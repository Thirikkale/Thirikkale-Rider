import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thirikkale_rider/core/services/web_socket_service.dart';

class RideTrackingProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription? _locationSubscription;
  LatLng? _driverLocation;
  String? _currentRideId;

  LatLng? get driverLocation => _driverLocation;
  bool get isTracking => _locationSubscription != null;

  void startTracking(String rideId) {
    if (_currentRideId == rideId && isTracking) {
      print('ℹ️ Already tracking ride: $rideId');
      return;
    }

    stopTracking(); // Stop any previous tracking
    _currentRideId = rideId;

    final locationStream = _webSocketService.subscribeToRideLocation(rideId);
    if (locationStream == null) {
      print('❌ Failed to get location stream. Is WebSocket connected?');
      // Optionally, try to connect here if not connected.
      return;
    }

    _locationSubscription = locationStream.listen(
      (locationData) {
        print('📍 Received new driver location: $locationData');
        if (locationData['latitude'] != null &&
            locationData['longitude'] != null) {
          _driverLocation = LatLng(
            locationData['latitude'],
            locationData['longitude'],
          );
          notifyListeners();
        }
      },
      onError: (error) {
        print('❌ Error in location stream: $error');
        stopTracking();
      },
    );

    print('✅ Started tracking for ride: $rideId');
  }

  void stopTracking() {
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
      _locationSubscription = null;
      _driverLocation = null;
      _currentRideId = null;
      print('🛑 Stopped tracking ride.');
      notifyListeners();
    }
  }
}
