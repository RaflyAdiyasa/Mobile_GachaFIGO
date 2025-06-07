import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:gachafigo/models/user.dart';

class AccelerometerGame extends StatefulWidget {
  @override
  _AccelerometerGameState createState() => _AccelerometerGameState();
}

class _AccelerometerGameState extends State<AccelerometerGame> {
  double _posX = 0;
  double _posY = 0;
  int _score = 0;
  int _shakeCount = 0;
  bool _isGameActive = true;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  DateTime? _lastShakeTime;

  // Target position untuk ditangkap
  double _targetX = 100;
  double _targetY = -100;
  final double _targetRadius = 40;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  void _startGame() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (!_isGameActive) return;

      setState(() {
        // Update posisi bola berdasarkan accelerometer
        _posX = (_posX - event.y * 10).clamp(-200.0, 200.0);
        _posY = (_posY + event.x * 10).clamp(-200.0, 200.0);

        // Deteksi shake (gerakan kuat)
        final double shakeIntensity =
            (event.x.abs() + event.y.abs() + event.z.abs()) - 10;

        if (shakeIntensity > 15) {
          final now = DateTime.now();
          if (_lastShakeTime == null ||
              now.difference(_lastShakeTime!) > Duration(seconds: 1)) {
            _shakeCount++;
            _score += 5; // 5 poin per shake
            _lastShakeTime = now;
          }
        }

        // Deteksi collision dengan target
        final double distanceToTarget = sqrt(
          pow(_posX - _targetX, 2) + pow(_posY - _targetY, 2),
        );
        if (distanceToTarget < _targetRadius) {
          _score += 10; // 10 poin jika menyentuh target
          // Reset target position
          _targetX = Random().nextDouble() * 400 - 200;
          _targetY = Random().nextDouble() * 400 - 200;
        }
      });
    });
  }

  Future<void> _saveScore() async {
    if (_score == 0) return;

    final prefs = await SharedPreferences.getInstance();
    final currentUserId = prefs.getString('currentUserId');

    if (currentUserId == null) return;

    final usersBox = Hive.box<User>('users');
    final userIndex = usersBox.values.toList().indexWhere(
      (u) => u.id == currentUserId,
    );

    if (userIndex == -1) return;

    final user = usersBox.getAt(userIndex) as User;
    final updatedUser = User(
      id: user.id,
      username: user.username,
      password: user.password,
      credit: user.credit + _score,
      collection: List.from(user.collection),
    );

    await usersBox.putAt(userIndex, updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$_score credits added to your account!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tilt & Shake Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
              _isGameActive = false;
              _saveScore().then((_) => Navigator.pop(context));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(179, 205, 194, 255)!,
                  Colors.blue[300]!,
                ],
              ),
            ),
          ),

          // Target
          Positioned(
            left:
                _targetX +
                MediaQuery.of(context).size.width / 2 -
                _targetRadius,
            top:
                _targetY +
                MediaQuery.of(context).size.height / 2 -
                _targetRadius,
            child: Container(
              width: _targetRadius * 2,
              height: _targetRadius * 2,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(Icons.star, color: Colors.yellow, size: 30),
              ),
            ),
          ),

          // Player ball
          AnimatedPositioned(
            duration: Duration(milliseconds: 100),
            left: _posX + MediaQuery.of(context).size.width / 2 - 25,
            top: _posY + MediaQuery.of(context).size.height / 2 - 25,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Score display
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Score: $_score',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ),
          ),

          // Instructions
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Tilt your device to move the ball',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Shake to earn 5 points',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    Text(
                      'Catch stars to earn 10 points',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
