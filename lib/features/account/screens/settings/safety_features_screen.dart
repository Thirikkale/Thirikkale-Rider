import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/account/screens/settings/widgets/settings_subheader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/account/screens/settings/learn_about_safety_screen.dart';
// import 'package:thirikkale_rider/features/account/widgets/account_info_tile.dart';

class SafetyFeaturesScreen extends StatefulWidget {
  const SafetyFeaturesScreen({super.key});

  @override
  State<SafetyFeaturesScreen> createState() => _SafetyFeaturesScreenState();
}

class _SafetyFeaturesScreenState extends State<SafetyFeaturesScreen> {
  bool _loading = true;
  bool shareTripStatus = true;
  bool sosEnabled = true;
  bool autoCallEmergency = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      shareTripStatus = prefs.getBool('safety_share_trip_status') ?? true;
      sosEnabled = prefs.getBool('safety_sos_enabled') ?? true;
      autoCallEmergency = prefs.getBool('safety_auto_call_emergency') ?? false;
      _loading = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('safety_share_trip_status', shareTripStatus);
    await prefs.setBool('safety_sos_enabled', sosEnabled);
    await prefs.setBool('safety_auto_call_emergency', autoCallEmergency);
    if (!mounted) return;
    SnackbarHelper.showSuccessSnackBar(context, 'Safety preferences saved!', showAction: false);
    await Future.delayed(const Duration(milliseconds: 500));
    // if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: 'Safety Features',
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
                          const SettingsSubheader(title: 'During your trip'),
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
                          _buildSafetyOption(
                            icon: Icons.phone_in_talk_outlined,
                            title: 'Auto Call Emergency',
                            subtitle: 'Automatically call emergency contacts if needed',
                            value: autoCallEmergency,
                            onChanged: (value) {
                              setState(() {
                                autoCallEmergency = value;
                              });
                            },
                          ),
                          const SizedBox(height: AppDimensions.subSectionSpacing),
                          const SettingsSubheader(title: 'Safety resources'),
                          _buildResourceTile(
                            icon: Icons.shield_outlined,
                            title: 'Learn about safety',
                            subtitle: 'View tips and resources to stay safe during your trip',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LearnAboutSafetyScreen(),
                                ),
                              );
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
                      onPressed: () async {
                        await _savePreferences();
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.subtleGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
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
                  subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
