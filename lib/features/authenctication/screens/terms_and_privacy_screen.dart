import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/sign_navigation_button_row.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar.dart';

class TermsAndPrivacyScreen extends StatefulWidget {
  const TermsAndPrivacyScreen({super.key});

  @override
  State<TermsAndPrivacyScreen> createState() => _TermsAndPrivacyScreenState();
}

class _TermsAndPrivacyScreenState extends State<TermsAndPrivacyScreen> {
  bool _isAgreed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerWidget: Image.asset(
          'assets/images/thirikkale_primary_logo.png',
          height: 32.0,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Title
              const Text(
                "Accept Thirikkale's Terms & Review Privacy Notice",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // Terms text
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'By selecting "I Agree" below, I have reviewed and agree to the ',
                    ),
                    TextSpan(
                      text: 'Terms of Use',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to Terms of Use
                              print('Navigate to Terms of Use');
                            },
                    ),
                    const TextSpan(text: ' and acknowledge the '),
                    TextSpan(
                      text: 'Privacy Notice',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer:
                          TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to Privacy Notice
                              print('Navigate to Privacy Notice');
                            },
                    ),
                    const TextSpan(text: '. I am at least 18 years of age.'),
                  ],
                ),
              ),

              const Spacer(),

              // Checkbox for agreement
              Row(
                children: [
                  Checkbox(
                    value: _isAgreed,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAgreed = value ?? false;
                      });
                    },
                  ),
                  const Text(
                    'I Agree',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              SignNavigationButtonRow(
                onBack: () => Navigator.pop(context),
                // onNext:
                //     _isFormValid
                //         ? () {
                //           Navigator.push(
                //             context,
                //             MaterialPageRoute(
                //               builder: (context) => const NextScreen(),
                //             ),
                //           );
                //         }
                //         : null,
                // onNext:
                //     () => Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => const NameRegistrationScreen(),
                //       ),
                //     ),
                // nextEnabled: _isFormValid,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
