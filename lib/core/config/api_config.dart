class ApiConfig {
  // Base URLs - Update this IP address to your backend server's IP
  // IMPORTANT: Replace 'YOUR_BACKEND_IP' with the actual IP address of your backend device
  // Example: 'http://192.168.1.100:8081/user-service/api/v1'
  static const String baseUrl = 'http://192.168.2.69:8081/user-service/api/v1';
  static const String authBaseUrl = '$baseUrl/auth';
  static const String ridersBaseUrl = '$baseUrl/riders';
  
  // Timeout configurations (increased for network latency)
  static const Duration connectTimeout = Duration(seconds: 45);
  static const Duration receiveTimeout = Duration(seconds: 90);
  static const Duration sendTimeout = Duration(seconds: 45);

  // Authentication Endpoints
  static const String riderRegister = '$ridersBaseUrl/register';
  static const String riderLogin = '$ridersBaseUrl/login';
  static const String refreshToken = '$authBaseUrl/refresh';
  static const String logout = '$authBaseUrl/logout';

  // Rider Profile Endpoints
  static String getRiderProfile(String riderId) => '$ridersBaseUrl/$riderId';
  static String updateRiderProfile(String riderId) => '$ridersBaseUrl/$riderId/profile';
  static String uploadProfilePhoto(String riderId) => '$ridersBaseUrl/$riderId/profile-photo';

  // Gender Detection & Women-Only Access
  static String genderDetection(String riderId) => '$ridersBaseUrl/$riderId/gender-detection';
  static String skipGenderDetection(String riderId) => '$ridersBaseUrl/$riderId/skip-gender-detection';
  static String womenOnlyStatus(String riderId) => '$ridersBaseUrl/$riderId/women-only-status';

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
}

// Rider-specific endpoints class
class RiderEndpoints {
  // Registration & Authentication
  static const String register = ApiConfig.riderRegister;
  static const String login = ApiConfig.riderLogin;
  
  // Profile Management
  static String profile(String riderId) => ApiConfig.getRiderProfile(riderId);
  static String updateProfile(String riderId) => ApiConfig.updateRiderProfile(riderId);
  static String profilePhoto(String riderId) => ApiConfig.uploadProfilePhoto(riderId);
  
  // Gender Detection & Women-Only Features
  static String genderDetection(String riderId) => ApiConfig.genderDetection(riderId);
  static String skipGender(String riderId) => ApiConfig.skipGenderDetection(riderId);
  static String womenOnlyAccess(String riderId) => ApiConfig.womenOnlyStatus(riderId);
}

// Rider profile completion steps
class RiderProfileSteps {
  static const List<String> onboardingSteps = [
    'basic_info',
    'emergency_contact',
    'gender_detection', // Optional
    'payment_method',
  ];
  
  static const Map<String, String> stepTitles = {
    'basic_info': 'Complete Your Profile',
    'emergency_contact': 'Emergency Contact',
    'gender_detection': 'Gender Verification (Optional)',
    'payment_method': 'Payment Method',
  };
  
  static const Map<String, String> stepDescriptions = {
    'basic_info': 'Add your personal details',
    'emergency_contact': 'Add emergency contact for safety',
    'gender_detection': 'Enable women-only rides feature',
    'payment_method': 'Set your preferred payment method',
  };
}
