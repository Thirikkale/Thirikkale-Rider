import 'package:flutter/material.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/custom_back_button.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/custom_next_button.dart';

class SignNavigationButtonRow extends StatelessWidget {
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String backText;
  final String nextText;
  final bool nextEnabled;
  const SignNavigationButtonRow({
    super.key,
    this.onBack,
    this.onNext,
    this.backText = 'Back',
    this.nextText = 'Next',
    this.nextEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Back button - takes equal space
        Expanded(
          child: CustomBackButton(
            onPressed: onBack ?? () => Navigator.pop(context),
            text: backText,
          ),
        ),

        const SizedBox(width: 145), // Spacing between buttons
        // Next button - takes equal space
        Expanded(
          child: CustomNextButton(
            onPressed: nextEnabled ? onNext : null,
            text: nextText,
          ),
        ),
      ],
    );
  }
}
