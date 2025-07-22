import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/authenctication/screens/otp_verification_screen.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/custom_phone_input_field.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar.dart';

class MobileRegistrationScreen extends StatefulWidget {
  const MobileRegistrationScreen({super.key});

  @override
  State<MobileRegistrationScreen> createState() =>
      _MobileRegistrationScreenState();
}

class _MobileRegistrationScreenState extends State<MobileRegistrationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _cleanPhoneNumber = '';
  // ignore: unused_field
  bool _isLocalLoading = false;

  String? _validatePhoneNumber(String? value) {
    if (_cleanPhoneNumber.isEmpty) {
      return 'Please enter your phone number';
    }
    if (_cleanPhoneNumber.length < 9) {
      return 'Please enter a valid phone number';
    }
    if (!RegExp(r'^[7][0-9]{8}$').hasMatch(_cleanPhoneNumber)) {
      return 'Please enter a valid Sri Lankan mobile number';
    }
    return null;
  }

  // Check if form is valid
  bool get _isFormValid {
    return _cleanPhoneNumber.isNotEmpty && _validatePhoneNumber(null) == null;
  }

  // Send OTP
  void _sendOTP() async {
    if (!_isFormValid) {
      SnackbarHelper.showErrorSnackBar(
        context,
        "Please enter a valid phone number",
      );
      return;
    }

    // Start local loading
    setState(() {
      _isLocalLoading = true;
    });

    final fullNumber = '+94 ${_phoneController.text}';
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.sendOTP(
        phoneNumber: fullNumber,
        onCodeSent: (verificationId, resendToken) {
          setState(() {
            _isLocalLoading = false; // Stop local loading
          });

          if (mounted) {
            // Set the verified phone number in provider
            authProvider.setVerifiedPhoneNumber(fullNumber);

            Navigator.of(context).push(
              NoAnimationPageRoute(
                builder:
                    (context) => OtpVerificationScreen(
                      verificationId: verificationId,
                      phoneNumber: fullNumber,
                    ),
              ),
            );
          }
        },
        onVerificationFailed: (error) {
          setState(() {
            _isLocalLoading = false; // Stop local loading
          });

          if (mounted) {
            SnackbarHelper.showErrorSnackBar(
              context,
              "Verification failed: ${error.message}",
            );
          }
        },
      );
    } catch (e) {
      setState(() {
        _isLocalLoading = false;
      });

      if (mounted) {
        SnackbarHelper.showErrorSnackBar(
          context,
          "An error occurred. Please try again.",
        );
      }
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerWidget: Image.asset(
          'assets/images/primary_logo.png',
          height: 32.0,
        ),
      ),
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              // Top image
              Image.asset(
                'assets/images/mobile_registration_bg.png',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),

              // Scrollable content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    Text(
                      'Enter your mobile number',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 24),
                    // Input field
                    CustomPhoneInputField(
                      controller: _phoneController,
                      validator: _validatePhoneNumber,
                      onChanged: (cleanNumber) {
                        setState(() {
                          _cleanPhoneNumber = cleanNumber;
                          print('Phone number changed: +94$cleanNumber');
                          // Store clean number
                        });
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),

              // Bottom button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    if (authProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isFormValid ? _sendOTP : null,
                        style: AppButtonStyles.primaryButton.copyWith(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.disabled)) {
                                  return AppColors.lightGrey;
                                }
                                return AppColors.primaryBlue;
                              }),
                        ),
                        child: const Text('Continue'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
