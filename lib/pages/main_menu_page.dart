import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:gachafigo/models/user.dart';
import 'package:gachafigo/pages/collection_page.dart';
import 'package:gachafigo/pages/gacha_page.dart';
import 'package:gachafigo/pages/topup_page.dart';
import 'package:gachafigo/pages/login_page.dart';
import 'package:gachafigo/pages/suggestions_page.dart';

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
      appBar: AppBar(
        title: Text(
          'Hello $_username',
          style: TextStyle(
            color: const Color.fromARGB(179, 32, 5, 151),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(179, 205, 194, 255),
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: Text('Credit Info'),
                      content: Text('Current Credit: $_credit'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TopUpPage(),
                              ),
                            ).then((_) => _loadUserData());
                          },
                          child: Text('Top Up'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Close'),
                        ),
                      ],
                    ),
              );
            },
          ),
          IconButton(icon: Icon(Icons.logout), onPressed: _logout),
        ],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.add_comment),
            label: 'Coming Soon',
          ),
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
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GachaPage()),
                  ).then((_) => _loadUserData());
                },
                child: Text('Gacha (3000 Credit)'),
              ),
            ],
          ),
        );
      case 1:
        return CollectionPage();
      case 2:
        return Center(child: Text('Coming Soon'));
      case 3:
        return SuggestionsPage();
      default:
        return Center(child: Text('Coming Soon'));
    }
  }
}
