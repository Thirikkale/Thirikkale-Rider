import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thirikkale_rider/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPhoneVerified = false;
  String? _verifiedPhoneNumber;
  String? _idToken;
  String? _firebaseUid;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPhoneVerified => _isPhoneVerified;
  String? get verifiedPhoneNumber => _verifiedPhoneNumber;
  String? get idToken => _idToken;
  String? get firebaseUid => _firebaseUid;

  // Send OTP for phone verification
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(FirebaseAuthException error) onVerificationFailed,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.sendOTP(
        phoneNumber: phoneNumber,
        codeSent: (verificationId, resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        verificationFailed: (error) {
          _setError(error.message ?? 'Phone verification failed');
          onVerificationFailed(error);
        },
        verificationCompleted: (credential) {
          // Auto-verification completed
          _isPhoneVerified = true;
          _verifiedPhoneNumber = phoneNumber;
          notifyListeners();
        },
      );
    } catch (e) {
      _setError(e.toString());
      onVerificationFailed(
        FirebaseAuthException(code: 'unknown', message: e.toString()),
      );
    } finally {
      _setLoading(false);
    }
  }

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

  // Send token to backend
  Future<bool> sendTokenToBackend({
    required String endpoint,
    Map<String, dynamic>? additionalData,
  }) async {
    if (_idToken == null) {
      _setError('No authentication token available');
      return false;
    }

    _setLoading(true);
    _clearError();

    try {
      // Prepare request data
      final requestData = {
        'phoneNumber': _verifiedPhoneNumber,
        'uid': _firebaseUid,
        ...?additionalData,
      };

      // Send request to your Spring Boot backend
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_idToken',
        },
        body: jsonEncode(requestData),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success - parse response if needed
        return true;
      } else {
        // Backend returned an error
        _setError('Server error: ${response.body}');
        return false;
      }
    } catch (e) {
      _setError('Network error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set verified phone number
  void setVerifiedPhoneNumber(String phoneNumber) {
    _verifiedPhoneNumber = phoneNumber;
    notifyListeners();
  }

  // Reset verification status
  void resetVerification() {
    _isPhoneVerified = false;
    _verifiedPhoneNumber = null;
    _idToken = null;
    _firebaseUid = null;
    _clearError();
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

  // Clear error manually
  void clearError() {
    _clearError();
  }
}
