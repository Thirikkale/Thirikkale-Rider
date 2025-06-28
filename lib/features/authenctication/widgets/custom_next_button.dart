import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class CustomNextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool showArrow;
  final double? width;
  final String text;
  const CustomNextButton({
    super.key,
    required this.onPressed,
    this.showArrow = true,
    this.width,
    this.text = 'Next',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 48, 
      child: ElevatedButton(
        onPressed: onPressed,
        style: AppButtonStyles.nextButton,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text),
            if (showArrow) const SizedBox(width: 8),
            if (showArrow) const Icon(Icons.arrow_forward, size: 16),
          ],
        ),
      ),
    );
  }
}
