import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gachafigo/models/user.dart';
import 'package:gachafigo/models/card.dart';
import 'package:photo_view/photo_view.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<GachaCard> _userCards = [];

  @override
  void initState() {
    super.initState();
    _loadUserCollection();
  }

  Future<void> _loadUserCollection() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('currentUserId');

    if (currentUserId != null) {
      final usersBox = Hive.box<User>('users');
      final user = usersBox.values.firstWhere((u) => u.id == currentUserId);

      final cardsBox = Hive.box<GachaCard>('cards');
      _userCards =
          user.collection
              .map(
                (cardId) => cardsBox.values.firstWhere(
                  (card) => card.id == cardId,
                  orElse:
                      () => GachaCard(
                        id: '',
                        urlImg: '',
                        rarity: 0,
                        name: 'Unknown',
                      ),
                ),
              )
              .where((card) => card.id.isNotEmpty)
              .toList();

      setState(() {});
    }
  }

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

  void _showCardDetail(GachaCard card) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.all(20),
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
                      color: card.rarity >= 4 ? Colors.black87 : Colors.white70,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    height: 300,
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
                        loadingBuilder:
                            (context, event) =>
                                Center(child: CircularProgressIndicator()),
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Center(child: Icon(Icons.error, size: 50)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      foregroundColor: Colors.black,
                    ),
                    child: Text('Close'),
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
      appBar: AppBar(title: Text('My Collection'), centerTitle: true),
      body:
          _userCards.isEmpty
              ? Center(
                child: Text(
                  'No cards in your collection yet',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : GridView.builder(
                padding: EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                itemCount: _userCards.length,
                itemBuilder: (context, index) {
                  final card = _userCards[index];
                  return GestureDetector(
                    onTap: () => _showCardDetail(card),
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
                                        loadingBuilder: (
                                          context,
                                          child,
                                          progress,
                                        ) {
                                          return progress == null
                                              ? child
                                              : Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 40,
                                              color: Colors.white70,
                                            ),
                                          );
                                        },
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
    );
  }
}
