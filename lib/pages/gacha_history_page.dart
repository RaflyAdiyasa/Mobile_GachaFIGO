import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gachafigo/models/card.dart';
import 'package:gachafigo/models/user.dart';
import 'package:gachafigo/services/timezone_service.dart';

class GachaHistoryPage extends StatefulWidget {
  @override
  _GachaHistoryPageState createState() => _GachaHistoryPageState();
}

class _GachaHistoryPageState extends State<GachaHistoryPage> {
  List<GachaCard> _userGachaHistory = [];
  List<GachaCard> _filteredHistory = [];
  String _username = '';
  String _selectedTimeZone = 'WIB';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserHistory();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterHistory();
    });
  }

  void _filterHistory() {
    if (_searchQuery.isEmpty) {
      _filteredHistory = List.from(_userGachaHistory);
    } else {
      _filteredHistory =
          _userGachaHistory
              .where(
                (card) => card.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
              )
              .toList();
    }
  }

  Future<void> _loadUserHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('currentUserId');

    if (currentUserId != null) {
      final usersBox = Hive.box<User>('users');
      final user = usersBox.values.firstWhere(
        (u) => u.id == currentUserId,
        orElse: () => User(id: '', username: '', password: ''),
      );

      if (user.id.isNotEmpty) {
        final cardsBox = Hive.box<GachaCard>('cards');
        final userCards =
            user.collection
                .map((cardId) {
                  return cardsBox.values.firstWhere(
                    (card) => card.id == cardId,
                    orElse:
                        () => GachaCard(
                          id: '',
                          urlImg: '',
                          rarity: 0,
                          name: 'Unknown',
                          coordinates: '0,0',
                          time: DateTime.now(),
                          imageLore: '',
                        ),
                  );
                })
                .where((card) => card.id.isNotEmpty)
                .toList();

        userCards.sort((a, b) => b.time.compareTo(a.time));

        setState(() {
          _userGachaHistory = userCards;
          _filteredHistory = List.from(_userGachaHistory);
          _username = user.username;
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final convertedTime = TimeZoneService.convertTimeZone(
      dateTime,
      _selectedTimeZone,
    );
    return '${convertedTime.day}/${convertedTime.month}/${convertedTime.year} '
        '${convertedTime.hour}:${convertedTime.minute.toString().padLeft(2, '0')} '
        '(${TimeZoneService.getTimeZoneAbbreviation(_selectedTimeZone)})';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildSearchField(),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: Icon(_searchQuery.isEmpty ? Icons.search : Icons.clear),
            onPressed: () {
              if (_searchQuery.isNotEmpty) {
                _searchController.clear();
              }
            },
          ),
          _buildTimeZoneDropdown(),
        ],
      ),
      body: _buildHistoryList(),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search ....',
        border: InputBorder.none,
        hintStyle: TextStyle(color: const Color.fromARGB(179, 0, 0, 0)),
      ),
      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
      cursorColor: const Color.fromARGB(255, 7, 118, 133),
    );
  }

  Widget _buildTimeZoneDropdown() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        setState(() {
          _selectedTimeZone = value;
        });
      },
      itemBuilder: (BuildContext context) {
        return ['WIB', 'WITA', 'WIT', 'LONDON', 'USA', 'JEPANG'].map((
          String choice,
        ) {
          return PopupMenuItem<String>(
            value: choice,
            child: Text(TimeZoneService.getTimeZoneAbbreviation(choice)),
          );
        }).toList();
      },
      icon: Icon(Icons.access_time, color: const Color.fromARGB(255, 0, 0, 0)),
    );
  }

  Widget _buildHistoryList() {
    if (_userGachaHistory.isEmpty) {
      return Center(
        child: Text('No gacha history found', style: TextStyle(fontSize: 18)),
      );
    }

    if (_filteredHistory.isEmpty && _searchQuery.isNotEmpty) {
      return Center(
        child: Text(
          'No results for "$_searchQuery"',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: _filteredHistory.length,
      itemBuilder: (context, index) {
        final card = _filteredHistory[index];
        final coordinates = card.coordinates.split(',');
        final lat = double.tryParse(coordinates[0]) ?? 0;
        final lng = double.tryParse(coordinates[1]) ?? 0;

        return Card(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getRarityColor(card.rarity),
              child: Text(
                '${index + 1}',
                style: TextStyle(color: Colors.white),
              ),
            ),
            title: _buildHighlightedText(card.name, _searchQuery),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${'★' * card.rarity}'),
                Text(
                  _formatDateTime(card.time),
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Icon(Icons.map),
            onTap: () => _showMapDialog(context, lat, lng, card),
          ),
        );
      },
    );
  }

  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query.toLowerCase())) {
      return Text(text);
    }

    final matches = query.toLowerCase().allMatches(text.toLowerCase()).toList();
    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in matches) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }

      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: TextStyle(
            backgroundColor: Colors.yellow,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }

  Color _getRarityColor(int rarity) {
    switch (rarity) {
      case 1:
        return Colors.brown;
      case 2:
        return Colors.brown[400]!;
      case 3:
        return Colors.grey;
      case 4:
        return Colors.amber;
      case 5:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }

  void _showMapDialog(
    BuildContext context,
    double lat,
    double lng,
    GachaCard card,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Pull Location'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lng),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    // subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40.0,
                        height: 40.0,
                        point: LatLng(lat, lng),

                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
    );
  }
}

//   String _formatDateTime(DateTime dateTime) {
//     final convertedTime = TimeZoneService.convertTimeZone(
//       dateTime,
//       _selectedTimeZone,
//     );
//     return '${convertedTime.day}/${convertedTime.month}/${convertedTime.year} '
//         '${convertedTime.hour}:${convertedTime.minute.toString().padLeft(2, '0')} '
//         '(${TimeZoneService.getTimeZoneAbbreviation(_selectedTimeZone)})';
//   }
// }
