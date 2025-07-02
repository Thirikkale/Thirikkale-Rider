import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color primaryBlue = Color(0xFF0EA5E9);
  static const Color secondaryBlue = Color(0xFF3B82F6);

  // Background colors
  static const Color background = Color(0xFFFFFFFF); // Pure white background
  static const Color surfaceLight = Color(0xFFF8F9FA); // Light gray for cards
  
  // Text colors
  static const Color textPrimary = Color(0xFF212529); // Almost black
  static const Color textSecondary = Color(0xFF6C757D); // Medium gray

  // Other colors
  static const Color grey = Color(0xFF6C757D);
  static const Color lightGrey = Color(0xFFDEE2E6);
  static const Color subtleGrey = Color(0xFFE9ECEF);
  static const Color error = Color(0xFFDC3545);
  static const Color success = Color(0xFF198754);
  static const Color warning = Color(0xFFFFC107);
  static const Color divider = Color(0xFFE9ECEF);
}

class AppTextStyles {
  static TextStyle heading1 = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static TextStyle heading2 = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: AppColors.grey,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
}

class AppButtonStyles {
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: AppColors.white,
    textStyle: AppTextStyles.button,
    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  );

  static final ButtonStyle secondaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.white,
    foregroundColor: AppColors.primaryBlue,
    textStyle: AppTextStyles.button,
    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 16.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
      side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
    ),
  );

  static final ButtonStyle textButton = TextButton.styleFrom(
    foregroundColor: AppColors.primaryBlue,
    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  );

  static final ButtonStyle nextButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryBlue,
    foregroundColor: AppColors.white,
    disabledBackgroundColor: AppColors.lightGrey,
    disabledForegroundColor: AppColors.grey,
    textStyle: AppTextStyles.button,
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0), // Pill-shaped
    ),
    elevation: 0, // Flat design without shadow
  );

  static final ButtonStyle backButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.surfaceLight,
    foregroundColor: AppColors.textPrimary,
    textStyle: AppTextStyles.button.copyWith(color: AppColors.textPrimary),
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30.0), // Matching the Next button's shape
    ),
    elevation: 0, // Flat design without shadow
  );
}