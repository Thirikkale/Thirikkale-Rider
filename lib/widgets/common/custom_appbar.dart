// Updated CustomAppBar - acts as a band without affecting status bar
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBack;
  final Widget centerWidget;
  final VoidCallback? onSkip;

  const CustomAppBar({
    super.key,
    this.onBack,
    required this.centerWidget,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Column(
        children: [
          Container(height: statusBarHeight, color: Colors.white),
          // The actual app bar band
          Container(
            height: kToolbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.black,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                ),
                Expanded(child: Center(child: centerWidget)),
                if (onSkip != null)
                  TextButton(
                    onPressed: onSkip,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                else
                  // Add invisible widget to balance the layout
                  const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize {
    const defaultStatusBarHeight = 44.0;
    return const Size.fromHeight(kToolbarHeight + defaultStatusBarHeight);
  }
}
