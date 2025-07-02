import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class RideOptionCard extends StatelessWidget {
  final String icon;
  final String title;
  final bool isPromo;

  const RideOptionCard({
    super.key,
    required this.icon,
    required this.title,
    this.isPromo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isPromo)
            Container(
              width: 60.0,
              alignment: Alignment.topLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: const BoxDecoration(
                color: AppColors.secondaryBlue,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: Text(
                'Promo',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Image.asset(icon, width: 40, height: 40),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
