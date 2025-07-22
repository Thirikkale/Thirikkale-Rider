import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/authenctication/screens/name_registration_screen.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/sign_navigation_button_row.dart';
import 'package:thirikkale_rider/features/home/screens/home_screen.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar.dart';
import 'package:thirikkale_rider/widgets/otp_input_row.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpControllers = List.generate(6, (_) => TextEditingController());
  late Timer _timer;
  int _start = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    setState(() {
      _canResend = false;
      _start = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _canResend = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    for (var c in _otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  // Resend OTP
  void _resendOtp() {
    if (!_canResend) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.sendOTP(
      phoneNumber: widget.phoneNumber,
      onCodeSent: (newVerificationId, resendToken) {
        SnackbarHelper.showSuccessSnackBar(
          context,
          "New OTP sent successfully!",
        );
        startTimer(); // Restart the timer
      },
      onVerificationFailed: (error) {
        SnackbarHelper.showErrorSnackBar(
          context,
          error.message ?? "Failed to send OTP",
        );
      },
    );
  }

  // Check if all OTP fields are filled
  bool get _isFormValid {
    return _otpControllers.every((controller) => controller.text.isNotEmpty);
  }

  // Get OTP code from controllers
  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  // Verify OTP
  void _verifyOTP() async {
    if (!_isFormValid) {
      SnackbarHelper.showErrorSnackBar(
        context,
        "Please enter the complete verification code",
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // First verify the OTP
    final verified = await authProvider.verifyOTP(
      widget.verificationId,
      _otpCode,
    );

    // Check if widget is still mounted before using context
    if (!mounted) return;

    if (verified) {
      // Now check user registration status
      final statusResult = await authProvider.checkUserRegistrationStatus();

      // Check if widget is still mounted before using context
      if (!mounted) return;

      if (statusResult['success'] == true) {
        if (statusResult['isAutoLogin'] == true) {
          // Existing user with complete profile
          final firstName = authProvider.firstName ?? 'Rider';

          SnackbarHelper.showSuccessSnackBar(
            context,
            'Welcome back, $firstName!',
          );

          Navigator.of(context).pushAndRemoveUntil(
            NoAnimationPageRoute(builder: (context) => HomeScreen()),
            (route) => false,
          );
        } else {
          Navigator.of(context).push(
            NoAnimationPageRoute(
              builder: (context) => const NameRegistrationScreen(),
            ),
          );
        }
      } else {
        SnackbarHelper.showErrorSnackBar(
          context,
          statusResult['error'] ?? 'Failed to check registration status',
        );
      }
    } else {
      SnackbarHelper.showErrorSnackBar(
        context,
        authProvider.errorMessage ?? 'Invalid verification code',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerWidget: Image.asset(
          'assets/images/thirikkale_primary_logo.png',
          height: 32.0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Enter the 6-digit code sent via\nSMS to ${widget.phoneNumber}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 32),

            // OTP fields
            OtpInputRow(
              controllers: _otpControllers,
              onChanged: (value, index) {
                setState(() {}); // Update UI when text changes
              },
            ),
            const SizedBox(height: 24),

            // Resend OTP Timer and Button
            Center(
              child:
                  _canResend
                      ? TextButton(
                        onPressed: _resendOtp,
                        child: const Text('Resend Code'),
                      )
                      : Text(
                        'Resend code in 00:${_start.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
            ),

            const Spacer(),

            // Navigation buttons with loading state
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                if (authProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SignNavigationButtonRow(
                  onBack: () => Navigator.pop(context),
                  onNext: _isFormValid ? _verifyOTP : null,
                  nextEnabled: _isFormValid && !authProvider.isLoading,
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
