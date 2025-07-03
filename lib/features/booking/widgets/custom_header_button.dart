import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class CustomHeaderButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;
  final Color? borderColor;

  const CustomHeaderButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.subtleGrey,
          border: Border.all(color: borderColor ?? AppColors.white),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor ?? AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: textColor ?? AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: iconColor ?? AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
