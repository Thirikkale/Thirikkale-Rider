import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class LocationTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool autoFocus;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final String? initialValue;

  const LocationTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.prefixIcon,
    this.autoFocus = false,
    this.onTap,
    this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autoFocus,
      onTap: onTap,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20)
                : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2)
        ),
        filled: true,
        fillColor: AppColors.subtleGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      style: AppTextStyles.bodyMedium,
    );
  }
}
