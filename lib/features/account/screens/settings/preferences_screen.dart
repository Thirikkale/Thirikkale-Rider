import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/account/screens/settings/widgets/settings_subheader.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  String _selectedRideType = 'Solo'; // Default ride type
  String _selectedVehicle = 'Tuk'; // Default vehicle
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedRideType = prefs.getString('default_ride_type') ?? 'Solo';
      _selectedVehicle = prefs.getString('default_vehicle') ?? 'Tuk';
      _loading = false;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('default_ride_type', _selectedRideType);
    await prefs.setString('default_vehicle', _selectedVehicle);
    if (mounted) {
      SnackbarHelper.showSuccessSnackBar(
        context,
        'Preferences saved successfully!',
      );
    }
  }

  final List<Map<String, dynamic>> _rideTypeOptions = [
    {
      'title': 'Solo',
      'description': 'Share your trip status with trusted contacts',
      'value': 'Solo',
      'icon': Icons.person,
    },
    {
      'title': 'Shared',
      'description': 'Share your trip status with trusted contacts',
      'value': 'Shared',
      'icon': Icons.people,
    },
  ];

  final List<Map<String, dynamic>> _vehicleOptions = [
    {
      'title': 'Tuk',
      'description': 'Quick and affordable three-wheeler',
      'value': 'Tuk',
      'icon': 'assets/icons/vehicles/tuk.png',
    },
    {
      'title': 'Ride',
      'description': 'Comfortable and reliable rides',
      'value': 'Ride',
      'icon': 'assets/icons/vehicles/ride.png',
    },
    {
      'title': 'Rush',
      'description': 'Fast routes during peak hours',
      'value': 'Rush',
      'icon': 'assets/icons/vehicles/rush.png',
    },
    {
      'title': 'Prime',
      'description': 'Premium cars with top drivers',
      'value': 'Prime',
      'icon': 'assets/icons/vehicles/primeRide.png',
    },
    {
      'title': 'Squad',
      'description': 'Large group sharing (4-6 people)',
      'value': 'Squad',
      'icon': 'assets/icons/vehicles/squad.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(title: "Preference", showBackButton: true),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          AppDimensions.pageHorizontalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SettingsSubheader(title: 'Ride Type'),
                            ..._rideTypeOptions.map(
                              (option) => _buildRideTypeOption(option),
                            ),
                            const SizedBox(
                              height: AppDimensions.sectionSpacing,
                            ),
                            const SettingsSubheader(title: 'Default Vehicle'),
                            ..._vehicleOptions.map(
                              (option) => _buildVehicleOption(option),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(
                      AppDimensions.pageHorizontalPadding,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          developer.log(
                            'Selected ride type: $_selectedRideType',
                            name: 'PreferencesScreen',
                          );
                          developer.log(
                            'Selected vehicle: $_selectedVehicle',
                            name: 'PreferencesScreen',
                          );
                          await _savePreferences();
                          // Navigator.pop(context);
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

  Widget _buildRideTypeOption(Map<String, dynamic> option) {
    final bool isSelected = _selectedRideType == option['value'];
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.widgetSpacing),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRideType = option['value'];
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.widgetSpacing,
            vertical: AppDimensions.widgetSpacing,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : AppColors.subtleGrey,
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected
                    ? Border.all(color: AppColors.primaryBlue, width: 2)
                    : null,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: option['value'],
                groupValue: _selectedRideType,
                onChanged: (value) {
                  setState(() {
                    _selectedRideType = value!;
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
              const SizedBox(width: AppDimensions.widgetSpacing),
              Icon(
                option['icon'],
                color:
                    isSelected
                        ? AppColors.primaryBlue
                        : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: AppDimensions.widgetSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['title'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option['description'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleOption(Map<String, dynamic> option) {
    final bool isSelected = _selectedVehicle == option['value'];

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.widgetSpacing),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedVehicle = option['value'];
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.widgetSpacing,
            vertical: AppDimensions.widgetSpacing,
          ),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : AppColors.subtleGrey,
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected
                    ? Border.all(color: AppColors.primaryBlue, width: 2)
                    : null,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: option['value'],
                groupValue: _selectedVehicle,
                onChanged: (value) {
                  setState(() {
                    _selectedVehicle = value!;
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
              const SizedBox(width: AppDimensions.widgetSpacing),
              Container(
                width: 60,
                height: 60,
                padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Image.asset(option['icon'], fit: BoxFit.contain),
              ),
              const SizedBox(width: AppDimensions.widgetSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['title'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color:
                            isSelected
                                ? AppColors.primaryBlue
                                : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option['description'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
