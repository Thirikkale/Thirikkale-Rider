import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class PromoCodeInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onApply;
  final String hintText;
  final String buttonText;

  const PromoCodeInput({
    super.key,
    required this.controller,
    required this.onApply,
    this.hintText = 'Enter promo code',
    this.buttonText = 'Apply',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalPadding,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.subtleGrey,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onApply,
                style: AppButtonStyles.primaryButton.copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: AppTextStyles.button,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
