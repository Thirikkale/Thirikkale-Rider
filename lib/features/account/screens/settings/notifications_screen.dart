import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _rideStatusUpdates = true;
  bool _rideChanges = false;
  bool _promotionalOffers = true;
  bool _appUpdates = false;
  bool _newsAndArticles = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: "Notifications",
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
                    _buildSectionHeader('Ride Updates'),
                    _buildNotificationTile(
                      'Ride Status Updates',
                      'Track your ride in real-time, get notifications when driver arrives',
                      _rideStatusUpdates,
                      (value) => setState(() => _rideStatusUpdates = value),
                    ),
                    _buildNotificationTile(
                      'Ride Changes',
                      'Such as driver cancellations or route changes',
                      _rideChanges,
                      (value) => setState(() => _rideChanges = value),
                    ),
                    
                    const SizedBox(height: AppDimensions.subSectionSpacing),
                    
                    _buildSectionHeader('Promotions & Offers'),
                    _buildNotificationTile(
                      'Promotional Offers',
                      'Stay informed about special offers, discounts and promotions from our partners',
                      _promotionalOffers,
                      (value) => setState(() => _promotionalOffers = value),
                    ),
                    
                    const SizedBox(height: AppDimensions.subSectionSpacing),
                    
                    _buildNotificationTile(
                      'App Updates',
                      'Get notified about new app features, improvements and security updates',
                      _appUpdates,
                      (value) => setState(() => _appUpdates = value),
                    ),
                    
                    const SizedBox(height: AppDimensions.subSectionSpacing),
                    
                    _buildSectionHeader('News & Information'),
                    _buildNotificationTile(
                      'News & Articles',
                      'Be the first to hear about city news, traffic patterns and travel advice',
                      _newsAndArticles,
                      (value) => setState(() => _newsAndArticles = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Save button at bottom
          Padding(
            padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle save
                  print('Saving notification preferences...');
                  Navigator.pop(context);
                },
                style: AppButtonStyles.primaryButton,
                child: const Text('Save'),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: AppTextStyles.bodyLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
  
  Widget _buildNotificationTile(
    String title,
    String description,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.subtleGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryBlue,
            activeTrackColor: AppColors.primaryBlue.withOpacity(0.3),
            inactiveThumbColor: AppColors.grey,
            inactiveTrackColor: AppColors.lightGrey,
          ),
        ],
      ),
    );
  }
}
