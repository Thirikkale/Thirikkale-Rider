import 'package:flutter/material.dart';
import 'package:thirikkale_rider/features/booking/models/vehicle_option.dart';

class RideBookingProvider extends ChangeNotifier {
  // Trip details
  String _pickupAddress = '';
  String _destinationAddress = '';
  double? _pickupLat;
  double? _pickupLng;
  double? _destLat;
  double? _destLng;

  // Selected options
  VehicleOption? _selectedVehicle;
  String _selectedPaymentMethod = 'cash';
  String _scheduleType = 'now';
  DateTime? _scheduledDateTime;

  // Available options
  final List<VehicleOption> _vehicleOptions = VehicleOption.getDefaultOptions();

  // Loading states
  bool _isLoadingRoute = false;
  bool _isBookingRide = false;
  bool _isSettingTrip = false;

  // Trip information
  String? _estimatedDuration;
  String? _estimatedDistance;
  double? _estimatedPrice;

  // Getters
  String get pickupAddress => _pickupAddress;
  String get destinationAddress => _destinationAddress;
  double? get pickupLat => _pickupLat;
  double? get pickupLng => _pickupLng;
  double? get destLat => _destLat;
  double? get destLng => _destLng;

  VehicleOption? get selectedVehicle => _selectedVehicle;
  String get selectedPaymentMethod => _selectedPaymentMethod;
  String get scheduleType => _scheduleType;
  DateTime? get scheduledDateTime => _scheduledDateTime;

  List<VehicleOption> get vehicleOptions => _vehicleOptions;

  bool get isLoadingRoute => _isLoadingRoute;
  bool get isBookingRide => _isBookingRide;
  bool get isSettingTrip => _isSettingTrip;

  String? get estimatedDuration => _estimatedDuration;
  String? get estimatedDistance => _estimatedDistance;
  double? get estimatedPrice => _estimatedPrice;

  bool get canBookRide => 
      _selectedVehicle != null && 
      _pickupAddress.isNotEmpty && 
      _destinationAddress.isNotEmpty;

  bool get hasValidLocations =>
      _pickupLat != null && 
      _pickupLng != null && 
      _destLat != null && 
      _destLng != null;

  // Methods
  Future<void> setTripDetails({
    required String pickup,
    required String destination,
    double? pickupLat,
    double? pickupLng,
    double? destLat,
    double? destLng,
    bool preserveVehicleSelection = false,
  }) async {
    _isSettingTrip = true;
    notifyListeners();

    // Simulate a short delay to allow UI to show loading state
    await Future.delayed(const Duration(milliseconds: 50));

    _pickupAddress = pickup;
    _destinationAddress = destination;
    _pickupLat = pickupLat;
    _pickupLng = pickupLng;
    _destLat = destLat;
    _destLng = destLng;

    // Reset previous selections when trip details change, unless preserving
    if (!preserveVehicleSelection) {
      _selectedVehicle = null;
      _estimatedPrice = null;
    }
    _estimatedDuration = null;
    _estimatedDistance = null;

    _isSettingTrip = false;
    notifyListeners();
  }

  void setRouteInfo({
    String? duration,
    String? distance,
  }) {
    _estimatedDuration = duration;
    _estimatedDistance = distance;
    _updateVehiclePrices();
    notifyListeners();
  }

  void selectVehicle(VehicleOption vehicle) {
    _selectedVehicle = vehicle;
    _estimatedPrice = vehicle.price;
    notifyListeners();
  }

  void setInitialVehicleByRideType(String? rideType) {
    if (rideType == null) return;
    
    // Map ride type to vehicle option ID
    String vehicleId;
    switch (rideType.toLowerCase()) {
      case 'tuk':
        vehicleId = 'tuk';
        break;
      case 'ride':
      case 'solo':
        vehicleId = 'ride';
        break;
      case 'rush':
        vehicleId = 'rush';
        break;
      case 'prime':
      case 'prime ride':
        vehicleId = 'primeRide';
        break;
      case 'shared':
        // For shared rides, we could use a different logic or default to ride
        vehicleId = 'ride';
        break;
      default:
        // Default to ride if unknown type
        vehicleId = 'ride';
        break;
    }
    
    // Find and select the corresponding vehicle option
    final vehicle = _vehicleOptions.firstWhere(
      (option) => option.id == vehicleId,
      orElse: () => _vehicleOptions.first, // Fallback to first option
    );
    
    selectVehicle(vehicle);
  }

  void setPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void setScheduleType(String type) {
    _scheduleType = type;
    notifyListeners();
  }

  void setScheduledDateTime(DateTime? dateTime) {
    _scheduledDateTime = dateTime;
    notifyListeners();
  }

