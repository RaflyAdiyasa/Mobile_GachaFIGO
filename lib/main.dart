import 'package:flutter/material.dart';
import 'package:gachafigo/pages/main_menu_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:gachafigo/models/user.dart';
import 'package:gachafigo/models/card.dart';
import 'package:gachafigo/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(GachaCardAdapter());
  await Hive.openBox<User>('users');
  await Hive.openBox<GachaCard>('cards');

  try {
    await Hive.openBox<User>('users');
  } catch (e) {
    await Hive.deleteBoxFromDisk('users');
    await Hive.openBox<User>('users');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GachaFigo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: AppBarTheme(
          backgroundColor: Color.fromARGB(179, 205, 194, 255), // Dark blue
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(179, 32, 5, 151), // Dark blue
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: _checkSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data == true ? MainMenuPage() : LoginPage();
          }
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
    );
  }

  Future<bool> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
