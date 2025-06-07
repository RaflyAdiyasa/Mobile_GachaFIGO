import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:gachafigo/models/user.dart';
import 'package:gachafigo/pages/collection_page.dart';
import 'package:gachafigo/pages/gacha_page.dart';
import 'package:gachafigo/pages/topup_page.dart';
import 'package:gachafigo/pages/login_page.dart';
import 'package:gachafigo/pages/suggestions_page.dart';
import 'package:gachafigo/pages/profile_page.dart';
import 'package:gachafigo/pages/gacha_history_page.dart';
import 'package:gachafigo/pages/gacha_menu_page.dart';

class MainMenuPage extends StatefulWidget {
  @override
  _MainMenuPageState createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  int _currentIndex = 0;
  String _username = '';
  int _credit = 0;

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
        (user) => user.id == currentUserId,
        orElse: () => User(id: '', username: '', password: ''),
      );

      if (user.id.isNotEmpty) {
        setState(() {
          _username = user.username;
          _credit = user.credit;
        });
      }
    }
  }

  Widget _buildProfileAvatar() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
      },
      child: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          _username.isNotEmpty ? _username[0].toUpperCase() : '?',
          style: TextStyle(
            color: Color(0xFF0D47A1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('currentUserId');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://static.atlasacademy.io/NA/CharaGraph/9302590/9302590a.png',
                fit: BoxFit.cover,
              ),
              Container(color: Colors.black.withOpacity(0.25)),
            ],
          ),
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: NetworkImage(
                    'https://static.atlasacademy.io/NA/CharaGraph/9400030/9400030a.png',
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'GachaFI-GO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black54,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.account_balance_wallet, color: Colors.white),
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Wallet Information',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                radius: 15,
                                backgroundImage: NetworkImage(
                                  'https://static.atlasacademy.io/NA/CharaGraph/9400030/9400030a.png',
                                ),
                              ),
                              title: Text(
                                _username,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Account Balance'),
                            ),
                            Divider(),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Current Credits:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Text(
                                    '$_credit',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Close',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          SizedBox(width: 40),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TopUpPage(),
                                ),
                              ).then((_) => _loadUserData());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(
                                179,
                                205,
                                194,
                                255,
                              ),
                            ),
                            child: Text('Top Up'),
                          ),
                        ],
                      ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: _logout,
            ),
          ],
        ),
      ),

      body: _getPage(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Color.fromARGB(255, 142, 175, 226), // Dark blue
        selectedItemColor: const Color.fromARGB(255, 255, 2, 2),
        unselectedItemColor: const Color.fromARGB(179, 32, 5, 151),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Main Menu'),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections),
            label: 'Collection',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.feedback), label: 'Saran'),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeMenu(
          onGachaPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GachaPage()),
            ).then((_) => _loadUserData());
          },
          username: _username,
          credit: _credit,
        );
      case 1:
        return CollectionPage();
      case 2:
        return GachaHistoryPage();
      case 3:
        return SuggestionsPage();
      default:
        return Center(child: Text('Coming Soon'));
    }
  }
}
