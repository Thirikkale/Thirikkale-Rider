import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool showArrow;
  final double? width;
  final String text;
  const CustomBackButton({
    super.key,
    required this.onPressed,
    this.showArrow = true,
    this.width,
    this.text = 'Back',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 48, // Fixed height for consistency
      child: ElevatedButton(
        onPressed: onPressed,
        style: AppButtonStyles.backButton,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showArrow) const Icon(Icons.arrow_back, size: 16),
            if (showArrow) const SizedBox(width: 8),
            Text(text),
          ],
        ),
      ),
    );
  }
}
