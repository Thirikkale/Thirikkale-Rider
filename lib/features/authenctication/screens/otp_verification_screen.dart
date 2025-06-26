import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
import 'package:thirikkale_rider/features/authenctication/screens/name_registration_screen.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/sign_navigation_button_row.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

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
            Text(
              'Enter the 4-digit code sent via\nSMS at +9477#######',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 32),

            // OTP fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 70,
                  height: 70,
                  child: TextField(
                    // controller: _controllers[index],
                    // focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    // onChanged: (value) => _onDigitChanged(value, index),
                    style: AppTextStyles.heading2,
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor:
                          index == 0 ? AppColors.white : AppColors.surfaceLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            index == 0
                                ? const BorderSide(color: AppColors.black)
                                : BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            index == 0
                                ? const BorderSide(color: AppColors.black)
                                : BorderSide.none,
                      ),
                    ),
                  ),
                );
              }),
            ),
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
                      builder: (context) => const NameRegistrationScreen(),
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
