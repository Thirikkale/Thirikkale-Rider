import 'dart:io';
import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class ProfileImagePreview extends StatelessWidget {
  final File? capturedImage;

  const ProfileImagePreview({
    Key? key,
    required this.capturedImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (capturedImage != null) {
      return _buildCapturedImageView();
    } else {
      return _buildPlaceholderView(context);
    }
  }

  Widget _buildCapturedImageView() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primaryBlue, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.file(
          capturedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildPlaceholderView(BuildContext context) {
    return Container(
      height: 300,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildReadyToCapture(context),
    );
  }

  Widget _buildReadyToCapture(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 64, color: Colors.grey[500]),
        const SizedBox(height: 16),
        Text(
          'Tap "Take Photo" to capture\nyour profile picture',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[700]),
        ),
      ],
    );
  }
}
