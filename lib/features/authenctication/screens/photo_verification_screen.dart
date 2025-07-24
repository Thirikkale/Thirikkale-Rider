import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/authenctication/screens/full_screen_camera_page.dart';
import 'package:thirikkale_rider/features/authenctication/screens/terms_and_privacy_screen.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/photo_guidelines.dart';
import 'package:thirikkale_rider/features/authenctication/widgets/profile_image_preview.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar.dart';
import 'package:thirikkale_rider/widgets/custom_modern_loading_overlay.dart';

class PhotoVerificationScreen extends StatefulWidget {
  const PhotoVerificationScreen({super.key});

  @override
  State<PhotoVerificationScreen> createState() =>
      _PhotoVerificationScreenState();
}

class _PhotoVerificationScreenState extends State<PhotoVerificationScreen> {
  bool _cameraPermissionGranted = false;
  File? _capturedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _cameraPermissionGranted = status.isGranted;
    });
  }

  Future<void> _openFullScreenCamera() async {
    if (!_cameraPermissionGranted) {
      await _requestCameraPermission();
      if (!_cameraPermissionGranted) return;
    }

    if (!mounted) return;

    try {
      // Navigate to full-screen camera and wait for the result
      final File? imageFile = await Navigator.of(context).push<File>(
        MaterialPageRoute(builder: (context) => const FullScreenCameraPage()),
      );

      // If a photo was captured, update the state
      if (imageFile != null && mounted) {
        setState(() {
          _capturedImage = imageFile;
        });
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showErrorSnackBar(context, "Failed to open camera: $e");
      }
    }
  }

  Future<void> _uploadPhoto() async {
    if (_capturedImage == null) {
      SnackbarHelper.showErrorSnackBar(context, "Please take a photo first");
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    setState(() {
      _isUploading = true;
    });

    try {
      // Try to upload for gender detection first
      final result = await authProvider.uploadGenderDetection(_capturedImage!);

      if (!mounted) return;

      if (result['success'] == true) {
        SnackbarHelper.showSuccessSnackBar(
          context,
          "Photo uploaded successfully!",
        );
        _navigateToNextScreen();
      } else {
        // If gender detection fails, try profile photo upload as fallback
        final profileResult = await authProvider.uploadProfilePhoto(
          _capturedImage!,
        );

        if (!mounted) return;

        if (profileResult['success'] == true) {
          SnackbarHelper.showSuccessSnackBar(
            context,
            "Profile photo uploaded successfully!",
          );
          _navigateToNextScreen();
        } else {
          throw Exception(
            result['error'] ?? profileResult['error'] ?? 'Upload failed',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      print('❌ Upload error: $e');
      SnackbarHelper.showErrorSnackBar(
        context,
        "Upload failed. Please try again or continue without uploading.",
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _skipPhotoUpload() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final result = await authProvider.skipGenderDetection();

      if (!mounted) return;

      // Handle both success and empty response cases
      if (result['success'] == true || result.isEmpty) {
        SnackbarHelper.showInfoSnackBar(
          context,
          "You can add your profile photo later from account settings",
        );
        _navigateToNextScreen();
      } else {
        throw Exception(result['error'] ?? 'Failed to skip photo upload');
      }
    } catch (e) {
      if (!mounted) return;

      print('❌ Skip error: $e');
      // If skip fails, still allow user to continue
      SnackbarHelper.showInfoSnackBar(
        context,
        "Continuing without photo verification",
      );
      _navigateToNextScreen();
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  // Future<void> _uploadProfilePhoto() async {
  //   if (_capturedImage == null) {
  //     SnackbarHelper.showErrorSnackBar(context, "Please take a photo first");
  //     return;
  //   }

  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);

  //   setState(() {
  //     _isUploading = true;
  //   });

  //   try {
  //     final result = await authProvider.uploadProfilePhoto(_capturedImage!);

  //     if (!mounted) return;

  //     if (result['success'] == true) {
  //       SnackbarHelper.showSuccessSnackBar(
  //         context,
  //         "Profile photo uploaded successfully!",
  //       );
  //       _navigateToNextScreen();
  //     } else {
  //       throw Exception(result['error'] ?? 'Upload failed');
  //     }
  //   } catch (e) {
  //     if (!mounted) return;

  //     print('❌ Profile photo upload error: $e');
  //     SnackbarHelper.showErrorSnackBar(context, "Upload failed: $e");
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isUploading = false;
  //       });
  //     }
  //   }
  // }

  // Future<void> _uploadForGenderDetection() async {
  //   if (_capturedImage == null) {
  //     SnackbarHelper.showErrorSnackBar(context, "Please take a photo first");
  //     return;
  //   }

  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);

  //   setState(() {
  //     _isUploading = true;
  //   });

  //   try {
  //     final result = await authProvider.uploadGenderDetection(_capturedImage!);

  //     if (!mounted) return;

  //     if (result['success'] == true) {
  //       SnackbarHelper.showSuccessSnackBar(
  //         context,
  //         "Photo verification completed!",
  //       );
  //       _navigateToNextScreen();
  //     } else {
  //       throw Exception(result['error'] ?? 'Gender detection failed');
  //     }
  //   } catch (e) {
  //     if (!mounted) return;

  //     print('❌ Gender detection error: $e');
  //     SnackbarHelper.showErrorSnackBar(context, "Verification failed: $e");
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isUploading = false;
  //       });
  //     }
  //   }
  // }

  // Future<void> _skipGenderDetection() async {
  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);

  //   setState(() {
  //     _isUploading = true;
  //   });

  //   try {
  //     final result = await authProvider.skipGenderDetection();

  //     if (!mounted) return;

  //     // Handle both success and empty response cases
  //     if (result['success'] == true || result.isEmpty) {
  //       SnackbarHelper.showInfoSnackBar(
  //         context,
  //         "You can add your profile photo later from account settings",
  //       );
  //       _navigateToNextScreen();
  //     } else {
  //       throw Exception(result['error'] ?? 'Failed to skip gender detection');
  //     }
  //   } catch (e) {
  //     if (!mounted) return;

  //     print('❌ Skip gender detection error: $e');
  //     // Allow user to continue even if skip fails
  //     SnackbarHelper.showInfoSnackBar(
  //       context,
  //       "Continuing without photo verification",
  //     );
  //     _navigateToNextScreen();
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         _isUploading = false;
  //       });
  //     }
  //   }
  // }

  void _navigateToNextScreen() {
    Navigator.of(context).push(
      NoAnimationPageRoute(builder: (context) => const TermsAndPrivacyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUploading = _isUploading;
    return ModernLoadingOverlay(
      isLoading: isUploading,
      message: "Uploading",
      style: LoadingStyle.circular,

      child: Scaffold(
        appBar: CustomAppBar(
          centerWidget: Image.asset(
            'assets/images/thirikkale_primary_logo.png',
            height: 32.0,
          ),
          onSkip: _skipPhotoUpload,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Submitting your photo helps us offer women-only ride options, creating a safer and more comfortable experience for women riders.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  const PhotoGuidelines(),
                  const SizedBox(height: 24),

                  // Display either the captured images or a placeholder
                  ProfileImagePreview(
                    capturedImage: _capturedImage,
                    cameraPermissionGranted: _cameraPermissionGranted,
                    requestCameraPermission: _requestCameraPermission,
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
                  const SizedBox(height: 8),

                  if (_capturedImage == null) ...[
                    // Take Photo Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _openFullScreenCamera,
                        style: AppButtonStyles.primaryButton,
                        child: const Text('Take Photo'),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _uploadPhoto,
                        style: AppButtonStyles.primaryButton,
                        child: const Text('Upload Photo'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _openFullScreenCamera,
                        style: AppButtonStyles.secondaryButton,
                        child: const Text('Retake Photo'),
                      ),
                    ),
                  ],

                  // // Show upload and continue buttons if we have a photo
                  // if (_capturedImage != null) ...[
                  //   const SizedBox(height: 16),

                  //   // Upload Photo Button (combines both profile and gender detection)
                  //   SizedBox(
                  //     width: double.infinity,
                  //     child: ElevatedButton(
                  //       onPressed: _isUploading ? null : _uploadPhoto,
                  //       style: AppButtonStyles.secondaryButton,
                  //       child:
                  //           _isUploading
                  //               ? const Row(
                  //                 mainAxisAlignment: MainAxisAlignment.center,
                  //                 children: [
                  //                   SizedBox(
                  //                     width: 20,
                  //                     height: 20,
                  //                     child: CircularProgressIndicator(
                  //                       strokeWidth: 2,
                  //                       valueColor:
                  //                           AlwaysStoppedAnimation<Color>(
                  //                             Colors.white,
                  //                           ),
                  //                     ),
                  //                   ),
                  //                   SizedBox(width: 8),
                  //                   Text('Uploading...'),
                  //                 ],
                  //               )
                  //               : const Text('Upload Photo'),
                  //     ),
                  //   ),

                  //   const SizedBox(height: 12),

                  //   // Continue without uploading
                  //   SizedBox(
                  //     width: double.infinity,
                  //     child: TextButton(
                  //       onPressed: _isUploading ? null : _navigateToNextScreen,
                  //       child: const Text('Continue without uploading'),
                  //     ),
                  //   ),
                  // ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
