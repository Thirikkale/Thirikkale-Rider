import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class PaymentInfoTile extends StatelessWidget {
  final String icon;
  final String cardInfo;
  final String expiryDate;
  final VoidCallback onTap;

  const PaymentInfoTile({
    super.key,
    required this.icon,
    required this.cardInfo,
    required this.expiryDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.subtleGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(icon, width: 40, height: 40),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cardInfo,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expiryDate,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
