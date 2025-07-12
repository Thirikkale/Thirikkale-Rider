import 'dart:io';
import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/authenctication/screens/full_screen_camera_page.dart';
import 'package:thirikkale_rider/features/authenctication/screens/terms_and_privacy_screen.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/photo_guidelines.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/profile_image_preview.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar.dart';

class PhotoVerificationScreen extends StatefulWidget {
  const PhotoVerificationScreen({super.key});

  @override
  State<PhotoVerificationScreen> createState() =>
      _PhotoVerificationScreenState();
}

class _PhotoVerificationScreenState extends State<PhotoVerificationScreen> {
  File? _capturedImage;

  Future<void> _openFullScreenCamera() async {
    // Navigate to full-screen camera and wait for the result
    // The camera package will handle permissions automatically
    final File? imageFile = await Navigator.of(context).push<File>(
      MaterialPageRoute(builder: (context) => const FullScreenCameraPage()),
    );

    // If a photo was captured, update the state
    if (imageFile != null && mounted) {
      setState(() {
        _capturedImage = imageFile;
      });
    }
  }

  void _navigateToNextScreen() {
    if (_capturedImage == null) {
      SnackbarHelper.showInfoSnackBar(context, "You can add your profile photo later from your account settings");
    }
    Navigator.of(context).push(
      NoAnimationPageRoute(builder: (context) => const TermsAndPrivacyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerWidget: Image.asset(
          'assets/images/thirikkale_primary_logo.png',
          height: 32.0,
        ),
        onSkip: _navigateToNextScreen,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take your profile photo',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your profile photo helps people recognize you. Please note that once you submit your profile photo it can only be changed in limited circumstances.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Text(
                  'Why you should submit a picture?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Submitting your photo helps us offer women-only ride options, creating a safer and more comfortable experience for women riders.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                const PhotoGuidelines(),
                const SizedBox(height: 24),
        
                // Display either the captured images or a place holder
                ProfileImagePreview(
                  capturedImage: _capturedImage,
                ),
                const SizedBox(height: 16),
                Text(
                  'Verifi will confirm that your photo depicts a live individual, captured in real-time, and Thirikkale will utilize the image to detect any duplicate accounts.',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // Show detailed privacy policy
                    },
                    child: const Text('Learn More'),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _openFullScreenCamera,
                    style: AppButtonStyles.primaryButton,
                    child: const Text('Take Photo'),
                  ),
                ),
        
                // Show continue button if we have a photo
                if (_capturedImage != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _navigateToNextScreen,
                      style: AppButtonStyles.secondaryButton,
                      child: const Text('Continue with This Photo'),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
