import 'dart:async';
import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/services/web_socket_service.dart';
import 'package:thirikkale_rider/models/ride_model.dart'; // Assuming you have a Ride model

enum RideState { initial, pending, accepted, driverArrived, inProgress, completed, cancelled }

class RideStatusProvider with ChangeNotifier {
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription? _statusSubscription;
  Ride? _currentRide;
  RideState _rideState = RideState.initial;

  Ride? get currentRide => _currentRide;
  RideState get rideState => _rideState;

  void updateRide(Ride ride) {
    _currentRide = ride;
    _rideState = _mapStatusToState(ride.status);
    notifyListeners();
  }

  void listenForRideUpdates(String riderId) {
    if (_statusSubscription != null) {
      _statusSubscription!.cancel();
    }
    
    print('🔔 Subscribing to ride updates for rider: $riderId');
    final stream = _webSocketService.subscribeToRideUpdates(riderId);

    if (stream != null) {
      _statusSubscription = stream.listen((rideData) {
        print('📊 Received ride update via WebSocket: $rideData');
        final ride = Ride.fromJson(rideData); // Assuming a fromJson factory
        updateRide(ride);
      });
    } else {
      print('❌ Could not subscribe to ride updates. WebSocket not connected?');
    }
  }

  RideState _mapStatusToState(String status) {
    switch (status) {
      case 'PENDING':
        return RideState.pending;
      case 'ACCEPTED':
        return RideState.accepted;
      case 'DRIVER_ARRIVED':
        return RideState.driverArrived;
      case 'IN_PROGRESS':
        return RideState.inProgress;
      case 'COMPLETED':
        return RideState.completed;
      case 'CANCELLED_BY_RIDER':
      case 'CANCELLED_BY_DRIVER':
      case 'CANCELLED_BY_SYSTEM':
        return RideState.cancelled;
      default:
        return RideState.initial;
    }
  }

  void stopListening() {
    _statusSubscription?.cancel();
    _statusSubscription = null;
    _currentRide = null;
    _rideState = RideState.initial;
    print('🛑 Stopped listening for ride updates.');
    notifyListeners();
  }
}
