import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/account/screens/settings/widgets/settings_subheader.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';


class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String _selectedTheme = 'Light'; // Default theme
  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedTheme = prefs.getString('selected_theme') ?? 'Light';
    });
  }

  Future<void> _saveThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_theme', _selectedTheme);
    if (mounted) {
      SnackbarHelper.showSuccessSnackBar(context, 'Theme saved successfully!');
    }
  }
  
  final List<Map<String, dynamic>> _themeOptions = [
    {
      'title': 'Light',
      'description': 'Light theme',
      'value': 'Light',
    },
    {
      'title': 'Dark',
      'description': 'Dark theme',
      'value': 'Dark',
    },
    {
      'title': 'System Default',
      'description': 'Use system theme',
      'value': 'System Default',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: "Appearance",
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
                    const SettingsSubheader(title: 'Theme'),
                    
                    // Theme options
                    // Theme options
                    ..._themeOptions.map((option) => _buildThemeOption(option)),
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
                  developer.log('Selected theme: $_selectedTheme', name: 'AppearanceScreen');
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('selected_theme', _selectedTheme);
                  if (mounted) {
                    SnackbarHelper.showSuccessSnackBar(context, 'Theme saved successfully!', showAction: false);
                  }
                  await Future.delayed(const Duration(milliseconds: 500));
                  if (mounted) Navigator.pop(context);
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
  
  Widget _buildThemeOption(Map<String, dynamic> option) {
    final bool isSelected = _selectedTheme == option['value'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTheme = option['value'];
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : AppColors.subtleGrey,
            borderRadius: BorderRadius.circular(8),
            border: isSelected 
                ? Border.all(color: AppColors.primaryBlue, width: 2)
                : null,
          ),
          child: Row(
            children: [
              Radio<String>(
                value: option['value'],
                groupValue: _selectedTheme,
                onChanged: (value) {
                  setState(() {
                    _selectedTheme = value!;
                  });
                },
                activeColor: AppColors.primaryBlue,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['title'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                      ),
                    ),
                    if (option['description'] != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        option['description'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
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
