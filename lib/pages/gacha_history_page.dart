import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gachafigo/models/card.dart';
import 'package:gachafigo/models/user.dart';

class GachaHistoryPage extends StatefulWidget {
  @override
  _GachaHistoryPageState createState() => _GachaHistoryPageState();
}

class _GachaHistoryPageState extends State<GachaHistoryPage> {
  List<GachaCard> _userGachaHistory = [];
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserHistory();
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
                        ),
                  );
                })
                .where((card) => card.id.isNotEmpty)
                .toList();

        // Sort by time (newest first)
        userCards.sort((a, b) => b.time.compareTo(a.time));

        setState(() {
          _userGachaHistory = userCards;
          _username = user.username;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_username\'s Gacha History'),
        backgroundColor: Color(0xFF0D47A1),
      ),
      body:
          _userGachaHistory.isEmpty
              ? Center(
                child: Text(
                  'No gacha history found',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: _userGachaHistory.length,
                itemBuilder: (context, index) {
                  final card = _userGachaHistory[index];
                  final coordinates = card.coordinates.split(',');
                  final lat = double.tryParse(coordinates[0]) ?? 0;
                  final lng = double.tryParse(coordinates[1]) ?? 0;

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRarityColor(card.rarity),
                        child: Text('${index + 1}'),
                      ),
                      title: Text(card.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${'★' * card.rarity}'),
                          Text(
                            '${card.time.toString().substring(0, 16)}',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      trailing: Icon(Icons.map),
                      onTap: () => _showMapDialog(context, lat, lng, card),
                    ),
                  );
                },
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
