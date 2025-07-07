import 'package:flutter/material.dart';

class PhotoGuidelines extends StatelessWidget {
  const PhotoGuidelines({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGuidelineItem(
          context,
          '1. ',
          'Face the camera directly with your eyes and mouth clearly visible.',
        ),
        const SizedBox(height: 8),
        _buildGuidelineItem(
          context,
          '2. ',
          'Make sure the photo is well lit, free of glare, and in focus.',
        ),
        const SizedBox(height: 8),
        _buildGuidelineItem(
          context,
          '3. ',
          'No photos of a photo, filters or alterations.',
        ),
      ],
    );
  }

  Widget _buildGuidelineItem(BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}
