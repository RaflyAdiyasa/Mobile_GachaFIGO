import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gachafigo/models/user.dart';

class TopUpPage extends StatefulWidget {
  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Top Up Credit')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildTopUpButton(6000, '+6000 Credit'),
            SizedBox(height: 20),
            _buildTopUpButton(12000, '+12000 Credit'),
          ],
        ),
      ),
    );
  }

  Widget _buildTopUpButton(int amount, String label) {
    return ElevatedButton(
      onPressed: () => _topUpCredit(amount),
      child: Text(label),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      ),
    );
  }

  Future<void> _topUpCredit(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('currentUserId');

    if (currentUserId != null) {
      final usersBox = Hive.box<User>('users');
      final user = usersBox.values.firstWhere((u) => u.id == currentUserId);

      user.credit += amount;
      await user.save();

      Fluttertoast.showToast(
        msg: "Successfully added $amount credit",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      Navigator.pop(context);
    }
  }
}
