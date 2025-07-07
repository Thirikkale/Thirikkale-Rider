import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class SafetyFeaturesScreen extends StatefulWidget {
  const SafetyFeaturesScreen({super.key});

  @override
  State<SafetyFeaturesScreen> createState() => _SafetyFeaturesScreenState();
}

class _SafetyFeaturesScreenState extends State<SafetyFeaturesScreen> {
  bool shareTripStatus = true;
  bool sosEnabled = true;
  bool autoCallEmergency = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: 'Safety Features',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'During your trip',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 20),
                    _buildSafetyOption(
                      icon: Icons.share_location_outlined,
                      title: 'Share Trip Status',
                      subtitle: 'Share your trip status with trusted friends and family',
                      value: shareTripStatus,
                      onChanged: (value) {
                        setState(() {
                          shareTripStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildSafetyOption(
                      icon: Icons.emergency_outlined,
                      title: 'SOS',
                      subtitle: 'Call your emergency contacts immediately',
                      value: sosEnabled,
                      onChanged: (value) {
                        setState(() {
                          sosEnabled = value;
                        });
                      },
                      showButton: true,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Safety resources',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 20),
                    _buildResourceTile(
                      icon: Icons.local_police_outlined,
                      title: 'In-app safety resources',
                      subtitle: 'Get safety tips, help, and support',
                      onTap: () {
                        // Handle safety resources
                        print('Navigate to safety resources');
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppButtonStyles.primaryButton,
                onPressed: () {
                  // Save safety settings
                  Navigator.pop(context);
                },
                child: const Text('Save Settings'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool showButton = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (showButton)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Call',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: value,
                        onChanged: onChanged,
                        activeColor: AppColors.primaryBlue,
                        activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.3),
                        inactiveThumbColor: AppColors.grey,
                        inactiveTrackColor: AppColors.lightGrey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
