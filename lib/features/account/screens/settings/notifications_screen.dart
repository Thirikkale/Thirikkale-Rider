import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/account/screens/settings/widgets/settings_subheader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    //similate a delay for loading preferences
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _rideStatusUpdates = prefs.getBool('notif_ride_status_updates') ?? true;
      _rideChanges = prefs.getBool('notif_ride_changes') ?? false;
      _promotionalOffers = prefs.getBool('notif_promotional_offers') ?? true;
      _appUpdates = prefs.getBool('notif_app_updates') ?? false;
      _newsAndArticles = prefs.getBool('notif_news_and_articles') ?? false;
      _loading = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_ride_status_updates', _rideStatusUpdates);
    await prefs.setBool('notif_ride_changes', _rideChanges);
    await prefs.setBool('notif_promotional_offers', _promotionalOffers);
    await prefs.setBool('notif_app_updates', _appUpdates);
    await prefs.setBool('notif_news_and_articles', _newsAndArticles);
    if (!mounted) return;
    SnackbarHelper.showSuccessSnackBar(context, 'Notification preferences saved!', showAction: false);
    await Future.delayed(const Duration(milliseconds: 500));
    // if (mounted) Navigator.pop(context);
  }
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SettingsSubheader(title: 'Ride Updates'),
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
                          const SettingsSubheader(title: 'Promotions & Offers'),
                          _buildNotificationTile(
                            'Promotional Offers',
                            'Stay informed about special offers, discounts and promotions from our partners',
                            _promotionalOffers,
                            (value) => setState(() => _promotionalOffers = value),
                          ),
                          _buildNotificationTile(
                            'App Updates',
                            'Get notified about new app features, improvements and security updates',
                            _appUpdates,
                            (value) => setState(() => _appUpdates = value),
                          ),
                          const SizedBox(height: AppDimensions.subSectionSpacing),
                          const SettingsSubheader(title: 'News & Information'),
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
                      onPressed: () async {
                        await _savePreferences();
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
                  style: AppTextStyles.bodyMedium.copyWith(
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
            activeTrackColor: AppColors.primaryBlue.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.grey,
            inactiveTrackColor: AppColors.lightGrey,
          ),
        ],
      ),
    );
  }
}
