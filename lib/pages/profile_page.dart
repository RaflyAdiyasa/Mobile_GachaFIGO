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
  final Color _primaryBlack = const Color.fromARGB(255, 255, 255, 255);
  final Color _accentColor = Colors.amber;

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
      backgroundColor: _primaryBlack,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(200),
        child: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: const Color.fromARGB(255, 252, 247, 247),
          flexibleSpace: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://static.atlasacademy.io/NA/CharaGraph/9302590/9302590a.png',
                fit: BoxFit.cover,
                color: const Color.fromARGB(
                  255,
                  255,
                  253,
                  253,
                ).withOpacity(0.8),
                colorBlendMode: BlendMode.darken,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: _primaryBlack.withOpacity(0.7),
                    child: CircleAvatar(
                      radius: 45,
                      backgroundImage: AssetImage(
                        'lib/assets/img/gambar_profile.jpeg',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 40), // Space for the overlapping avatar
            Text(
              'Rafly Adiyasa Putra',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            SizedBox(height: 5),
            Text(
              'NIM: 123220106',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            SizedBox(height: 20),
            _buildProfileCard(
              icon: Icons.person,
              title: 'Username',
              value: _username,
            ),
            SizedBox(height: 10),
            _buildProfileCard(
              icon: Icons.credit_card,
              title: 'Credit Score',
              value: _credit.toString(),
            ),
            SizedBox(height: 10),
            _buildProfileCard(
              icon: Icons.collections,
              title: 'Collection',
              value: _collectionCount.toString(),
            ),
            SizedBox(height: 25),
            _buildSection(
              title: 'Pesan',
              content: 'Wajah Aseli Admin',
              icon: Icons.message,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: _accentColor, size: 28),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                  ),
                  SizedBox(height: 5),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: _accentColor),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Divider(color: Colors.grey[800]),
            SizedBox(height: 10),
            Text(
              content,
              style: TextStyle(fontSize: 16, color: Colors.grey[300]),
            ),
          ],
        ),
      ),
    );
  }
}
