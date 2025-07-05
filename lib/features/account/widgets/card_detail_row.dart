import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

/// A reusable widget for displaying card detail rows (label and value pairs)
/// Used in card detail bottom sheets and card information displays
class CardDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const CardDetailRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
