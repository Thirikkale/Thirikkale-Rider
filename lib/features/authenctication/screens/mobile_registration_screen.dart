import 'package:flutter/material.dart';
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
    // Add more validation as needed
    return null;
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              // SizedBox(
              //   height: MediaQuery.of(context).padding.top + kToolbarHeight,
              // ),
              // Top image
              Image.asset(
                'assets/images/mobile_registration_bg.png',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
              // Content below image
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
                        // Handle real-time changes if needed
                        print('Phone number changed: +94$value');
                      },
                    ),
                    const SizedBox(height: 32),
                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle submit
                          String fullNumber = '+94${_phoneController.text}';
                          print('Phone Number: $fullNumber');
                          Navigator.of(context).push(
                            NoAnimationPageRoute(builder: (context) => const OtpVerificationScreen())
                          );
                        },
                        style: AppButtonStyles.primaryButton,
                        child: const Text('Continue'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
