import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class ProfileHeader extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String subtitle;

  const ProfileHeader({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(radius: 50, backgroundImage: AssetImage(imageUrl)),
          const SizedBox(height: 12),
          Text(name, style: AppTextStyles.heading2),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
