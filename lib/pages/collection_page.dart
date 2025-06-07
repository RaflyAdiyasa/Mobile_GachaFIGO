import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gachafigo/models/user.dart';
import 'package:gachafigo/models/card.dart';
import 'package:photo_view/photo_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CollectionPage extends StatefulWidget {
  @override
  _CollectionPageState createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  List<GachaCard> _userCards = [];
  List<GachaCard> _displayedCards = [];
  bool _showFavoritesOnly = false;
  bool _isFavorite = false; // Track favorite state for animation

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
                        time: DateTime.now(),
                        coordinates: '',
                        imageLore: '',
                      ),
                ),
              )
              .where((card) => card.id.isNotEmpty)
              .toList();

      _updateDisplayedCards();
      setState(() {});
    }
  }

  void _updateDisplayedCards() {
    if (_showFavoritesOnly) {
      _loadFavorites();
    } else {
      _displayedCards = List.from(_userCards);
      _displayedCards.sort((a, b) => b.rarity.compareTo(a.rarity));
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('currentUserId');

    if (currentUserId != null) {
      final usersBox = Hive.box<User>('users');
      final user = usersBox.values.firstWhere(
        (u) => u.id == currentUserId,
        orElse: () => User(id: '', username: '', password: ''),
      );

      if (user.id.isNotEmpty) {
        final favoriteCardIds = user.favoriteCards;
        _displayedCards =
            _userCards
                .where((card) => favoriteCardIds.contains(card.id))
                .toList();
        _displayedCards.sort((a, b) => b.rarity.compareTo(a.rarity));
        setState(() {});
      }
    }
  }

  Future<void> _deleteCard(GachaCard card) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('currentUserId');

    if (currentUserId == null) return;

    final usersBox = Hive.box<User>('users');
    final userIndex = usersBox.values.toList().indexWhere(
      (u) => u.id == currentUserId,
    );

    if (userIndex == -1) return;

    final user = usersBox.getAt(userIndex) as User;
    final updatedCollection = List<String>.from(user.collection)
      ..remove(card.id);
    final updatedFavorites = List<String>.from(user.favoriteCards)
      ..remove(card.id);

    final updatedUser = User(
      id: user.id,
      username: user.username,
      password: user.password,
      credit: user.credit,
      collection: updatedCollection,
      favoriteCards: updatedFavorites,
    );

    await usersBox.putAt(userIndex, updatedUser);
    await _loadUserCollection(); // Refresh the list

    Fluttertoast.showToast(
      msg: "Card removed from collection",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
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

  void _showCardDetail(GachaCard card) async {
    // Check favorite status before showing dialog
    var isFavorite = await _isCardFavorite(card.id);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
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
                        color:
                            card.rarity >= 4 ? Colors.black87 : Colors.white70,
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
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight: 150, // Set maximum height for lore
                            ),
                            child: SingleChildScrollView(
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
                        ),
                      ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white.withOpacity(0.8),
                          ),
                          child: Text('Close'),
                        ),
                        IconButton(
                          icon: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              key: ValueKey<bool>(isFavorite),
                              color: isFavorite ? Colors.red : Colors.grey,
                              size: 30,
                            ),
                          ),
                          onPressed: () async {
                            await _toggleFavorite(card.id);
                            final newStatus = await _isCardFavorite(card.id);
                            setState(() {
                              isFavorite = newStatus;
                            });
                            // Update the main view if needed
                            if (_showFavoritesOnly) {
                              _loadFavorites();
                            }
                          },
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _showDeleteConfirmation(card);
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.red[600],
                          ),
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _toggleFavorite(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('currentUserId');

    if (currentUserId == null) return;

    final usersBox = Hive.box<User>('users');
    final userIndex = usersBox.values.toList().indexWhere(
      (u) => u.id == currentUserId,
    );

    if (userIndex == -1) return;

    final user = usersBox.getAt(userIndex) as User;
    final updatedFavorites = List<String>.from(user.favoriteCards);

    if (updatedFavorites.contains(cardId)) {
      updatedFavorites.remove(cardId);
    } else {
      updatedFavorites.add(cardId);
    }

    final updatedUser = User(
      id: user.id,
      username: user.username,
      password: user.password,
      credit: user.credit,
      collection: List.from(user.collection),
      favoriteCards: updatedFavorites,
    );

    await usersBox.putAt(userIndex, updatedUser);
    _updateDisplayedCards();
    setState(() {}); // Refresh the UI
  }

  Future<bool> _isCardFavorite(String cardId) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('currentUserId');

    if (currentUserId == null) return false;

    final usersBox = Hive.box<User>('users');
    final user = usersBox.values.firstWhere(
      (u) => u.id == currentUserId,
      orElse: () => User(id: '', username: '', password: ''),
    );

    return user.favoriteCards.contains(cardId);
  }

  void _showDeleteConfirmation(GachaCard card) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text(
              'Are you sure you want to remove this card from your collection?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteCard(card);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _toggleViewMode() {
    setState(() {
      _showFavoritesOnly = !_showFavoritesOnly;
      _updateDisplayedCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_showFavoritesOnly ? 'Favorite Cards' : 'My Collection'),
        centerTitle: false,
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.collections : Icons.favorite,
              color: _showFavoritesOnly ? Colors.red : Colors.black,
            ),
            onPressed: _toggleViewMode,
          ),
        ],
      ),
      body:
          _displayedCards.isEmpty
              ? Center(
                child: Text(
                  _showFavoritesOnly
                      ? 'No favorite cards yet'
                      : 'No cards in your collection yet',
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
                itemCount: _displayedCards.length,
                itemBuilder: (context, index) {
                  final card = _displayedCards[index];
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
