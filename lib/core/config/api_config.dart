class ApiConfig {
  // Base URLs - Update this IP address to your backend server's IP
  // IMPORTANT: Replace 'YOUR_BACKEND_IP' with the actual IP address of your backend device
  // Example: 'http://192.168.1.100:8081/user-service/api/v1'
  static const String baseIP = 'http://10.138.196.69';

  static const String userServiceBaseUrl = '$baseIP:8081/user-service/api/v1';
  static const String rideServiceBaseUrl = '$baseIP:8082/ride-service/api/v1';

  static const String rideServiceSocketUrl = '$baseIP:8082/ride-service';

  static const String pricingServiceBaseUrl = '$baseIP:8084/pricing-service/api';

  static const String pricingBaseUrl = '$pricingServiceBaseUrl/pricing';
  // User Service URLs
  static const String authBaseUrl = '$userServiceBaseUrl/auth';
  static const String ridersBaseUrl = '$userServiceBaseUrl/riders';
  static const String driversBaseUrl = '$userServiceBaseUrl/drivers';

  // Timeout configurations (increased for network latency)
  static const Duration connectTimeout = Duration(seconds: 45);
  static const Duration receiveTimeout = Duration(seconds: 90);
  static const Duration sendTimeout = Duration(seconds: 45);

  // =================== USER SERVICE ENDPOINTS ===================

  // Authentication Endpoints
  static const String riderRegister = '$ridersBaseUrl/register';
  static const String riderLogin = '$ridersBaseUrl/login';
  static const String driverRegister = '$driversBaseUrl/register';
  static const String driverLogin = '$driversBaseUrl/login';
  static const String refreshToken = '$authBaseUrl/refresh';
  static const String logout = '$authBaseUrl/logout';

  // Rider Profile Endpoints
  static String completeRiderProfile(String riderId) =>
      '$ridersBaseUrl/$riderId/complete-profile';
  static String getRiderProfile(String riderId) => '$ridersBaseUrl/$riderId';
  static String updateRiderProfile(String riderId) =>
      '$ridersBaseUrl/$riderId/profile';
  static String uploadRiderProfilePhoto(String riderId) =>
      '$ridersBaseUrl/$riderId/profile-photo';

  // Driver Profile Endpoints
  static String completeDriverProfile(String driverId) =>
      '$driversBaseUrl/$driverId/complete-profile';
  static String getDriverProfile(String driverId) =>
      '$driversBaseUrl/$driverId';
  static String updateDriverProfile(String driverId) =>
      '$driversBaseUrl/$driverId/profile';
  static String uploadDriverProfilePhoto(String driverId) =>
      '$driversBaseUrl/$driverId/profile-photo';

  // Driver Document Management
  static String uploadDriverDocuments(String driverId) =>
      '$driversBaseUrl/$driverId/documents';
  static String getDriverDocuments(String driverId) =>
      '$driversBaseUrl/$driverId/documents';
  static String getDocumentStatus(String driverId) =>
      '$driversBaseUrl/$driverId/documents/status';

  // Driver Vehicle Management
  static String registerVehicle(String driverId) =>
      '$driversBaseUrl/$driverId/vehicles';
  static String getDriverVehicles(String driverId) =>
      '$driversBaseUrl/$driverId/vehicles';
  static String updateVehicle(String driverId, String vehicleId) =>
      '$driversBaseUrl/$driverId/vehicles/$vehicleId';
  static String deleteVehicle(String driverId, String vehicleId) =>
      '$driversBaseUrl/$driverId/vehicles/$vehicleId';
  static String setPrimaryVehicle(String driverId, String vehicleId) =>
      '$driversBaseUrl/$driverId/vehicles/$vehicleId/set-primary';
  static String updateVehicleType(String driverId, String vehicleId) =>
      '$driversBaseUrl/$driverId/vehicles/$vehicleId/vehicle-type';
  static String updatePrimaryVehicleType(String driverId) =>
      '$driversBaseUrl/$driverId/primary-vehicle/vehicle-type';

  // Gender Detection & Women-Only Access (Both Riders & Drivers)
  static String riderGenderDetection(String riderId) =>
      '$ridersBaseUrl/$riderId/gender-detection';
  static String skipRiderGenderDetection(String riderId) =>
      '$ridersBaseUrl/$riderId/skip-gender-detection';
  static String riderWomenOnlyStatus(String riderId) =>
      '$ridersBaseUrl/$riderId/women-only-status';

  static String driverGenderDetection(String driverId) =>
      '$driversBaseUrl/$driverId/gender-detection';
  static String skipDriverGenderDetection(String driverId) =>
      '$driversBaseUrl/$driverId/skip-gender-detection';
  static String driverWomenOnlyStatus(String driverId) =>
      '$driversBaseUrl/$driverId/women-only-status';

  // =================== RIDE SERVICE ENDPOINTS ===================

  // Ride Management
  static const String requestRide = '$rideServiceBaseUrl/rides/request';
  static String acceptRide(String rideId) =>
      '$rideServiceBaseUrl/rides/$rideId/accept';
  static String startRide(String rideId) =>
      '$rideServiceBaseUrl/rides/$rideId/start';
  static String completeRide(String rideId) =>
      '$rideServiceBaseUrl/rides/$rideId/complete';
  static String cancelRide(String rideId) =>
      '$rideServiceBaseUrl/rides/$rideId/cancel';
  static String rateRide(String rideId) =>
      '$rideServiceBaseUrl/rides/$rideId/rate';
  static String getRide(String rideId) => '$rideServiceBaseUrl/rides/$rideId';
  static String updateRideLocation(String rideId) =>
      '$rideServiceBaseUrl/rides/$rideId/location';

  // Ride History & Status
  static String getUserRides(String userId) =>
      '$rideServiceBaseUrl/rides/user/$userId';
  static String getDriverRides(String driverId) =>
      '$rideServiceBaseUrl/rides/driver/$driverId';
  static String getActiveRides(String userId) =>
      '$rideServiceBaseUrl/rides/active/$userId';

  // Driver Location & Availability
  static String updateDriverLocation(String driverId) =>
      '$rideServiceBaseUrl/drivers/$driverId/location';
  static String updateDriverAvailability(String driverId) =>
      '$rideServiceBaseUrl/drivers/$driverId/availability';
  static String getDriverLocation(String driverId) =>
      '$rideServiceBaseUrl/drivers/$driverId/location';
  static const String getNearbyDrivers = '$rideServiceBaseUrl/drivers/nearby';
  static String removeDriverLocation(String driverId) =>
      '$rideServiceBaseUrl/drivers/$driverId/location';
  static String driverHeartbeat(String driverId) =>
      '$rideServiceBaseUrl/drivers/$driverId/heartbeat';

  // Ride Tracking
  static String addTrackingData = '$rideServiceBaseUrl/tracking/add';
  static String getRideTracking(String rideId) =>
      '$rideServiceBaseUrl/tracking/ride/$rideId';
  static String getLatestRideTracking(String rideId) =>
      '$rideServiceBaseUrl/tracking/ride/$rideId/latest';
  static String getDriverTracking(String driverId) =>
      '$rideServiceBaseUrl/tracking/driver/$driverId';

  // Fare Calculation
  static const String estimateFare = '$rideServiceBaseUrl/rides/fare/estimate';

  // Ride Preferences
  static const String ridePreferences = '$rideServiceBaseUrl/preferences';
  static String getRiderPreferences(String riderId) =>
      '$rideServiceBaseUrl/preferences/rider/$riderId';
  static String deleteRiderPreferences(String riderId) =>
      '$rideServiceBaseUrl/preferences/rider/$riderId';

  // =================== PRICING SERVICE ENDPOINTS ===================
  // Mirrors PricingController mappings under /api/pricing
  // Calculate price (supports both POST with body and GET with query params)
  static const String pricingCalculate = '$pricingBaseUrl/calculate';
  // Get all vehicle pricing entries
  static const String pricingAll = '$pricingBaseUrl/all';
  // Get pricing for a vehicle type
  static String getPricingByVehicle(String vehicleType) =>
      '$pricingBaseUrl/vehicle/$vehicleType';
  // Update pricing for a vehicle type (PUT)
  static String updateVehiclePricing(String vehicleType) =>
      '$pricingBaseUrl/vehicle/$vehicleType';

  // Convenience endpoints for specific vehicle types used in the UI/business logic
  // Note: OTHER vehicle type is intentionally ignored per requirements
  static const String pricingVehicleTuk = '$pricingBaseUrl/vehicle/TUK';
  static const String pricingVehicleRide = '$pricingBaseUrl/vehicle/RIDE';
  static const String pricingVehiclePrimeRide =
      '$pricingBaseUrl/vehicle/PRIME_RIDE';
  static const String pricingVehicleRush = '$pricingBaseUrl/vehicle/RUSH';
  static const String pricingVehicleSquad = '$pricingBaseUrl/vehicle/SQUAD';

  // Payment Management
  static const String createPayment = '$rideServiceBaseUrl/payments/create';
  static String processPayment(String paymentId) =>
      '$rideServiceBaseUrl/payments/$paymentId/process';
  static String getPayment(String paymentId) =>
      '$rideServiceBaseUrl/payments/$paymentId';
  static String getPaymentByRide(String rideId) =>
      '$rideServiceBaseUrl/payments/ride/$rideId';
  static String getRiderPayments(String riderId) =>
      '$rideServiceBaseUrl/payments/rider/$riderId';
  static String getDriverPayments(String driverId) =>
      '$rideServiceBaseUrl/payments/driver/$driverId';
  static String getDriverEarnings(String driverId) =>
      '$rideServiceBaseUrl/payments/driver/$driverId/earnings';
  static String getRiderSpending(String riderId) =>
      '$rideServiceBaseUrl/payments/rider/$riderId/spending';

  // PubSub Ride System (Real-time)
  static const String publishRideRequest =
      '$rideServiceBaseUrl/pubsub/ride-requests';
  static String cancelRideRequest(String requestId) =>
      '$rideServiceBaseUrl/pubsub/ride-requests/$requestId/cancel';
  static const String requestSharedRide =
      '$rideServiceBaseUrl/pubsub/shared-rides';
  static String subscribeDriver(String driverId) =>
      '$rideServiceBaseUrl/pubsub/drivers/$driverId/subscribe';
  static String unsubscribeDriver(String driverId) =>
      '$rideServiceBaseUrl/pubsub/drivers/$driverId/unsubscribe';
  static String updatePubSubDriverLocation(String driverId) =>
      '$rideServiceBaseUrl/pubsub/drivers/$driverId/location';
  static String acceptRideRequest(String requestId) =>
      '$rideServiceBaseUrl/pubsub/ride-requests/$requestId/accept';
  static String rejectRideRequest(String requestId) =>
      '$rideServiceBaseUrl/pubsub/ride-requests/$requestId/reject';
  static const String pubSubStatistics =
      '$rideServiceBaseUrl/pubsub/statistics';
  static const String findNearbyDriversPubSub =
      '$rideServiceBaseUrl/pubsub/nearby-drivers';

  // WebSocket Endpoints
  static const String webSocketRideTracking =
      'ws://10.89.163.103:8082/ws/ride-tracking';
  static const String webSocketDriverLocation =
      'ws://10.89.163.103:8082/ws/driver-location';

  // Health Check Endpoints
  static const String rideServiceHealth = '$rideServiceBaseUrl/rides/health';
  static const String userServiceHealth = '$userServiceBaseUrl/health';

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> getAuthHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
  };

  static Map<String, String> getMultipartAuthHeaders(String token) => {
    ...multipartHeaders,
    'Authorization': 'Bearer $token',
  };

  // Driver specific headers (includes User-ID for driver operations)
  static Map<String, String> getDriverHeaders(String token, String driverId) =>
      {...getAuthHeaders(token), 'User-ID': driverId};
}

