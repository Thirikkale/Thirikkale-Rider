import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

/// A reusable tile widget for displaying payment methods
/// Used in the payment methods screen to show cards, cash, and other payment options
class PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isCash;
  final VoidCallback onTap;
  final bool isDefault;

  const PaymentMethodTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.isCash = false,
    required this.onTap,
    
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontalPadding,
          vertical: 6,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDefault ? AppColors.primaryBlue.withValues(alpha: 0.05) : null,
          border: Border.all(
            color: isDefault ? AppColors.primaryBlue : AppColors.lightGrey,
            width: isDefault ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: AppDimensions.widgetSpacing),
            Expanded(child: _buildContent()),
            if (!isCash) _buildTrailingIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDefault 
          ? AppColors.primaryBlue.withValues(alpha: 0.1) 
          : AppColors.subtleGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: isDefault ? AppColors.primaryBlue : AppColors.textSecondary,
        size: 24,
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isDefault ? AppColors.primaryBlue : AppColors.textPrimary,
              ),
            ),
            if (isDefault) ...[
              const SizedBox(width: 8),
              _buildDefaultBadge(),
            ],
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDefaultBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Default',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTrailingIcon() {
    return Icon(
      Icons.arrow_forward_ios_rounded,
      size: 16,
      color: isDefault ? AppColors.primaryBlue : AppColors.textSecondary,
    );
  }
}
