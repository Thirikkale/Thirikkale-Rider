
import 'package:flutter/material.dart';
import 'package:thirikkale_rider/features/booking/models/vehicle_option.dart';

class RideBookingProvider extends ChangeNotifier {
  // Expose default vehicle options for UI
  List<VehicleOption> get vehicleOptions => VehicleOption.getDefaultOptions();
  // For backward compatibility with UI code
  VehicleOption? get selectedVehicle => _vehicleType;
  // Trip details
  String _rideId = '';
  String _pickupAddress = '';
  String _destinationAddress = '';
  double? _pickupLat;
  double? _pickupLng;
  double? _destLat;
  double? _destLng;
  DateTime? _estimatedPickupTime;
  DateTime? _actualPickupTime;
  DateTime? _estimatedDropoffTime;
  DateTime? _actualDropoffTime;
  double? _estimatedPrice; // estimated fare
  double? _actualPrice; // actual fare
  double? _estimatedDuration;
  double? _actualDuration;
  double? _estimatedDistance;
  double? _actualDistance;

   // Default ride type
  bool _isSolo = true;
  bool _isRideScheduled = false;
  bool _isWomenOnly = false;
  bool _isShared= false;

  // for scheduled rides (_isRideScheduled = true)
  DateTime? _scheduledDateTime;

  //cancellation details
  DateTime? _cancellationTime;
  String? _cancellationReason;

  // for shared rides
  int? _participantCount = 1;
  double? _individualShare = 100.00;
  final DateTime? _joinedAt = DateTime.now();

  // Selected options
  VehicleOption? _vehicleType; // vehicle type, (Tuk, Ride, Rush, Prime, Squad)
  String _selectedPaymentMethod = 'cash';

  // payment details
  String? _paymentId;

  // Available options
  // final List<VehicleOption> _vehicleOptions = VehicleOption.getDefaultOptions();

  // Loading states
  bool _isLoadingRoute = false;
  bool _isBookingRide = false;
  bool _isSettingTrip = false;

  // Trip information
 
  // final List<VehicleOption> _vehicleOptions = [
  //   VehicleOption(
  //     id: 'tuk',
  //     name: 'Tuk',
  //     description: 'Affordable auto rickshaw ride',
  //     price: 30.0,
  //     estimatedTime: '10-15 min',
  //     capacity: 3,
  //     features: ['Open air', 'Economical'],
  //     iconAsset: 'assets/icons/tuk.png',
  //   ),
  //   VehicleOption(
  //     id: 'ride',
  //     name: 'Ride',
  //     description: 'Standard car ride',
  //     price: 50.0,
  //     estimatedTime: '8-12 min',
  //     capacity: 4,
  //     features: ['AC', 'Comfortable'],
  //     iconAsset: 'assets/icons/ride.png',
  //   ),
  //   VehicleOption(
  //     id: 'rush',
  //     name: 'Rush',
  //     description: 'Fast and premium ride',
  //     price: 80.0,
  //     estimatedTime: '5-8 min',
  //     capacity: 4,
  //     features: ['Priority', 'Premium'],
  //     iconAsset: 'assets/icons/rush.png',
  //   ),
  //   VehicleOption(
  //     id: 'prime',
  //     name: 'Prime',
  //     description: 'Luxury car ride',
  //     price: 120.0,
  //     estimatedTime: '5-10 min',
  //     capacity: 4,
  //     features: ['Luxury', 'Spacious'],
  //     iconAsset: 'assets/icons/prime.png',
  //   ),
  //   VehicleOption(
  //     id: 'squad',
  //     name: 'Squad',
  //     description: 'Group ride for up to 6',
  //     price: 150.0,
  //     estimatedTime: '12-18 min',
  //     capacity: 6,
  //     features: ['Group', 'Spacious'],
  //     iconAsset: 'assets/icons/squad.png',
  //   ),
  // ];
  
  // Promotion information
  bool _hasPromotion = false;
  String? _promotionText;
  double _promotionDiscountPercentage = 0.0;
  // Promotion getters
  bool get hasPromotion => _hasPromotion;
  String? get promotionText => _promotionText;
  double get promotionDiscountPercentage => _promotionDiscountPercentage;

  // (removed duplicate _sharedRideId)