// Rider-specific endpoints class
class RiderEndpoints {
  // Registration & Authentication
  static const String register = ApiConfig.riderRegister;
  static const String login = ApiConfig.riderLogin;

  // Profile Management
  static String profile(String riderId) => ApiConfig.getRiderProfile(riderId);
  static String updateProfile(String riderId) =>
      ApiConfig.updateRiderProfile(riderId);
  static String profilePhoto(String riderId) =>
      ApiConfig.uploadRiderProfilePhoto(riderId);
  static String completeProfile(String riderId) =>
      ApiConfig.completeRiderProfile(riderId);

  // Gender Detection & Women-Only Features
  static String genderDetection(String riderId) =>
      ApiConfig.riderGenderDetection(riderId);
  static String skipGender(String riderId) =>
      ApiConfig.skipRiderGenderDetection(riderId);
  static String womenOnlyAccess(String riderId) =>
      ApiConfig.riderWomenOnlyStatus(riderId);

  // Ride Management
  static const String requestRide = ApiConfig.requestRide;
  static String cancelRide(String rideId) => ApiConfig.cancelRide(rideId);
  static String rateRide(String rideId) => ApiConfig.rateRide(rideId);
  static String getRide(String rideId) => ApiConfig.getRide(rideId);

  // Ride History
  static String rideHistory(String riderId) => ApiConfig.getUserRides(riderId);
  static String activeRides(String riderId) =>
      ApiConfig.getActiveRides(riderId);

