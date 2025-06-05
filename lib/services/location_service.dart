import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<String?> getCurrentLocation() async {
    try {
      // Check permission status
      final status = await Permission.location.request();
      if (!status.isGranted) {
        return null;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return "${position.latitude},${position.longitude}";
    } catch (e) {
      print("Location error: $e");
      return null;
    }
  }

  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }
}
