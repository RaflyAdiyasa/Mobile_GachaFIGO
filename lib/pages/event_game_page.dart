// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:sensors_plus/sensors_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:hive/hive.dart';
// import 'package:gachafigo/models/user.dart';

// class EventGamePage extends StatefulWidget {
//   @override
//   _EventGamePageState createState() => _EventGamePageState();
// }

// class _EventGamePageState extends State<EventGamePage> {
//   double _posX = 0;
//   double _posY = 0;
//   int _score = 1;
//   int _shakeCount = 0;
//   bool _isGameActive = true;
//   StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _startGame();
//   }

//   @override
//   void dispose() {
//     _accelerometerSubscription?.cancel();
//     super.dispose();
//   }

//   void _startGame() {
//     _accelerometerSubscription = accelerometerEvents.listen((event) {
//       if (!_isGameActive) return;

//       // Calculate shake intensity
//       final double shakeIntensity =
//           (event.x.abs() + event.y.abs() + event.z.abs()) - 10;

//       if (shakeIntensity > 3) {
//         // Threshold for shake detection
//         _shakeCount++;

//         // Every 5 shakes = 1 credit
//         if (_shakeCount % 5 == 0) {
//           setState(() {
//             _score++;
//           });
//         }
//       }

//       // Update ball position based on device tilt
//       setState(() {
//         _posX = (_posX + event.y * 5).clamp(-150.0, 150.0);
//         _posY = (_posY + event.x * 5).clamp(-150.0, 150.0);
//       });
//     });
//   }

//   Future<void> _saveScore() async {
//     if (_score == 0) return;

//     final prefs = await SharedPreferences.getInstance();
//     final currentUserId = prefs.getString('currentUserId');

//     if (currentUserId == null) return;

//     final usersBox = Hive.box<User>('users');
//     final userIndex = usersBox.values.toList().indexWhere(
//       (u) => u.id == currentUserId,
//     );

//     if (userIndex == -1) return;

//     final user = usersBox.getAt(userIndex) as User;
//     final updatedUser = User(
//       id: user.id,
//       username: user.username,
//       password: user.password,
//       credit: user.credit + _score,
//       collection: List.from(user.collection),
//     );

//     await usersBox.putAt(userIndex, updatedUser);

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('$_score credits added to your account!')),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Shake For Credits'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: () {
//               _isGameActive = false;
//               _saveScore().then((_) => Navigator.pop(context));
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Stack(
//           children: [
//             // Background
//             Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Color.fromARGB(179, 205, 194, 255)!,
//                     Colors.blue[300]!,
//                   ],
//                 ),
//               ),
//             ),

//             // Ball
//             AnimatedPositioned(
//               duration: Duration(milliseconds: 100),
//               left: _posX + MediaQuery.of(context).size.width / 2 - 25,
//               top: _posY + MediaQuery.of(context).size.height / 2 - 25,
//               child: Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: Colors.red,
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 10,
//                       spreadRadius: 2,
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Score display
//             Positioned(
//               top: 50,
//               right: 20,
//               child: Container(
//                 padding: EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.8),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   'Credits: $_score',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue[800],
//                   ),
//                 ),
//               ),
//             ),

//             // Instructions
//             Positioned(
//               bottom: 30,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   padding: EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.5),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     'Shake your device to earn credits!\n'
//                     '5 shakes = 1 credit\n'
//                     'Press save to add credits to your account',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
