import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
import 'package:thirikkale_rider/features/authenctication/screens/photo_verification_screen.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/sign_navigation_button_row.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar.dart';
import 'package:thirikkale_rider/widgets/common/custom_input_field_label.dart';

class NameRegistrationScreen extends StatelessWidget {
  const NameRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerWidget: Image.asset(
          'assets/images/primary_logo.png',
          height: 32.0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What is your name?',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Let us know how to properly address you.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 14),
            CustomInputFieldLabel(label: "First Name"),
            const SizedBox(height: 16),
            CustomInputFieldLabel(label: "Last Name"),
            const Spacer(),
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
              onNext:
                  () => Navigator.of(context).push(
                    NoAnimationPageRoute(
                      builder: (context) => const PhotoVerificationScreen(),
                    ),
                  ),
              // nextEnabled: _isFormValid,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