  // Getters
  String get rideId => _rideId;
  String get pickupAddress => _pickupAddress;
  String get destinationAddress => _destinationAddress;
  double? get pickupLat => _pickupLat;
  double? get pickupLng => _pickupLng;
  double? get destLat => _destLat;
  double? get destLng => _destLng;
  DateTime? get estimatedPickupTime => _estimatedPickupTime;
  DateTime? get actualPickupTime => _actualPickupTime;
  DateTime? get estimatedDropoffTime => _estimatedDropoffTime;
  DateTime? get actualDropoffTime => _actualDropoffTime;
  double? get estimatedPrice => _estimatedPrice;
  double? get actualPrice => _actualPrice;
  double? get estimatedDuration => _estimatedDuration;
  double? get actualDuration => _actualDuration;
  double? get estimatedDistance => _estimatedDistance;
  double? get actualDistance => _actualDistance;
  VehicleOption? get vehicleType => _vehicleType;
  bool get isSolo => _isSolo;
  bool get isRideScheduled => _isRideScheduled;
  bool get isWomenOnly => _isWomenOnly;
  bool get isShared => _isShared;
  DateTime? get scheduledDateTime => _scheduledDateTime;
  DateTime? get cancellationTime => _cancellationTime;
  String? get cancellationReason => _cancellationReason;
  int get participantCount => _participantCount ?? 1;
  double get individualShare => _individualShare ?? 100.00;
  DateTime get joinedAt => _joinedAt ?? DateTime.now();
  String get selectedPaymentMethod => _selectedPaymentMethod;
  String? get paymentId => _paymentId;
  bool get isLoadingRoute => _isLoadingRoute;
  bool get isBookingRide => _isBookingRide;
  bool get isSettingTrip => _isSettingTrip;
  // Setters
  set rideId(String value) {
    _rideId = value;
    notifyListeners();
  }
  set pickupAddress(String value) {
    _pickupAddress = value;
    notifyListeners();
  }
  set destinationAddress(String value) {
    _destinationAddress = value;
    notifyListeners();
  }
  set pickupLat(double? value) {
    _pickupLat = value;
    notifyListeners();
  }
  set pickupLng(double? value) {
    _pickupLng = value;
    notifyListeners();
  }
  set destLat(double? value) {
    _destLat = value;
    notifyListeners();
  }
  set destLng(double? value) {
    _destLng = value;
    notifyListeners();
  }
  set estimatedPickupTime(DateTime? value) {
    _estimatedPickupTime = value;
    notifyListeners();
  }
  set actualPickupTime(DateTime? value) {
    _actualPickupTime = value;
    notifyListeners();
  }
  set estimatedDropoffTime(DateTime? value) {
    _estimatedDropoffTime = value;
    notifyListeners();
  }
  set actualDropoffTime(DateTime? value) {
    _actualDropoffTime = value;
    notifyListeners();
  }
  set estimatedPrice(double? value) {
    _estimatedPrice = value;
    notifyListeners();
  }
  set actualPrice(double? value) {
    _actualPrice = value;
    notifyListeners();
  }
  set estimatedDuration(double? value) {
    _estimatedDuration = value;
    notifyListeners();
  }
  set actualDuration(double? value) {
    _actualDuration = value;
    notifyListeners();
  }
  set estimatedDistance(double? value) {
    _estimatedDistance = value;
    notifyListeners();
  }
  set actualDistance(double? value) {
    _actualDistance = value;
    notifyListeners();
  }
  // set vehicleType removed; use setSelectVehicle instead
  set isRideScheduled(bool value) {
    _isRideScheduled = value;
    notifyListeners();
  }
  set isWomenOnly(bool value) {
    _isWomenOnly = value;
    notifyListeners();
  }
  set isShared(bool value) {
    _isShared = value;
    notifyListeners();
  }
  set cancellationTime(DateTime? value) {
    _cancellationTime = value;
    notifyListeners();
  }
  set cancellationReason(String? value) {
    _cancellationReason = value;
    notifyListeners();
  }
  set participantCount(int value) {
    _participantCount = value;
    notifyListeners();
  }
  set individualShare(double value) {
    _individualShare = value;
    notifyListeners();
  }
  set vehicleType(VehicleOption? value) {
    _vehicleType = value;
    notifyListeners();
  }
  set selectedPaymentMethod(String value) {
    _selectedPaymentMethod = value;
    notifyListeners();
  }
  set paymentId(String? value) {
    _paymentId = value;
    notifyListeners();
  }
  set isLoadingRoute(bool value) {
    _isLoadingRoute = value;
    notifyListeners();
  }
  set isBookingRide(bool value) {
    _isBookingRide = value;
    notifyListeners();
  }
  set isSettingTrip(bool value) {
    _isSettingTrip = value;
    notifyListeners();
  }

  bool get canBookRide => // Computed properties
      _vehicleType != null &&
      _pickupAddress.isNotEmpty &&
      _destinationAddress.isNotEmpty;

  bool get hasValidLocations =>
      _pickupLat != null &&
      _pickupLng != null &&
      _destLat != null &&
      _destLng != null;

