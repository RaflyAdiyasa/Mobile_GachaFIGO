import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gachafigo/models/user.dart';
import 'package:gachafigo/models/card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Collection')),
      body:
          _userCards.isEmpty
              ? Center(child: Text('No cards in your collection yet'))
              : GridView.builder(
                padding: EdgeInsets.all(8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 0.7,
                ),
                itemCount: _userCards.length,
                itemBuilder: (context, index) {
                  final card = _userCards[index];
                  return Card(
                    child: Column(
                      children: [
                        Expanded(
                          child:
                              card.urlImg.isNotEmpty
                                  ? Image.network(
                                    card.urlImg,
                                    fit: BoxFit.cover,
                                  )
                                  : Placeholder(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.name,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('Rarity: ${'★' * card.rarity}'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
