import 'package:flutter/material.dart';
import 'package:flutter_sensors/flutter_sensors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:gachafigo/models/user.dart';
import 'dart:async';

class LightSensorGame extends StatefulWidget {
  @override
  _LightSensorGameState createState() => _LightSensorGameState();
}

class _LightSensorGameState extends State<LightSensorGame> {
  double _lightLevel = 0; // 0-1 scale
  int _score = 0;
  bool _isGameActive = true;
  StreamSubscription<SensorEvent>? _lightSubscription;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _lightSubscription?.cancel();
    super.dispose();
  }

  void _startGame() async {
    final available = await SensorManager().isSensorAvailable(
      Sensors.SENSOR_STATUS_ACCURACY_HIGH,
    );
    if (!available) {
      print("Light sensor not available");
      return;
    }

    final stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.ACCELEROMETER,
      interval: Sensors.SENSOR_DELAY_NORMAL,
    );

    _lightSubscription = stream.listen((SensorEvent event) {
      if (!_isGameActive) return;

      final now = DateTime.now();
      final timePassed =
          _lastUpdate == null
              ? 1.0
              : now.difference(_lastUpdate!).inMilliseconds / 1000.0;
      _lastUpdate = now;

      final lux = event.data[0];
      final normalized = (lux / 1000).clamp(0.0, 1.0);

      setState(() {
        _lightLevel = normalized;
        _score += (_lightLevel * 10 * timePassed).toInt();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Light Sensor Game")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Light Level: ${_lightLevel.toStringAsFixed(2)}"),
            SizedBox(height: 20),
            Text("Score: $_score"),
          ],
        ),
      ),
    );
  }
}
