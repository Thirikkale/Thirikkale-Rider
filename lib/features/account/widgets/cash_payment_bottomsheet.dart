import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

/// A reusable bottom sheet for confirming cash payment and setting it as default.
class CashPaymentBottomSheet extends StatelessWidget {
  final Function(bool isSetAsDefault) onConfirm;

  const CashPaymentBottomSheet({
    super.key,
    required this.onConfirm,
  });

  /// Static method to show the bottom sheet.
  static void show(
    BuildContext context, {
    required Function(bool isSetAsDefault) onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CashPaymentBottomSheet(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.pageHorizontalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: 16),
                  _buildContent(),
                  const SizedBox(height: 32),
                  _buildSetAsDefaultButton(context), // Replaced buttons
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        const Icon(Icons.money, color: AppColors.primaryBlue),
        const SizedBox(width: 8),
        Text(
          'Cash Payment',
          style: AppTextStyles.heading3,
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      'Pay your driver with cash at the end of your ride. No card details required.',
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
    );
  }

  // This new widget replaces the old checkbox and action buttons
  Widget _buildSetAsDefaultButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context); // Close the sheet
          onConfirm(true); // Trigger the callback to set as default
        },
        style: AppButtonStyles.primaryButton,
        child: const Text(
          'Set as default',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}