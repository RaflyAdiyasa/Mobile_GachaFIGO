import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gachafigo/models/user.dart';
import 'package:gachafigo/models/card.dart';
import 'package:gachafigo/seeds/card_ids.dart';
import 'package:gachafigo/services/location_service.dart';
import 'package:photo_view/photo_view.dart';

class GachaPage extends StatefulWidget {
  @override
  _GachaPageState createState() => _GachaPageState();
}

class _GachaPageState extends State<GachaPage> {
  bool _isLoading = false;
  bool _isLoading10x = false;
  final List<String> _cardIds = cardIds;
  final Color _primaryColor = Color.fromARGB(179, 205, 194, 255);
  final Color _buttonColor = Color.fromARGB(255, 142, 175, 226);

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<List<GachaCard>> _fetchCards(int count) async {
    final List<GachaCard> cards = [];
    final location = await LocationService.getCurrentLocation();

    for (int i = 0; i < count; i++) {
      final randomCardId =
          _cardIds[DateTime.now().millisecondsSinceEpoch % _cardIds.length];

      final response = await http
          .get(
            Uri.parse(
              'https://api.atlasacademy.io/nice/NA/equip/$randomCardId?lore=true&lang=en',
            ),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final cardData = json.decode(response.body);
        String imageUrl =
            cardData['extraAssets']?['charaGraph']?['equip']?[randomCardId] ??
            cardData['extraAssets']?['equipFace']?['equip']?[randomCardId] ??
            '';

        cards.add(
          GachaCard(
            id: randomCardId,
            urlImg: imageUrl,
            rarity: cardData['rarity']?.toInt() ?? 1,
            name: cardData['name'] ?? 'Unknown Card',
            coordinates: location ?? '',
            time: DateTime.now(),
            imageLore:
                cardData['profile']?['comments']?[0]?['comment'] ??
                'No lore available',
          ),
        );
      }
    }
    return cards;
  }

  Future<void> _updateUserCredit(String userId, int cost) async {
    final usersBox = Hive.box<User>('users');
    final user = usersBox.values.firstWhere((u) => u.id == userId);

    final updatedUser = User(
      id: user.id,
      username: user.username,
      password: user.password,
      credit: user.credit - cost,
      collection: List<String>.from(user.collection),
    );

    final userIndex = usersBox.values.toList().indexWhere(
      (u) => u.id == user.id,
    );
    if (userIndex != -1) {
      await usersBox.putAt(userIndex, updatedUser);
    }
  }

  Future<void> _performGacha() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('currentUserId');

      final location = await LocationService.getCurrentLocation();
      if (location == null) {
        _showToast("Location permission required for gacha");
        return;
      }

      if (currentUserId == null || currentUserId.isEmpty) {
        _showToast("Session expired. Please login again.");
        return;
      }

      final usersBox = Hive.box<User>('users');
      final user = usersBox.values.firstWhere(
        (u) => u.id == currentUserId,
        orElse: () => User(id: '', username: '', password: ''),
      );

      if (user.id.isEmpty) {
        _showToast("User not found");
        return;
      }

      if (user.credit < 150) {
        _showToast("Not enough credit (Need 150)");
        return;
      }

      final cards = await _fetchCards(1);
      if (cards.isEmpty) {
        _showToast("Failed to fetch card data");
        return;
      }

      final cardsBox = Hive.box<GachaCard>('cards');
      await cardsBox.add(cards[0]);

      user.collection.add(cards[0].id);
      await _updateUserCredit(currentUserId, 150);