  void setLoadingRoute(bool loading) {
    _isLoadingRoute = loading;
    notifyListeners();
  }

  void _updateVehiclePrices() {
    // You can implement dynamic pricing based on distance/duration here
    // For now, using default prices from VehicleOption.getDefaultOptions()
  }

  // Booking methods
  Future<void> bookRide() async {
    if (!canBookRide) {
      throw Exception('Cannot book ride: Missing required information');
    }

    _isBookingRide = true;
    notifyListeners();

    try {
      // Simulate API call for booking
      await _simulateBookingAPI();
      
      // Handle successful booking
      await _handleSuccessfulBooking();
      
    } catch (e) {
      // Handle booking error
      print('Booking failed: $e');
      _handleBookingError(e);
      rethrow; // Re-throw to let UI handle the error
    } finally {
      _isBookingRide = false;
      notifyListeners();
    }
  }

  Future<void> _simulateBookingAPI() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Simulate possible booking scenarios
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    
    if (random < 5) {
      // 5% chance of failure for testing
      throw Exception('Network error: Unable to connect to server');
    }
    
    if (random < 10) {
      // 5% chance of no available drivers
      throw Exception('No drivers available in your area');
    }
    
    // 90% success rate
    print('Booking successful!');
  }

  Future<void> _handleSuccessfulBooking() async {
    // You can add any post-booking logic here
    // For example: storing booking in local database, sending notifications, etc.
    
    print('Ride booked successfully!');
    print('Vehicle: ${_selectedVehicle?.name}');
    print('Pickup: $_pickupAddress');
    print('Destination: $_destinationAddress');
    print('Payment: $_selectedPaymentMethod');
    print('Schedule: $_scheduleType');
  }

  void _handleBookingError(dynamic error) {
    // Handle different types of booking errors
    print('Booking error: $error');
    // You can add error logging, analytics, etc. here
  }

  // Utility methods
  Map<String, dynamic> getTripSummary() {
    return {
      'pickup': _pickupAddress,
      'destination': _destinationAddress,
      'vehicle': _selectedVehicle?.toMap(),
      'paymentMethod': _selectedPaymentMethod,
      'scheduleType': _scheduleType,
      'estimatedDuration': _estimatedDuration,
      'estimatedDistance': _estimatedDistance,
      'estimatedPrice': _estimatedPrice,
    };
  }

  bool isValidBooking() {
    return canBookRide && hasValidLocations;
  }

  String getBookingButtonText() {
    if (_isBookingRide) {
      return 'Booking...';
    }
    
    if (_selectedVehicle != null) {
      if (_scheduleType == 'now') {
        return 'Book ${_selectedVehicle!.name}';
      } else {
        return 'Schedule ${_selectedVehicle!.name}';
      }
    }
    
    return 'Select a Vehicle';
  }

  // Reset methods
  void reset() {
    _pickupAddress = '';
    _destinationAddress = '';
    _pickupLat = null;
    _pickupLng = null;
    _destLat = null;
    _destLng = null;
    _selectedVehicle = null;
    _selectedPaymentMethod = 'cash';
    _scheduleType = 'now';
    _scheduledDateTime = null;
    _isLoadingRoute = false;
    _isBookingRide = false;
    _estimatedDuration = null;
    _estimatedDistance = null;
    _estimatedPrice = null;
    notifyListeners();
  }

  void resetSelections() {
    _selectedVehicle = null;
    _selectedPaymentMethod = 'cash';
    _scheduleType = 'now';
    _scheduledDateTime = null;
    _estimatedPrice = null;
    notifyListeners();
  }

  // Validation methods
  String? validateBooking() {
    if (_pickupAddress.isEmpty) {
      return 'Please select pickup location';
    }
    
    if (_destinationAddress.isEmpty) {
      return 'Please select destination';
    }
    
    if (_selectedVehicle == null) {
      return 'Please select a vehicle';
    }
    
    if (!hasValidLocations) {
      return 'Invalid location coordinates';
    }
    
    return null; // No validation errors
  }

  // Development/Debug methods
  void debugPrintState() {
    print('=== RideBookingProvider State ===');
    print('Pickup: $_pickupAddress ($_pickupLat, $_pickupLng)');
    print('Destination: $_destinationAddress ($_destLat, $_destLng)');
    print('Selected Vehicle: ${_selectedVehicle?.name ?? 'None'}');
    print('Payment Method: $_selectedPaymentMethod');
    print('Schedule Type: $_scheduleType');
    print('Can Book: $canBookRide');
    print('Is Booking: $_isBookingRide');
    print('=================================');
  }
}

// Extension for VehicleOption to convert to Map
extension VehicleOptionExtension on VehicleOption {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'estimatedTime': estimatedTime,
      'capacity': capacity,
      'features': features,
    };
  }
}