  // Ride Preferences
  static const String preferences = ApiConfig.ridePreferences;
  static String getPreferences(String riderId) =>
      ApiConfig.getRiderPreferences(riderId);

  // Payments
  static String payments(String riderId) => ApiConfig.getRiderPayments(riderId);
  static String spending(String riderId) => ApiConfig.getRiderSpending(riderId);
}

// Driver-specific endpoints class
class DriverEndpoints {
  // Registration & Authentication
  static const String register = ApiConfig.driverRegister;
  static const String login = ApiConfig.driverLogin;

  // Profile Management
  static String profile(String driverId) =>
      ApiConfig.getDriverProfile(driverId);
  static String updateProfile(String driverId) =>
      ApiConfig.updateDriverProfile(driverId);
  static String profilePhoto(String driverId) =>
      ApiConfig.uploadDriverProfilePhoto(driverId);
  static String completeProfile(String driverId) =>
      ApiConfig.completeDriverProfile(driverId);

  // Document Management
  static String uploadDocuments(String driverId) =>
      ApiConfig.uploadDriverDocuments(driverId);
  static String getDocuments(String driverId) =>
      ApiConfig.getDriverDocuments(driverId);
  static String documentStatus(String driverId) =>
      ApiConfig.getDocumentStatus(driverId);

