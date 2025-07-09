import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thirikkale_rider/core/services/auth_service.dart';
import 'package:thirikkale_rider/core/config/api_config.dart';
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
  error
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State management
  AuthState _authState = AuthState.initial;
  bool _isLoading = false;
  String? _errorMessage;

  // Phone verification
  bool _isPhoneVerified = false;
  String? _verifiedPhoneNumber;
  String? _verificationId;
  String? _idToken;
  String? _firebaseUid;

  // User data
  UserModel? _currentUser;
  String? _authToken; // Backend JWT token

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
  bool get isLoggedIn => _authState == AuthState.loggedIn && _currentUser != null;

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
  Future<bool> verifyOTP(String code) async {
    if (_verificationId == null) {
      _setError('No verification ID available');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      final result = await _authService.verifyOTPAndGetToken(
        _verificationId!,
        code,
      );

      if (result['success'] == true) {
        _idToken = result['idToken'];
        _firebaseUid = result['uid'];
        _isPhoneVerified = true;
        _authState = AuthState.otpVerified;

        if (_verifiedPhoneNumber == null && result['phoneNumber'] != null) {
          _verifiedPhoneNumber = result['phoneNumber'];
        }

        print('✅ OTP verified successfully. Firebase token obtained.');
        return true;
      } else {
        _setError(result['error'] ?? 'Verification failed');
        _authState = AuthState.error;
        return false;
      }
    } catch (e) {
      _setError('Invalid verification code. Please try again.');
      _authState = AuthState.error;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 3. Check if user exists in backend
  Future<bool> checkUserExists() async {
    if (_verifiedPhoneNumber == null || _idToken == null) {
      _setError('Phone verification required');
      return false;
    }

    _setLoading(true);
    _clearError();
    _authState = AuthState.checkingUser;

    try {
      // Backend expects firebaseIdToken as request parameter, not in body
      final loginUrl = Uri.parse(RiderEndpoints.login).replace(
        queryParameters: {'firebaseIdToken': _idToken},
      );

      print('🔍 LOGIN REQUEST:');
      print('📍 URL: $loginUrl');
      print('📋 Headers: ${ApiConfig.defaultHeaders}');
      print('🔑 Firebase Token: ${_idToken?.substring(0, 20)}...');
      print('📱 Phone: $_verifiedPhoneNumber');
      print('👤 Firebase UID: $_firebaseUid');

      final response = await http.post(
        loginUrl,
        headers: ApiConfig.defaultHeaders,
      );

      print('📨 LOGIN RESPONSE:');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        // User exists and logged in successfully
        final data = jsonDecode(response.body);
        _authToken = data['token']; // Backend JWT token
        _currentUser = UserModel.fromJson(data['user']);
        _authState = AuthState.loggedIn;
        
        print('✅ User exists and logged in successfully');
        return true;
      } else if (response.statusCode == 404) {
        // User doesn't exist, needs registration
        _authState = AuthState.userNotExists;
        print('ℹ️ User not found, registration required');
        return false;
      } else {
        // Other error
        final errorData = jsonDecode(response.body);
        _setError(errorData['message'] ?? 'Login failed');
        _authState = AuthState.error;
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      _authState = AuthState.error;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 4. Register new user
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
      // Create user model for registration
      final newUser = UserModel(
        phoneNumber: _verifiedPhoneNumber!,
        firstName: firstName,
        lastName: lastName,
        email: email,
        dateOfBirth: dateOfBirth,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
        isPhoneVerified: true,
      );

      // Backend expects firebaseIdToken as query parameter + registration data in body
      final registrationUrl = Uri.parse(RiderEndpoints.register).replace(
        queryParameters: {'firebaseIdToken': _idToken},
      );

      final registrationData = newUser.toRegistrationJson();

      print('🔍 REGISTRATION REQUEST:');
      print('📍 URL: $registrationUrl');
      print('📋 Headers: ${ApiConfig.defaultHeaders}');
      print('� Firebase Token: ${_idToken?.substring(0, 20)}...');
      print('📦 Body Parameters: ${jsonEncode(registrationData)}');
      print('📝 Registration Data Breakdown:');
      print('   - phoneNumber: ${newUser.phoneNumber}');
      print('   - firstName: ${newUser.firstName}');
      print('   - lastName: ${newUser.lastName}');
      print('   - email: ${newUser.email}');
      print('   - dateOfBirth: ${newUser.dateOfBirth?.toIso8601String()}');
      print('   - emergencyContactName: ${newUser.emergencyContactName}');
      print('   - emergencyContactPhone: ${newUser.emergencyContactPhone}');
      print('   - gender: ${newUser.gender?.name}');
      print('   - womenOnlyAccess: ${newUser.womenOnlyAccess}');
      print('❌ NOTE: NO userId or firebaseUid in body - Firebase token is in URL parameter');

      final response = await http.post(
        registrationUrl,
        headers: ApiConfig.defaultHeaders,
        body: jsonEncode(registrationData),
      );

      print('📨 REGISTRATION RESPONSE:');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        _authToken = data['token']; // Backend JWT token
        _currentUser = UserModel.fromJson(data['user']);
        _authState = AuthState.loggedIn;
        
        print('✅ User registered and logged in successfully');
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _setError(errorData['message'] ?? 'Registration failed');
        _authState = AuthState.error;
        return false;
      }
    } catch (e) {
      _setError('Registration error: ${e.toString()}');
      _authState = AuthState.error;
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 5. Complete user profile (additional step)
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
      final updatedData = <String, dynamic>{};
      if (firstName != null) updatedData['firstName'] = firstName;
      if (lastName != null) updatedData['lastName'] = lastName;
      if (email != null) updatedData['email'] = email;
      if (dateOfBirth != null) updatedData['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (emergencyContactName != null) updatedData['emergencyContactName'] = emergencyContactName;
      if (emergencyContactPhone != null) updatedData['emergencyContactPhone'] = emergencyContactPhone;

      print('🔍 PROFILE UPDATE REQUEST:');
      print('📍 URL: ${RiderEndpoints.updateProfile(_currentUser!.userId!)}');
      print('📋 Headers: ${ApiConfig.getAuthHeaders(_authToken!)}');
      print('📦 Body Parameters: ${jsonEncode(updatedData)}');
      print('📝 Update Data Breakdown:');
      updatedData.forEach((key, value) {
        print('   - $key: $value');
      });

      final response = await http.put(
        Uri.parse(RiderEndpoints.updateProfile(_currentUser!.userId!)),
        headers: ApiConfig.getAuthHeaders(_authToken!),
        body: jsonEncode(updatedData),
      );

      print('📨 PROFILE UPDATE RESPONSE:');
      print('📊 Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        _currentUser = UserModel.fromJson(data['user']);
        
        print('✅ Profile updated successfully');
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        _setError(errorData['message'] ?? 'Profile update failed');
        return false;
      }
    } catch (e) {
      _setError('Update error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // 6. Logout
  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      
      // Clear local state
      _clearAllData();
      _authState = AuthState.initial;
      
      print('✅ Logged out successfully');
    } catch (e) {
      print('❌ Logout error: $e');
    }
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
}
