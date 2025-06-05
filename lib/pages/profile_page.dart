import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gachafigo/models/user.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _username = '';
  int _credit = 0;
  int _collectionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('currentUserId');

    if (currentUserId != null) {
      final usersBox = Hive.box<User>('users');
      final user = usersBox.values.firstWhere(
        (u) => u.id == currentUserId,
        orElse: () => User(id: '', username: '', password: ''),
      );

      if (user.id.isNotEmpty) {
        setState(() {
          _username = user.username;
          _credit = user.credit;
          _collectionCount = user.collection.length;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 142, 175, 226),
        title: Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF0D47A1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('lib/assets/img/gambar_profile.jpeg'),
            ),
            SizedBox(height: 20),
            Text(
              'Rafly Adiyasa Putra',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            _buildProfileItem('Username', _username),
            _buildProfileItem('NIM', '123220106'),
            _buildProfileItem('Credit Score', _credit.toString()),
            _buildProfileItem('Collection', _collectionCount.toString()),

            SizedBox(height: 40),
            _buildSection('Pesan', 'Wajah Aseli Admin'),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1),
            ),
          ),
          SizedBox(height: 8),
          Text(content, style: TextStyle(fontSize: 16)),
          Divider(color: Colors.grey),
        ],
      ),
    );
  }
}
