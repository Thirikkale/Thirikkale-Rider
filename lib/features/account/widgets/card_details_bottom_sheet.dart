import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/core/utils/dialog_helper.dart';
import 'package:thirikkale_rider/features/account/screens/payment_methods/edit_payment_method_screen.dart';
import 'package:thirikkale_rider/features/account/widgets/card_detail_row.dart';

/// A reusable bottom sheet widget for displaying card details
/// Includes card information, set as default, edit, and delete actions
class CardDetailsBottomSheet extends StatelessWidget {
  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final bool isDefault;
  final VoidCallback? onSetAsDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CardDetailsBottomSheet({
    super.key,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    this.isDefault = false,
    this.onSetAsDefault,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                const SizedBox(height: 20),
                _buildCardDetails(),
                const SizedBox(height: 32),
                if (!isDefault) _buildSetAsDefaultButton(context),
                if (!isDefault) const SizedBox(height: 16),
                _buildActionButtons(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
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
    return const Text(
      'Card Details',
      style: AppTextStyles.heading3,
    );
  }

  Widget _buildCardDetails() {
    return Column(
      children: [
        CardDetailRow(label: 'Card Number', value: cardNumber),
        const SizedBox(height: 16),
        CardDetailRow(label: 'Expiry Date', value: expiryDate),
        const SizedBox(height: 16),
        CardDetailRow(label: 'Card Holder', value: cardHolderName),
      ],
    );
  }

  Widget _buildSetAsDefaultButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          onSetAsDefault?.call();
          SnackbarHelper.showSuccessSnackBar(
            context,
            'Payment method set as default!',
          );
        },
        label: const Text('Set as Default'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryBlue),
          foregroundColor: AppColors.primaryBlue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditPaymentMethodScreen(),
                ),
              );
              onEdit?.call();
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.lightGrey),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Edit',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: AppButtonStyles.errorButton,
            onPressed: () {
              Navigator.pop(context);
              _showDeleteConfirmationDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Delete Payment Method',
      content: 'Are you sure you want to delete this payment method? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmButtonColor: AppColors.error,
      onConfirm: () {
        onDelete?.call();
      },
    );
  }

  /// Static method to show the bottom sheet
  static void show(
    BuildContext context, {
    required String cardNumber,
    required String expiryDate,
    required String cardHolderName,
    bool isDefault = false,
    VoidCallback? onSetAsDefault,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CardDetailsBottomSheet(
        cardNumber: cardNumber,
        expiryDate: expiryDate,
        cardHolderName: cardHolderName,
        isDefault: isDefault,
        onSetAsDefault: onSetAsDefault,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}
