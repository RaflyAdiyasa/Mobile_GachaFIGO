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

class GachaPage extends StatefulWidget {
  @override
  _GachaPageState createState() => _GachaPageState();
}

class _GachaPageState extends State<GachaPage> {
  bool _isLoading = false;
  final List<String> _cardIds = cardIds; // Assuming cardIds is a List<String>

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
      print(usersBox.values.toList());
      final user = usersBox.values.firstWhere(
        (u) => u.id == currentUserId,
        orElse: () => User(id: '', username: '', password: ''),
      );

      if (user.id.isEmpty) {
        _showToast("User not found");
        return;
      }

      if (user.credit < 3000) {
        _showToast("Not enough credit (Need 3000)");
        return;
      }

      // Random card selection
      final randomCardId =
          _cardIds[DateTime.now().millisecondsSinceEpoch % _cardIds.length];
      debugPrint("Attempting to fetch card: $randomCardId");

      final response = await http
          .get(
            Uri.parse(
              'https://api.atlasacademy.io/nice/NA/equip/$randomCardId',
            ),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        _showToast("Failed to fetch card data");
        return;
      }

      final cardData = json.decode(response.body);
      debugPrint("Card data received: ${cardData.toString()}");

      // Extract image URL
      String imageUrl = '';
      try {
        imageUrl =
            cardData['extraAssets']?['charaGraph']?['equip']?[randomCardId] ??
            cardData['extraAssets']?['equipFace']?['equip']?[randomCardId] ??
            '';
      } catch (e) {
        debugPrint("Error parsing image URL: $e");
      }

      final newCard = GachaCard(
        id: randomCardId,
        urlImg: imageUrl,
        rarity: cardData['rarity']?.toInt() ?? 1,
        name: cardData['name'] ?? 'Unknown Card',
        coordinates: location,
        time: DateTime.now(),
      );
      // Save to database
      final cardsBox = Hive.box<GachaCard>('cards');
      await cardsBox.add(newCard);

      // Update user
      final updatedUser = User(
        id: user.id,
        username: user.username,
        password: user.password,
        credit: user.credit - 3000,
        collection: List<String>.from(
          user.collection,
        ), // Buat copy yang mutable
      );

      updatedUser.collection.add(randomCardId);

      final userIndex = usersBox.values.toList().indexWhere(
        (u) => u.id == user.id,
      );
      if (userIndex != -1) {
        await usersBox.putAt(userIndex, updatedUser);
        _showToast("Got ${newCard.name}! (-3000 credit)");
        _showCardPopup(newCard);
      }
    } catch (e) {
      debugPrint("Gacha error: $e");
      _showToast(
        "Error: ${e.toString().replaceAll(RegExp(r'^Exception: '), '')}",
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showCardPopup(GachaCard card) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('You got: ${card.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (card.urlImg.isNotEmpty)
                    Image.network(
                      card.urlImg,
                      height: 200,
                      errorBuilder:
                          (_, __, ___) => Icon(Icons.error, size: 100),
                      loadingBuilder:
                          (_, child, progress) =>
                              progress == null
                                  ? child
                                  : CircularProgressIndicator(),
                    ),
                  SizedBox(height: 10),
                  Text('Rarity: ${'★' * card.rarity}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gacha')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _performGacha,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF0D47A1),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: Colors.blue[900],
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
                            'PULL GACHA (3000)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
            ),
            SizedBox(height: 20),
            // Text('Available cards: ${_cardIds.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
