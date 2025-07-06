import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class PaymentMethodBottomSheet extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodBottomSheet({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final methods = [
      {
        'id': 'cash',
        'name': 'Cash Payment',
        'icon': Icons.money,
        'description': 'Pay with cash when you arrive'
      },
      {
        'id': 'card',
        'name': 'Credit/Debit Card',
        'icon': Icons.credit_card,
        'description': 'Pay securely with your card'
      },
      {
        'id': 'digital',
        'name': 'Digital Wallet',
        'icon': Icons.account_balance_wallet,
        'description': 'Use mobile wallet or UPI'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            'Select Payment Method',
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 20),

          // Payment methods
          ...methods.map((method) => _buildPaymentOption(
                context,
                method,
                selectedMethod == method['id'],
              )),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    Map<String, dynamic> method,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? AppColors.primaryBlue.withOpacity(0.05) : AppColors.white,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppColors.primaryBlue.withOpacity(0.1) 
                : AppColors.subtleGrey,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            method['icon'] as IconData,
            color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
          ),
        ),
        title: Text(
          method['name'] as String,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color.fromARGB(255, 2, 4, 4) : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          method['description'] as String,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: isSelected
            ? const Icon(
                Icons.check_circle,
                color: AppColors.primaryBlue,
              )
            : null,
        onTap: () {
          onMethodSelected(method['id'] as String);
          Navigator.pop(context);
        },
      ),
    );
  }
}