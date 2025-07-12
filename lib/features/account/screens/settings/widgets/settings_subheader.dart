import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class SettingsSubheader extends StatelessWidget {
  final String title;

  const SettingsSubheader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTextStyles.bodyXLarge.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