  // Methods
  // Setting trip ride details
  Future<void> setTripDetails({
    required String pickup,
    required String destination,
    double? pickupLat,
    double? pickupLng,
    double? destLat,
    double? destLng,
    bool preserveVehicleSelection = true,
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
      _vehicleType = null;
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
    // Parse and update estimated duration
    if (duration != null && duration.isNotEmpty) {
      final parsedDuration = double.tryParse(duration);
      if (parsedDuration != null && parsedDuration > 0) {
        _estimatedDuration = parsedDuration;
      } else {
        _estimatedDuration = null;
      }
    } else {
      _estimatedDuration = null;
    }

    // Parse and update estimated distance
    if (distance != null && distance.isNotEmpty) {
      final parsedDistance = double.tryParse(distance);
      if (parsedDistance != null && parsedDistance > 0) {
        _estimatedDistance = parsedDistance;
        _updateVehiclePrice(distance: _estimatedDistance!, isActual: false);
      } else {
        _estimatedDistance = null;
        _estimatedPrice = null;
      }
    } else {
      _estimatedDistance = null;
      _estimatedPrice = null;
    }

    notifyListeners();
  }

  void setSelectVehicle(VehicleOption vehicle) {
    _vehicleType = vehicle;
    _estimatedPrice = vehicle.defaultPricePerUnit;
    _isSolo = true;
    _isRideScheduled = false;
    _isWomenOnly = false;
    _isShared= false;
    notifyListeners();
  }

  // setting if shared or solo
  void setRideType(String? rideType) {
    if (rideType == null) {
      _isSolo = true;
      return;
    }
    // Set _isSolo based on rideType
    if (rideType.toLowerCase() == 'shared') {
      _isSolo = false;
    } else {
      _isSolo = true;
    }
    notifyListeners();
    // Optionally, set vehicleType here if needed
  }

  void setPaymentMethod(String method) {
    // Only allow 'cash', 'card', or 'wallet'
    const allowedMethods = ['cash', 'card', 'wallet'];
    if (allowedMethods.contains(method.toLowerCase())) {
      _selectedPaymentMethod = method.toLowerCase();
      notifyListeners();
    } else {
      _selectedPaymentMethod = "cash"; // Default to cash if invalid method
    }
  }

  void setScheduleType(bool rideType) {
    // Set _isRideScheduled based on rideType
    _isRideScheduled = rideType;
    notifyListeners();
    // Removed: _scheduleType is not defined
  }

  void setScheduledDateTime(DateTime? dateTime) {
    _scheduledDateTime = dateTime ?? DateTime.now();
    notifyListeners();
  }

  // Promotion methods
  void setPromotion({
    required bool hasPromotion,
    String? promotionText,
    double discountPercentage = 0.0,
  }) {
    _hasPromotion = hasPromotion;
    _promotionText = promotionText;
    _promotionDiscountPercentage = discountPercentage;
    notifyListeners();
  }

  Future<void> fetchAvailablePromotions() async {
    // Promotion logic removed (fields not defined)
  }

  void setLoadingRoute(bool loading) {
    _isLoadingRoute = loading;
    notifyListeners();
  }

    // Dynamic pricing: 1st KM uses default price, rest uses FACTOR * default price per KM
  void _updateVehiclePrice({
    required double distance,
    required bool isActual,
  }) {
    const double priceFactor = 0.8;

    if (_vehicleType != null) {
      final double basePrice = _vehicleType!.defaultPricePerUnit;
      double price;
      if (distance <= 1.0) {
        price = basePrice;
      } else {
        price = basePrice + ((distance - 1.0) * basePrice * priceFactor);
      }
      if (isActual) {
        _actualPrice = price;
      } else {
        _estimatedPrice = price;
      }
    } else {
      if (isActual) {
        _actualPrice = null;
      } else {
        _estimatedPrice = null;
      }
    }
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
    print('Vehicle: ${_vehicleType?.name}');
    print('Pickup: $_pickupAddress');
    print('Destination: $_destinationAddress');
    print('Payment: $_selectedPaymentMethod');
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
      'vehicle': _vehicleType?.toMap(),
      'paymentMethod': _selectedPaymentMethod,
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
    if (_vehicleType != null) {
      return 'Book ${_vehicleType!.name}';
    }
    return 'Select a Vehicle';
  }

  // Reset methods
  void reset() {
    _rideId = '';
    _pickupAddress = '';
    _destinationAddress = '';
    _pickupLat = null;
    _pickupLng = null;
    _destLat = null;
    _destLng = null;
    _estimatedPickupTime = null;
    _actualPickupTime = null;
    _estimatedDropoffTime = null;
    _actualDropoffTime = null;
    _estimatedPrice = null;
    _actualPrice = null;
    _estimatedDuration = null;
    _actualDuration = null;
    _estimatedDistance = null;
    _actualDistance = null;
    _isSolo = true;
    _isRideScheduled = false;
    _isWomenOnly = false;
    _isShared = false;
    _scheduledDateTime = null;
    _cancellationTime = null;
    _cancellationReason = null;
    _participantCount = 1;
    _individualShare = 100.00;
    // _joinedAt is final and should not be reset
    _vehicleType = null;
    _selectedPaymentMethod = 'cash';
    _paymentId = null;
    _isLoadingRoute = false;
    _isBookingRide = false;
    _isSettingTrip = false;
    _hasPromotion = false;
    _promotionText = null;
    _promotionDiscountPercentage = 0.0;
    notifyListeners();
  }

  void resetSelections() {
    _vehicleType = null;
    _selectedPaymentMethod = 'cash';
    
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
    
    if (_vehicleType == null) {
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
    print('Selected Vehicle: ${_vehicleType?.name ?? 'None'}');
    print('Payment Method: $_selectedPaymentMethod');
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
      'defaultPricePerUnit': defaultPricePerUnit,
      'estimatedTime': estimatedTime,
      'capacity': capacity,
      'features': features,
    };
  }
}