  // Vehicle Management
  static String registerVehicle(String driverId) =>
      ApiConfig.registerVehicle(driverId);
  static String getVehicles(String driverId) =>
      ApiConfig.getDriverVehicles(driverId);
  static String updateVehicle(String driverId, String vehicleId) =>
      ApiConfig.updateVehicle(driverId, vehicleId);
  static String deleteVehicle(String driverId, String vehicleId) =>
      ApiConfig.deleteVehicle(driverId, vehicleId);
  static String setPrimaryVehicle(String driverId, String vehicleId) =>
      ApiConfig.setPrimaryVehicle(driverId, vehicleId);
  static String updateVehicleType(String driverId, String vehicleId) =>
      ApiConfig.updateVehicleType(driverId, vehicleId);
  static String updatePrimaryVehicleType(String driverId) =>
      ApiConfig.updatePrimaryVehicleType(driverId);

  // Gender Detection & Women-Only Features
  static String genderDetection(String driverId) =>
      ApiConfig.driverGenderDetection(driverId);
  static String skipGender(String driverId) =>
      ApiConfig.skipDriverGenderDetection(driverId);
  static String womenOnlyAccess(String driverId) =>
      ApiConfig.driverWomenOnlyStatus(driverId);

  // Ride Management
  static String acceptRide(String rideId) => ApiConfig.acceptRide(rideId);
  static String startRide(String rideId) => ApiConfig.startRide(rideId);
  static String completeRide(String rideId) => ApiConfig.completeRide(rideId);
  static String cancelRide(String rideId) => ApiConfig.cancelRide(rideId);
  static String rateRide(String rideId) => ApiConfig.rateRide(rideId);

  // Location & Availability
  static String updateLocation(String driverId) =>
      ApiConfig.updateDriverLocation(driverId);
  static String updateAvailability(String driverId) =>
      ApiConfig.updateDriverAvailability(driverId);
  static String getLocation(String driverId) =>
      ApiConfig.getDriverLocation(driverId);
  static String removeLocation(String driverId) =>
      ApiConfig.removeDriverLocation(driverId);
  static String heartbeat(String driverId) =>
      ApiConfig.driverHeartbeat(driverId);

  // Ride History
  static String rideHistory(String driverId) =>
      ApiConfig.getDriverRides(driverId);
  static String activeRides(String driverId) =>
      ApiConfig.getActiveRides(driverId);

  // Earnings & Payments
  static String payments(String driverId) =>
      ApiConfig.getDriverPayments(driverId);
  static String earnings(String driverId) =>
      ApiConfig.getDriverEarnings(driverId);

