import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/dialog_helper.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/account/screens/settings/widgets/settings_subheader.dart';

class WorkLocationScreen extends StatefulWidget {
  const WorkLocationScreen({super.key});

  @override
  State<WorkLocationScreen> createState() => _WorkLocationScreenState();
}

class _WorkLocationScreenState extends State<WorkLocationScreen> {
  final TextEditingController _locationController = TextEditingController();
  
  void _showAddressConfirmationDialog(String address) {
    DialogHelper.showCheckboxDialog(
      context: context,
      title: 'Set Work Location',
      content: 'Would you like to set this address as your work location?\n\n$address',
      checkboxLabel: 'Set as default work location',
      initialCheckboxValue: true,
      confirmText: 'Set Location',
      cancelText: 'Cancel',
      titleIcon: Icons.work,
      onConfirm: (isSetAsDefault) {
        // Handle the address confirmation
        if (isSetAsDefault) {
          // In a real app, you would save this to your data source
          SnackbarHelper.showSuccessSnackBar(
            context,
            'Work location set successfully!',
          );
        } else {
          SnackbarHelper.showSuccessSnackBar(
            context,
            'Address saved!',
          );
        }
      },
    );
  }
  
  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: "Set work location",
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSubheader(title: 'Search'),
            TextField(
              controller: _locationController,
              autofocus: true,
              onChanged: (value) {
                // Handle search
                print('Searching for: $value');
              },
              onSubmitted: (value) {
                // Handle when user submits the search
                if (value.isNotEmpty) {
                  _showAddressConfirmationDialog(value);
                }
              },
              decoration: InputDecoration(
                hintText: 'Enter your work address',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: AppColors.subtleGrey,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            
            // Current location option
            InkWell(
              onTap: () {
                // Handle current location selection
                _showAddressConfirmationDialog('Current Location: Latitude, Longitude');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.subtleGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.my_location,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use current location',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'We\'ll use your current location as work',
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
            
            const SizedBox(height: 24),
            
            // Map option
            InkWell(
              onTap: () {
                // Handle map selection
                _showAddressConfirmationDialog('Selected Address from Map: 789 Business Blvd, Springfield, IL 62701');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.subtleGrey,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Choose on map',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
