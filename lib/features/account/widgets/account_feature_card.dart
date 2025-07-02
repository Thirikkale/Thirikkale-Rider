import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class AccountFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon; // can be an Icon or an Image;

  const AccountFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
      decoration: BoxDecoration(
        color: AppColors.subtleGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.widgetSpacing),
          icon,
        ],
      ),
    );
  }
}