      _showToast("Got ${cards[0].name}! (-150 credit)");
      _showCardPopup(cards[0]);
    } catch (e) {
      _showToast(
        "Error: ${e.toString().replaceAll(RegExp(r'^Exception: '), '')}",
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _perform10xGacha() async {
    if (_isLoading10x) return;
    setState(() => _isLoading10x = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final currentUserId = prefs.getString('currentUserId');

      if (currentUserId == null || currentUserId.isEmpty) {
        _showToast("Session expired. Please login again.");
        return;
      }

      final usersBox = Hive.box<User>('users');
      final user = usersBox.values.firstWhere(
        (u) => u.id == currentUserId,
        orElse: () => User(id: '', username: '', password: ''),
      );

      if (user.id.isEmpty) {
        _showToast("User not found");
        return;
      }

      if (user.credit < 1500) {
        _showToast("Not enough credit (Need 1500)");
        return;
      }

      final cards = await _fetchCards(10);
      if (cards.isEmpty) {
        _showToast("Failed to fetch card data");
        return;
      }

      final cardsBox = Hive.box<GachaCard>('cards');
      for (final card in cards) {
        await cardsBox.add(card);
        user.collection.add(card.id);
      }

      await _updateUserCredit(currentUserId, 1500);
      _showToast("Got 10 cards! (-1500 credit)");
      _show10xResults(cards);
    } catch (e) {
      _showToast(
        "Error: ${e.toString().replaceAll(RegExp(r'^Exception: '), '')}",
      );
    } finally {
      if (mounted) setState(() => _isLoading10x = false);
    }
  }

  void _showCardPopup(GachaCard card, {bool from10x = false}) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                // Make the dialog scrollable
                child: Container(
                  decoration: _getCardDecoration(card.rarity),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: card.rarity >= 4 ? Colors.black : Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rarity: ${'★' * card.rarity}',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              card.rarity >= 4
                                  ? Colors.black87
                                  : Colors.white70,
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 200,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: PhotoView(
                            imageProvider: NetworkImage(card.urlImg),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 2,
                            backgroundDecoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                      if (card.imageLore.isNotEmpty &&
                          card.imageLore != 'No lore available')
                        Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lore:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        card.rarity >= 4
                                            ? Colors.black
                                            : Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  card.imageLore,
                                  style: TextStyle(
                                    color:
                                        card.rarity >= 4
                                            ? Colors.black87
                                            : Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white.withOpacity(0.8),
                        ),
                        child: Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      if (from10x && _displaying10xResults) {
        // Show the 10x results again after closing card detail
        _show10xResults(_last10xCards);
      }
    });
  }

  // Add these helper methods to your GachaPage class
  Color _getCardColor(int rarity) {
    switch (rarity) {
      case 1:
      case 2:
        return Color(0xFFCD7F32); // Bronze
      case 3:
        return Color(0xFFC0C0C0); // Silver
      case 4:
        return Color(0xFFDAA520); // Gold
      case 5:
        return Colors.purple; // Rainbow (base color)
      default:
        return Colors.grey;
    }
  }

  BoxDecoration _getCardDecoration(int rarity) {
    if (rarity == 5) {
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple,
            Colors.blue,
            Colors.green,
            Colors.yellow,
            Colors.orange,
            Colors.red,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      );
    }
    return BoxDecoration(
      color: _getCardColor(rarity),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 6,
          offset: Offset(0, 3),
        ),
      ],
    );
  }

  List<GachaCard> _last10xCards = [];
  bool _displaying10xResults = false;

  void _show10xResults(List<GachaCard> cards) {
    _last10xCards = cards;
    _displaying10xResults = true;

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: _primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '10x Gacha Results',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: SingleChildScrollView(
                      // Make the grid scrollable
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.pop(
                                context,
                              ); // Close the 10x results dialog
                              _showCardPopup(
                                card,
                                from10x: true,
                              ); // Show individual card detail
                            },
                            child: Container(
                              decoration: _getCardDecoration(card.rarity),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child:
                                          card.urlImg.isNotEmpty
                                              ? Image.network(
                                                card.urlImg,
                                                fit: BoxFit.contain,
                                              )
                                              : Center(
                                                child: Icon(
                                                  Icons.help_outline,
                                                  size: 40,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      children: [
                                        Text(
                                          card.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                card.rarity >= 4
                                                    ? Colors.black
                                                    : Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '${'★' * card.rarity}',
                                          style: TextStyle(
                                            color:
                                                card.rarity >= 4
                                                    ? Colors.black87
                                                    : Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _displaying10xResults = false;
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColor,
                    ),
                    child: Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: _primaryColor,
      appBar: AppBar(
        title: Text('Gacha', style: TextStyle(color: Colors.white)),
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Single Gacha Button
            ElevatedButton(
              onPressed: _isLoading ? null : _performGacha,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _buttonColor,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child:
                  _isLoading
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'PULL GACHA (150)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
            ),
            SizedBox(height: 30),
            // 10x Gacha Button
            ElevatedButton(
              onPressed: _isLoading10x ? null : _perform10xGacha,
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 52, 219, 197),
                // backgroundColor: Colors.purple[300],
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child:
                  _isLoading10x
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: const Color.fromARGB(255, 89, 207, 188),
                        ),
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome_mosaic, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'PULL 10x (1500)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
