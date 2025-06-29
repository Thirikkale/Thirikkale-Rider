import 'package:firebase_auth/firebase_auth.dart';

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
      verificationCompleted: verificationCompleted ?? (PhoneAuthCredential credential) {
        // Auto-verification completed (usually on iOS)
        print('Phone verification completed automatically');
      },
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout ?? (String verificationId) {
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
        smsCode: code
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

  // Get current verification status without signing in
  Future<bool> isPhoneNumberValid(String phoneNumber) async {
    // You can add additional phone number validation logic here
    return phoneNumber.isNotEmpty && phoneNumber.startsWith('+');
  }
}