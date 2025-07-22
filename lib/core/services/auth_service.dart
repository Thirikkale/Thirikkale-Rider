import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:thirikkale_rider/core/config/api_config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send OTP to phone number
  Future<void> sendOTP({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException error) verificationFailed,
    Function(PhoneAuthCredential credential)? verificationCompleted,
    Function(String verificationId)? codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted:
          verificationCompleted ??
          (PhoneAuthCredential credential) {
            // Auto-verification completed (usually on iOS)
            print('Phone verification completed automatically');
          },
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout:
          codeAutoRetrievalTimeout ??
          (String verificationId) {
            print('Code auto retrieval timeout: $verificationId');
          },
      timeout: const Duration(seconds: 60),
    );
  }

  // Verify OTP code (for verification only, not signup)
  Future<bool> verifyOTP(String verificationId, String code) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      // Just verify the credential, don't sign in
      await _auth.signInWithCredential(credential);

      // Immediately sign out since we're only verifying, not signing up
      await _auth.signOut();

      return true;
    } catch (e) {
      rethrow; // Re-throw to handle in AuthProvider
    }
  }

  // Update this method to return the token
  // Verify OTP and get token
  Future<Map<String, dynamic>> verifyOTPAndGetToken(
    String verificationId,
    String code,
  ) async {
    try {
      // Create credential
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: code,
      );

      // Sign in with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Get user
      final User? user = userCredential.user;

      if (user == null) {
        return {'success': false, 'error': 'User is null after verification'};
      }

      // Get ID token
      final String? idToken = await user.getIdToken();

      return {
        'success': true,
        'idToken': idToken,
        'uid': user.uid,
        'phoneNumber': user.phoneNumber,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get current verification status without signing in
  Future<bool> isPhoneNumberValid(String phoneNumber) async {
    // You can add additional phone number validation logic here
    return phoneNumber.isNotEmpty && phoneNumber.startsWith('+');
  }

  // Refresh JWT token using refresh token
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      print('🔄 Refreshing JWT token...');

      final response = await http
          .post(
            Uri.parse(ApiConfig.refreshToken),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 30));

      print('📨 Refresh token response status: ${response.statusCode}');
      print('📄 Refresh token response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Token refresh failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Token refresh error: $e');
      return {'success': false, 'error': 'Token refresh failed: $e'};
    }
  }

  // Logout and clear tokens
  Future<Map<String, dynamic>> logout(String accessToken) async {
    try {
      print('🚪 Logging out...');

      final response = await http
          .post(
            Uri.parse(ApiConfig.logout),
            headers: {
              ...ApiConfig.defaultHeaders,
              'Authorization': 'Bearer $accessToken',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('📨 Logout response status: ${response.statusCode}');

      // Sign out from Firebase as well
      await _auth.signOut();

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': 'Logged out successfully',
      };
    } catch (e) {
      print('❌ Logout error: $e');
      // Still sign out from Firebase even if backend call fails
      await _auth.signOut();
      return {'success': true, 'message': 'Logged out locally'};
    }
  }

  // Sign out from Firebase
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
