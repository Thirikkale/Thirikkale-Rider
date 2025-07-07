import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class SectionSubheader extends StatelessWidget {
  final String title;

  const SectionSubheader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.pageHorizontalPadding,
      ),
      child: Text(
        title,
        style: AppTextStyles.bodyXLarge.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
