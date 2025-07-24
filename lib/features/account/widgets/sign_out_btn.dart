import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class SignOutBtn extends StatelessWidget {
  final VoidCallback onPressed;

  const SignOutBtn({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.logout, size: 24, weight: 700),
        label: const Text('Sign Out'),
        style: TextButton.styleFrom(
          // This sets the color for both the icon and the text
          foregroundColor: AppColors.error,
          textStyle: AppTextStyles.bodyXLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
