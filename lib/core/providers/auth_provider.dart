import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thirikkale_rider/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isPhoneVerified = false;
  String? _verifiedPhoneNumber;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPhoneVerified => _isPhoneVerified;
  String? get verifiedPhoneNumber => _verifiedPhoneNumber;

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
      onVerificationFailed(FirebaseAuthException(
        code: 'unknown',
        message: e.toString(),
      ));
    } finally {
      _setLoading(false);
    }
  }

  // Verify OTP code
  Future<bool> verifyOTP(String verificationId, String code) async {
    _setLoading(true);
    _clearError();

    try {
      final isValid = await _authService.verifyOTP(verificationId, code);
      
      if (isValid) {
        _isPhoneVerified = true;
        return true;
      }
      return false;
    } catch (e) {
      _setError('Invalid verification code. Please try again.');
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