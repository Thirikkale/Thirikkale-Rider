import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
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

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.length < 9) {
      return 'Please enter a valid phone number';
    }
    if (!RegExp(r'^[7][0-9]{8}$').hasMatch(value)) {
      return 'Please enter a valid Sri Lankan mobile number';
    }
    return null;
  }

  // Check if form is valid
  bool get _isFormValid {
    return _phoneController.text.isNotEmpty &&
        _validatePhoneNumber(_phoneController.text) == null;
  }

  // Send OTP
  void _sendOTP() async {
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final fullNumber = '+94${_phoneController.text}';
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await authProvider.sendOTP(
      phoneNumber: fullNumber,
      onCodeSent: (verificationId, resendToken) {
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Verification failed: ${error.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
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
                      onChanged: (value) {
                        setState(() {}); // Update UI for validation
                        print('Phone number changed: +94$value');
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
                          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.disabled)) {
                                return AppColors.lightGrey;
                              }
                              return AppColors.primaryBlue;
                            },
                          ),
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