  // PubSub System
  static String subscribe(String driverId) =>
      ApiConfig.subscribeDriver(driverId);
  static String unsubscribe(String driverId) =>
      ApiConfig.unsubscribeDriver(driverId);
  static String pubSubLocation(String driverId) =>
      ApiConfig.updatePubSubDriverLocation(driverId);
  static String acceptRideRequest(String requestId) =>
      ApiConfig.acceptRideRequest(requestId);
  static String rejectRideRequest(String requestId) =>
      ApiConfig.rejectRideRequest(requestId);
}

// Common ride endpoints (used by both riders and drivers)
class RideEndpoints {
  // Fare Calculation
  static const String estimateFare = ApiConfig.estimateFare;

  // Nearby Drivers
  static const String nearbyDrivers = ApiConfig.getNearbyDrivers;

  // Ride Tracking
  static String addTracking = ApiConfig.addTrackingData;
  static String getRideTracking(String rideId) =>
      ApiConfig.getRideTracking(rideId);
  static String getLatestTracking(String rideId) =>
      ApiConfig.getLatestRideTracking(rideId);

  // WebSocket Connections
  static const String wsRideTracking = ApiConfig.webSocketRideTracking;
  static const String wsDriverLocation = ApiConfig.webSocketDriverLocation;
}

// Profile completion steps for different user types
class RiderProfileSteps {
  static const List<String> onboardingSteps = [
    'basic_info',
    'emergency_contact',
    'gender_detection', // Optional
    'payment_method',
    'ride_preferences',
  ];

  static const Map<String, String> stepTitles = {
    'basic_info': 'Complete Your Profile',
    'emergency_contact': 'Emergency Contact',
    'gender_detection': 'Gender Verification (Optional)',
    'payment_method': 'Payment Method',
    'ride_preferences': 'Ride Preferences',
  };

  static const Map<String, String> stepDescriptions = {
    'basic_info': 'Add your personal details',
    'emergency_contact': 'Add emergency contact for safety',
    'gender_detection': 'Enable women-only rides feature',
    'payment_method': 'Set your preferred payment method',
    'ride_preferences': 'Set your ride preferences',
  };
}

class DriverProfileSteps {
  static const List<String> onboardingSteps = [
    'basic_info',
    'emergency_contact',
    'vehicle_registration',
    'document_upload',
    'gender_detection', // Optional
    'banking_details',
  ];

  static const Map<String, String> stepTitles = {
    'basic_info': 'Complete Your Profile',
    'emergency_contact': 'Emergency Contact',
    'vehicle_registration': 'Vehicle Registration',
    'document_upload': 'Upload Documents',
    'gender_detection': 'Gender Verification (Optional)',
    'banking_details': 'Banking Details',
  };

  static const Map<String, String> stepDescriptions = {
    'basic_info': 'Add your personal details',
    'emergency_contact': 'Add emergency contact for safety',
    'vehicle_registration': 'Register your vehicle',
    'document_upload': 'Upload required documents',
    'gender_detection': 'Enable women-only rides feature',
    'banking_details': 'Add banking details for payments',
  };
}

// Vehicle Types (matching backend enum)
class VehicleTypes {
  static const String bike = 'BIKE';
  static const String threeWheeler = 'THREE_WHEELER';
  static const String car = 'CAR';
  static const String van = 'VAN';

  static const List<String> all = [bike, threeWheeler, car, van];

  static const Map<String, String> displayNames = {
    bike: 'Motorcycle/Bike',
    threeWheeler: 'Three Wheeler',
    car: 'Car',
    van: 'Van',
  };
}

// Ride Status (matching backend enum)
class RideStatus {
  static const String pending = 'PENDING';
  static const String accepted = 'ACCEPTED';
  static const String driverArrived = 'DRIVER_ARRIVED';
  static const String inProgress = 'IN_PROGRESS';
  static const String completed = 'COMPLETED';
  static const String cancelledByRider = 'CANCELLED_BY_RIDER';
  static const String cancelledByDriver = 'CANCELLED_BY_DRIVER';
  static const String cancelledBySystem = 'CANCELLED_BY_SYSTEM';
}

// Payment Methods (matching backend enum)
class PaymentMethods {
  static const String cash = 'CASH';
  static const String card = 'CARD';
  static const String digitalWallet = 'DIGITAL_WALLET';

  static const List<String> all = [cash, card, digitalWallet];

  static const Map<String, String> displayNames = {
    cash: 'Cash',
    card: 'Credit/Debit Card',
    digitalWallet: 'Digital Wallet',
  };
}
