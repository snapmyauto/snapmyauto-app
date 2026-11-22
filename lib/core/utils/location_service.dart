import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationProblem { serviceOff, denied, deniedForever }

class LocationException implements Exception {
  const LocationException(this.problem);

  final LocationProblem problem;
}

// Shared by garages and SOS.
class LocationService {
  // Asks for permission if needed, then returns the current position.
  Future<LatLng> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationException(LocationProblem.serviceOff);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException(LocationProblem.denied);
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(LocationProblem.deniedForever);
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      // Indoors the GPS can time out, so fall back to the last fix.
      final last = await Geolocator.getLastKnownPosition();
      if (last == null) rethrow;
      return LatLng(last.latitude, last.longitude);
    }
  }

  Future<void> openSettings(LocationProblem problem) {
    return problem == LocationProblem.serviceOff
        ? Geolocator.openLocationSettings()
        : Geolocator.openAppSettings();
  }
}

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);
