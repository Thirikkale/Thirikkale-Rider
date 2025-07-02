import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class RebookBtn extends StatelessWidget {
  final VoidCallback onPressed;

  const RebookBtn({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.refresh, size: 18),
      label: const Text('Rebook'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.subtleGrey,
        foregroundColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w500,
        ),
        elevation: 1,
        shadowColor: AppColors.black.withOpacity(0.1),
      ),
    );
  }
}
