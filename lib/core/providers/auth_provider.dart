import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirikkale_rider/core/services/auth_service.dart';
import 'package:thirikkale_rider/core/services/rider_service.dart';
import 'package:thirikkale_rider/models/user_model.dart';

enum AuthState {
  initial,
  phoneEntered,
  otpSent,
  otpVerified,
  checkingUser,
  userExists,
  userNotExists,
  registering,
  loggedIn,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final RiderService _riderService = RiderService();

  // State management
  AuthState _authState = AuthState.initial;
  bool _isLoading = false;
  String? _errorMessage;
  // ignore: unused_field
  bool _isLoggedIn = false;

  // Phone verification
  bool _isPhoneVerified = false;
  String? _verifiedPhoneNumber;
  String? _verificationId;
  String? _idToken;
  String? _firebaseUid;

  String? _accessToken;
  String? _refreshToken;
  String? _tokenType;
  DateTime? _tokenExpiresAt;

  // User data
  UserModel? _currentUser;
  String? _authToken; // Backend JWT token
  String? _userId;
  String? _firstName;
  String? _lastName;
  String? _riderId;

  String? _userType;
  String? _profilePictureUrl;

  // Getters
  AuthState get authState => _authState;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPhoneVerified => _isPhoneVerified;
  String? get verifiedPhoneNumber => _verifiedPhoneNumber;
  String? get verificationId => _verificationId;
  String? get idToken => _idToken;
  String? get firebaseUid => _firebaseUid;
  UserModel? get currentUser => _currentUser;
  String? get authToken => _authToken;
  bool get isLoggedIn =>
      _authState == AuthState.loggedIn && _currentUser != null;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  String? get userId => _userId;
  String? get riderId => _riderId;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? get userType => _userType;
  String? get profilePictureUrl => _profilePictureUrl;

  bool get hasValidJWTToken {
    if (_accessToken == null || _tokenExpiresAt == null) return false;
    return _tokenExpiresAt!.isAfter(
      DateTime.now().add(const Duration(minutes: 1)),
    );
  }

  // Get full name helper
  String get fullName {
    if (_firstName != null && _lastName != null) {
      return '$_firstName $_lastName';
    } else if (_firstName != null) {
      return _firstName!;
    }
    return 'Driver';
  }

  // Get display phone number
  String get displayPhoneNumber {
    if (_verifiedPhoneNumber != null) {
      return _verifiedPhoneNumber!;
    }
    return 'Not provided';
  }

  // Initialize AuthProvider - call this in main.dart
  Future<void> initialize() async {
    await _loadStoredTokens();

    // If we have valid tokens, try to refresh them
    if (_refreshToken != null && !hasValidJWTToken) {
      print('🔄 Attempting to refresh stored tokens...');
      await _refreshAccessToken();
    }

    notifyListeners();
  }

  // Set verified phone number
  void setVerifiedPhoneNumber(String phoneNumber) {
    _verifiedPhoneNumber = phoneNumber;
    notifyListeners();
  }

  // Set user name
  void setUserName(String firstName, String lastName) {
    _firstName = firstName;
    _lastName = lastName;
    notifyListeners();
  }

