import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class PromotionBanner extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? discountText;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  const PromotionBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.discountText,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalPadding,
        vertical: AppDimensions.widgetSpacing,
      ),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.subSectionSpacingDown * 3,
              vertical: AppDimensions.subSectionSpacingDown * 3,
            ),
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: textColor ?? AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: AppDimensions.subSectionSpacingDown),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: textColor ?? AppColors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (discountText != null) ...[
                  const SizedBox(width: AppDimensions.subSectionSpacingDown),
                  Text(
                    discountText!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: textColor ?? AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