  // 1. Send OTP for phone verification
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException error) onVerificationFailed,
  }) async {
    _setLoading(true);
    _clearError();
    _authState = AuthState.phoneEntered;

    try {
      await _authService.sendOTP(
        phoneNumber: phoneNumber,
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _verifiedPhoneNumber = phoneNumber;
          _authState = AuthState.otpSent;
          _setLoading(false);
          onCodeSent(verificationId, resendToken);
        },
        verificationFailed: (error) {
          _setError(error.message ?? 'Phone verification failed');
          _authState = AuthState.error;
          _setLoading(false);
          onVerificationFailed(error);
        },
        verificationCompleted: (credential) {
          // Auto-verification completed
          _isPhoneVerified = true;
          _verifiedPhoneNumber = phoneNumber;
          _authState = AuthState.otpVerified;
          _setLoading(false);
          notifyListeners();
        },
      );
    } catch (e) {
      _setError(e.toString());
      _authState = AuthState.error;
      onVerificationFailed(
        FirebaseAuthException(code: 'unknown', message: e.toString()),
      );
      _setLoading(false);
    }
  }

  // 2. Verify OTP code and get Firebase token
  // Verify OTP code and get token
  Future<bool> verifyOTP(String verificationId, String code) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.verifyOTPAndGetToken(
        verificationId,
        code,
      );

      if (result['success'] == true) {
        // Store token information
        _idToken = result['idToken'];
        _firebaseUid = result['uid'];
        _isPhoneVerified = true;

        // If the phone number wasn't set earlier, set it now
        if (_verifiedPhoneNumber == null && result['phoneNumber'] != null) {
          _verifiedPhoneNumber = result['phoneNumber'];
        }

        // Print token for development purposes only (remove in production)
        print('Firebase ID Token: $_idToken');

        return true;
      } else {
        _setError(result['error'] ?? 'Verification failed');
        return false;
      }
    } catch (e) {
      _setError('Invalid verification code. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> completeRiderProfile({
    required String firstName,
    required String lastName,
  }) async {
    // Check if user is logged in with JWT tokens
    if (_userId == null) {
      _setError('User not logged in');
      return false;
    }

    // Get current valid JWT token
    final jwtToken = await getCurrentToken();
    if (jwtToken == null) {
      _setError('Session expired. Please login again.');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print('🚀 Starting profile completion...');
      print('🆔 User ID: $_userId');
      print('👤 Name: $firstName $lastName');
      print('🎫 Using JWT Token: ${jwtToken.substring(0, 20)}...');

      final result = await _riderService.completeRiderProfile(
        riderId: _userId!,
        firstName: firstName,
        lastName: lastName,
        jwtToken: jwtToken,
      );

      if (result['success'] == true) {
        // Update local state with the new names
        _firstName = firstName;
        _lastName = lastName;

        // Save updated information to local storage
        await _saveTokensToStorage();

        print('✅ Driver profile completed successfully');
        print('👤 Updated Name: $_firstName $_lastName');

        notifyListeners();
        return true;
      } else {
        final errorMessage = result['error'] ?? 'Profile completion failed';

        // Handle token expiry or authentication errors
        if (result['statusCode'] == 401 || result['statusCode'] == 403) {
          _setError('Session expired. Please login again.');
          // Clear JWT tokens and logout
          await logout();
        } else {
          _setError(errorMessage);
        }
        return false;
      }
    } catch (e) {
      _setError('Profile completion error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> checkUserRegistrationStatus() async {
    if (_idToken == null) {
      return {'success': false, 'error': 'No authentication token available'};
    }

    _setLoading(true);
    _clearError();

    try {
      print('🔍 Checking user registration status...');

      final result = await _riderService.registerRider(
        firebaseToken: _idToken!,
        // Don't send name/vehicle for status check
      );

      if (result['success'] == true) {
        final responseData = result['data'];
        print('Response Data: $responseData');
        await _storeJWTTokens(responseData);

        _riderId = responseData['userId'];
        _isLoggedIn = true;

        // Store user info if available
        if (responseData['firstName'] != null) {
          _firstName = responseData['firstName'];
        }
        if (responseData['lastName'] != null) {
          _lastName = responseData['lastName'];
        }
        if (responseData['phoneNumber'] != null) {
          _verifiedPhoneNumber = responseData['phoneNumber'];
        }

        print('✅ User status checked successfully');
        print('🆔 User ID: $_userId');
        print('👤 Name: $_firstName $_lastName');
        print('🔄 Is New Registration: ${result['isNewRegistration']}');
        print('🔄 Is Auto Login: ${result['isAutoLogin']}');

        return {
          'success': true,
          'isNewRegistration': result['isNewRegistration'],
          'isAutoLogin': result['isAutoLogin'],
          'hasCompleteProfile': _firstName == 'Driver' && _lastName != 'User',
          'data': responseData,
        };
      } else {
        _setError(result['error'] ?? 'Failed to check registration status');
        return result;
      }
    } catch (e) {
      _setError('Status check error: $e');
      return {'success': false, 'error': 'Status check failed: $e'};
    } finally {
      _setLoading(false);
    }
  }

  // 3. Check if user exists in backend using RiderService
  Future<bool> checkUserExists() async {
    if (_verifiedPhoneNumber == null || _idToken == null) {
      _setError('Phone verification required');
      return false;
    }

    _setLoading(true);
    _clearError();
    _authState = AuthState.checkingUser;

    try {
      print('🔍 Checking if user exists using RiderService...');
      print('🔑 Firebase Token: ${_idToken?.substring(0, 20)}...');
      print('📱 Phone: $_verifiedPhoneNumber');
      print('👤 Firebase UID: $_firebaseUid');

      // Try to login first to check if user exists
      final loginResult = await _riderService.loginRider(
        firebaseToken: _idToken!,
      );

      if (loginResult['success'] == true) {
        // User exists and logged in successfully
        final userData = loginResult['data'];
        _authToken = userData['token']; // Backend JWT token
        _currentUser = UserModel.fromJson(userData['user']);
        _authState = AuthState.loggedIn;

        print('✅ User exists and logged in successfully');
        print('👤 User data: ${userData['user']}');
        return true;
      } else {
        // Check if it's a "user not found" error (404)
        if (loginResult['statusCode'] == 404 ||
            loginResult['error']?.toString().toLowerCase().contains(
                  'not found',
                ) ==
                true) {
          // User doesn't exist, needs registration
          _authState = AuthState.userNotExists;
          print('ℹ️ User not found, registration required');
          return false;
        } else {
          // Other error during login
          _setError(loginResult['error'] ?? 'Login failed');
          _authState = AuthState.error;
          print('❌ Login error: ${loginResult['error']}');
          return false;
        }
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _authState = AuthState.error;
      print('❌ Exception during user check: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Upload profile photo
  Future<Map<String, dynamic>> uploadProfilePhoto(File imageFile) async {
    final jwtToken = await getCurrentToken();
    if (jwtToken == null) {
      return {
        'success': false,
        'error': 'Session expired. Please login again.',
      };
    }

    if (_userId == null || _userId!.isEmpty) {
      return {
        'success': false,
        'error': 'User session invalid. Please logout and login again.',
      };
    }

    try {
      print('📤 Starting profile photo upload...');
      print('🆔 User ID: $_userId');
      print('🎫 JWT Token available: ${jwtToken.length} characters');

      final result = await _riderService.uploadProfilePhoto(
        riderId: _userId!,
        imageFile: imageFile,
        jwtToken: jwtToken,
      );

      print('📤 Upload result: $result');

      // Handle different response scenarios
      if (result.containsKey('success') && result['success'] == true) {
        // Update profile picture URL if returned
        if (result['data'] != null &&
            result['data']['profilePictureUrl'] != null) {
          _profilePictureUrl = result['data']['profilePictureUrl'];
          await _saveTokensToStorage();
          notifyListeners();
          print('✅ Profile picture URL updated: $_profilePictureUrl');
        }
        return result;
      } else if (result.containsKey('error')) {
        return result;
      } else {
        // Handle unexpected response format
        return {'success': false, 'error': 'Unexpected server response format'};
      }
    } catch (e) {
      print('❌ Upload profile photo error: $e');
      return {
        'success': false,
        'error':
            e.toString().contains('FormatException')
                ? 'Server response format error - please try again'
                : 'Upload failed: $e',
      };
    }
  }

  // Upload for gender detection with improved error handling
  Future<Map<String, dynamic>> uploadGenderDetection(File imageFile) async {
    final jwtToken = await getCurrentToken();
    if (jwtToken == null) {
      return {
        'success': false,
        'error': 'Session expired. Please login again.',
      };
    }

    if (_userId == null || _userId!.isEmpty) {
      return {
        'success': false,
        'error': 'User session invalid. Please logout and login again.',
      };
    }

    try {
      print('📤 Starting gender detection upload...');
      print('🆔 User ID: $_userId');

      final result = await _riderService.uploadGenderDetection(
        riderId: _userId!,
        imageFile: imageFile,
        jwtToken: jwtToken,
      );

      print('🎯 Gender detection result: $result');

      // Handle different response scenarios
      if (result.containsKey('success')) {
        return result;
      } else {
        // Handle unexpected response format
        return {'success': false, 'error': 'Unexpected server response format'};
      }
    } catch (e) {
      print('❌ Upload gender detection error: $e');
      return {
        'success': false,
        'error':
            e.toString().contains('FormatException')
                ? 'Server response format error - please try again'
                : 'Upload failed: $e',
      };
    }
  }

  // Skip gender detection with improved error handling
  Future<Map<String, dynamic>> skipGenderDetection() async {
    final jwtToken = await getCurrentToken();
    if (jwtToken == null) {
      return {
        'success': false,
        'error': 'Session expired. Please login again.',
      };
    }

    if (_userId == null || _userId!.isEmpty) {
      return {
        'success': false,
        'error': 'User session invalid. Please logout and login again.',
      };
    }

    try {
      print('⏭️ Skipping gender detection...');
      print('🆔 User ID: $_userId');

      final result = await _riderService.skipGenderDetection(
        riderId: _userId!,
        jwtToken: jwtToken,
      );

      print('⏭️ Skip gender detection result: $result');

      // Handle different response scenarios including empty responses
      if (result.isEmpty) {
        // Empty response from server - treat as success
        print('✅ Empty response treated as success');
        return {'success': true};
      } else if (result.containsKey('success')) {
        return result;
      } else {
        // Handle unexpected response format but don't fail
        print('⚠️ Unexpected response format, treating as success');
        return {'success': true};
      }
    } catch (e) {
      print('❌ Skip gender detection error: $e');

      // For FormatException (empty response), treat as success
      if (e.toString().contains('FormatException')) {
        print('✅ FormatException treated as successful skip');
        return {'success': true};
      }

      return {'success': false, 'error': 'Skip failed: $e'};
    }
  }

  // 4. Register new user using RiderService
  Future<bool> registerUser({
    required String firstName,
    String? lastName,
    String? email,
    DateTime? dateOfBirth,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    if (_verifiedPhoneNumber == null || _idToken == null) {
      _setError('Phone verification required');
      return false;
    }

    _setLoading(true);
    _clearError();
    _authState = AuthState.registering;

    try {
      print('🔍 Registering new user using RiderService...');
      print('🔑 Firebase Token: ${_idToken?.substring(0, 20)}...');
      print('📱 Phone: $_verifiedPhoneNumber');
      print('👤 Registration data:');
      print('   - firstName: $firstName');
      print('   - lastName: $lastName');
      print('   - email: $email');
      print('   - dateOfBirth: ${dateOfBirth?.toIso8601String()}');
      print('   - emergencyContactName: $emergencyContactName');
      print('   - emergencyContactPhone: $emergencyContactPhone');

      final registrationResult = await _riderService.registerRider(
        firebaseToken: _idToken!,
        firstName: firstName,
        lastName: lastName,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
      );

      if (registrationResult['success'] == true) {
        final userData = registrationResult['data'];
        _authToken = userData['token']; // Backend JWT token
        _currentUser = UserModel.fromJson(userData['user']);
        _authState = AuthState.loggedIn;

        // If email or dateOfBirth were provided but not in the registration,
        // update the profile with additional info
        if ((email != null && _currentUser?.email != email) ||
            (dateOfBirth != null && _currentUser?.dateOfBirth != dateOfBirth)) {
          print('📝 Updating additional profile information...');
          await updateProfile(email: email, dateOfBirth: dateOfBirth);
        }

        print('✅ User registered and logged in successfully');
        print('🆔 Rider ID: ${registrationResult['riderId']}');
        print(
          '📋 Is new registration: ${registrationResult['isNewRegistration']}',
        );
        return true;
      } else {
        _setError(registrationResult['error'] ?? 'Registration failed');
        _authState = AuthState.error;
        print('❌ Registration error: ${registrationResult['error']}');
        return false;
      }
    } catch (e) {
      _setError('Registration error: ${e.toString()}');
      _authState = AuthState.error;
      print('❌ Exception during registration: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 5. Complete user profile using RiderService
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    DateTime? dateOfBirth,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    if (_currentUser == null || _authToken == null) {
      _setError('User not logged in');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print('🔍 Updating profile using RiderService...');
      print('🆔 Rider ID: ${_currentUser!.userId}');
      print('📝 Update data:');
      if (firstName != null) print('   - firstName: $firstName');
      if (lastName != null) print('   - lastName: $lastName');
      if (email != null) print('   - email: $email');
      if (dateOfBirth != null)
        print('   - dateOfBirth: ${dateOfBirth.toIso8601String()}');
      if (emergencyContactName != null)
        print('   - emergencyContactName: $emergencyContactName');
      if (emergencyContactPhone != null)
        print('   - emergencyContactPhone: $emergencyContactPhone');

      final updateResult = await _riderService.updateRiderProfile(
        riderId: _currentUser!.userId!,
        jwtToken: _authToken!,
        firstName: firstName,
        lastName: lastName,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
      );

      if (updateResult['success'] == true) {
        final userData = updateResult['data'];
        _currentUser = UserModel.fromJson(userData['user']);

        // Handle email and dateOfBirth separately if they weren't handled by the rider service
        // Note: You might need to add these fields to your RiderService.updateRiderProfile method
        // or handle them through a different endpoint

        print('✅ Profile updated successfully');
        return true;
      } else {
        if (updateResult['statusCode'] == 401) {
          _setError('Session expired. Please login again.');
          _authState = AuthState.error;
          // Optionally trigger logout here
        } else {
          _setError(updateResult['error'] ?? 'Profile update failed');
        }
        print('❌ Profile update error: ${updateResult['error']}');
        return false;
      }
    } catch (e) {
      _setError('Update error: ${e.toString()}');
      print('❌ Exception during profile update: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 6. Get rider profile using RiderService
  Future<bool> refreshUserProfile() async {
    if (_currentUser == null || _authToken == null) {
      _setError('User not logged in');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      print('🔄 Refreshing user profile using RiderService...');
      print('🆔 Rider ID: ${_currentUser!.userId}');

      final profileResult = await _riderService.getRiderProfile(
        riderId: _currentUser!.userId!,
        jwtToken: _authToken!,
      );

      if (profileResult['success'] == true) {
        final userData = profileResult['data'];
        _currentUser = UserModel.fromJson(userData['user']);

        print('✅ Profile refreshed successfully');
        return true;
      } else {
        if (profileResult['statusCode'] == 401) {
          _setError('Session expired. Please login again.');
          _authState = AuthState.error;
          // Optionally trigger logout here
        } else {
          _setError(profileResult['error'] ?? 'Failed to refresh profile');
        }
        print('❌ Profile refresh error: ${profileResult['error']}');
        return false;
      }
    } catch (e) {
      _setError('Profile refresh error: ${e.toString()}');
      print('❌ Exception during profile refresh: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 7. Logout using RiderService
  Future<void> logout() async {
    try {
      print('🚪 Logging out using RiderService...');

      // Logout from backend if we have a token
      if (_authToken != null) {
        final logoutResult = await _riderService.logoutRider(
          jwtToken: _authToken!,
        );

        if (logoutResult['success'] == true) {
          print('✅ Backend logout successful');
        } else {
          print('⚠️ Backend logout failed: ${logoutResult['error']}');
          // Continue with local logout even if backend logout fails
        }
      }

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear local state
      _clearAllData();
      _authState = AuthState.initial;

      print('✅ Logged out successfully');
    } catch (e) {
      print('❌ Logout error: $e');
      // Still clear local data even if logout fails
      _clearAllData();
      _authState = AuthState.initial;
    }
  }

  // 8. Auto-login attempt (try to login with stored credentials)
  Future<bool> autoLogin() async {
    if (_idToken == null) {
      print('ℹ️ No Firebase token available for auto-login');
      return false;
    }

    _setLoading(true);
    _clearError();
    _authState = AuthState.checkingUser;

    try {
      print('🔄 Attempting auto-login using RiderService...');

      final loginResult = await _riderService.loginRider(
        firebaseToken: _idToken!,
      );

      if (loginResult['success'] == true) {
        final userData = loginResult['data'];
        _authToken = userData['token'];
        _currentUser = UserModel.fromJson(userData['user']);
        _authState = AuthState.loggedIn;

        print('✅ Auto-login successful');
        return true;
      } else {
        print('ℹ️ Auto-login failed: ${loginResult['error']}');
        _authState = AuthState.initial;
        return false;
      }
    } catch (e) {
      print('❌ Auto-login exception: $e');
      _authState = AuthState.initial;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Store JWT tokens with persistence
  Future<void> _storeJWTTokens(Map<String, dynamic> data) async {
    try {
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
      _userId = data['userId'];
      _tokenType = data['tokenType'] ?? 'Bearer';
      _userType = data['userType'];

      // Calculate expiry time
      final expiresIn = data['expiresIn'] ?? 3600;
      _tokenExpiresAt = DateTime.now().add(Duration(seconds: expiresIn));

      // Update user info
      _firstName = data['firstName'] ?? _firstName;
      _lastName = data['lastName'] ?? _lastName;
      _verifiedPhoneNumber = data['phoneNumber'] ?? _verifiedPhoneNumber;

      // Persist to local storage
      await _saveTokensToStorage();

      print('✅ JWT tokens stored and persisted');
      notifyListeners();
    } catch (e) {
      print('❌ Error storing JWT tokens: $e');
    }
  }

  // Save tokens to SharedPreferences
  Future<void> _saveTokensToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final tokenData = {
        'accessToken': _accessToken,
        'refreshToken': _refreshToken,
        'userId': _userId,
        'tokenType': _tokenType,
        'userType': _userType,
        'tokenExpiresAt': _tokenExpiresAt?.millisecondsSinceEpoch,
        'firstName': _firstName,
        'lastName': _lastName,
        'phoneNumber': _verifiedPhoneNumber,
        'riderId': _riderId,
        'profilePictureUrl': _profilePictureUrl,
      };

      await prefs.setString('jwt_tokens', jsonEncode(tokenData));
      print('💾 Tokens saved to local storage');
    } catch (e) {
      print('❌ Error saving tokens to storage: $e');
    }
  }

  // Load tokens from SharedPreferences
  // ignore: unused_element
  Future<void> _loadStoredTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenString = prefs.getString('jwt_tokens');

      if (tokenString != null) {
        final tokenData = jsonDecode(tokenString);

        _accessToken = tokenData['accessToken'];
        _refreshToken = tokenData['refreshToken'];
        _userId = tokenData['userId'];
        _tokenType = tokenData['tokenType'];
        _userType = tokenData['userType'];
        _firstName = tokenData['firstName'];
        _lastName = tokenData['lastName'];
        _verifiedPhoneNumber = tokenData['phoneNumber'];
        _riderId = tokenData['driverId'];
        _profilePictureUrl = tokenData['profilePictureUrl'];

        if (tokenData['tokenExpiresAt'] != null) {
          _tokenExpiresAt = DateTime.fromMillisecondsSinceEpoch(
            tokenData['tokenExpiresAt'],
          );
        }

        _isLoggedIn = _accessToken != null;

        print('📱 Loaded stored tokens');
        print('🎫 Access Token: ${_accessToken?.substring(0, 20)}...');
        print('⏰ Expires at: $_tokenExpiresAt');
        print('✅ Valid: $hasValidJWTToken');
      }
    } catch (e) {
      print('❌ Error loading stored tokens: $e');
    }
  }

  // Get current valid token (with auto-refresh)
  Future<String?> getCurrentToken() async {
    if (_accessToken == null) {
      print('❌ No access token available');
      return null;
    }

    // Check if token needs refresh (5 minutes before expiry)
    if (_tokenExpiresAt != null &&
        _tokenExpiresAt!.isBefore(
          DateTime.now().add(const Duration(minutes: 5)),
        )) {
      print('🔄 Token expiring soon, refreshing...');

      final refreshed = await _refreshAccessToken();
      if (!refreshed) {
        print('❌ Token refresh failed, user needs to login again');
        await logout();
        return null;
      }
    }

    return _accessToken;
  }

  // Refresh access token
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) {
      print('❌ No refresh token available');
      return false;
    }

    try {
      print('🔄 Refreshing access token...');

      final result = await _authService.refreshToken(_refreshToken!);

      if (result['success'] == true) {
        await _storeJWTTokens(result['data']);
        print('✅ Token refreshed successfully');
        return true;
      } else {
        print('❌ Token refresh failed: ${result['error']}');
        await _clearJWTTokens();
        return false;
      }
    } catch (e) {
      print('❌ Token refresh error: $e');
      await _clearJWTTokens();
      return false;
    }
  }

  // Clear JWT tokens
  Future<void> _clearJWTTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _userId = null;
    _tokenType = null;
    _tokenExpiresAt = null;
    _userType = null;
    _isLoggedIn = false;

    // Clear from storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_tokens');
    } catch (e) {
      print('❌ Error clearing tokens from storage: $e');
    }

    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _clearAllData() {
    _isPhoneVerified = false;
    _verifiedPhoneNumber = null;
    _verificationId = null;
    _idToken = null;
    _firebaseUid = null;
    _currentUser = null;
    _authToken = null;
    _clearError();
    notifyListeners();
  }

  // Public helper methods
  void clearError() {
    _clearError();
  }

  void resetToPhoneEntry() {
    _authState = AuthState.initial;
    _isPhoneVerified = false;
    _verificationId = null;
    _clearError();
    notifyListeners();
  }

  // Convenience methods for checking auth flow state
  bool get needsOTPVerification => _authState == AuthState.otpSent;
  bool get needsUserCheck => _authState == AuthState.otpVerified;
  bool get needsRegistration => _authState == AuthState.userNotExists;
  bool get isRegistering => _authState == AuthState.registering;
  bool get isCheckingUser => _authState == AuthState.checkingUser;

  // Additional convenience methods
  bool get canUploadProfilePhoto => _currentUser != null && _authToken != null;

  bool get canSkipGenderDetection => _currentUser != null && _authToken != null;
}
