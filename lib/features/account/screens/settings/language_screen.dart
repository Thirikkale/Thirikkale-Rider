import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English (Australia)'; // Default language
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _loadLanguagePreference();
  }

  Future<void> _loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('selected_language') ?? 'English (Australia)';
      _loading = false;
    });
  }

  Future<void> _saveLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', _selectedLanguage);
  }
  
  final List<Map<String, dynamic>> _languageOptions = [
    {
      'title': 'English (Australia)',
      'subtitle': 'English (Australia)',
      'value': 'English (Australia)',
    },
    {
      'title': 'English (Canada)',
      'subtitle': 'English (Canada)', 
      'value': 'English (Canada)',
    },
    {
      'title': 'English (India)',
      'subtitle': 'English (India)',
      'value': 'English (India)',
    },
    {
      'title': 'English (Ireland)', 
      'subtitle': 'English (Ireland)',
      'value': 'English (Ireland)',
    },
    {
      'title': 'English (New Zealand)',
      'subtitle': 'English (New Zealand)',
      'value': 'English (New Zealand)',
    },
    {
      'title': 'English (Singapore)',
      'subtitle': 'English (Singapore)',
      'value': 'English (Singapore)',
    },
    {
      'title': 'English (South Africa)',
      'subtitle': 'English (South Africa)',
      'value': 'English (South Africa)',
    },
    {
      'title': 'English (US)',
      'subtitle': 'English (US)',
      'value': 'English (US)',
    },
    {
      'title': 'Deutsch',
      'subtitle': 'German',
      'value': 'Deutsch',
    },
    {
      'title': 'Italiano',
      'subtitle': 'Italian',
      'value': 'Italiano',
    },
    {
      'title': 'Nederlands',
      'subtitle': 'Dutch',
      'value': 'Nederlands',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: "Language",
        showBackButton: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
                  child: TextField(
                    onChanged: (value) {
                      // Handle search
                      print('Searching for: $value');
                    },
                    decoration: InputDecoration(
                      hintText: 'Search',
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
                ),
                // Language list
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.pageHorizontalPadding,
                    ),
                    itemCount: _languageOptions.length,
                    itemBuilder: (context, index) {
                      final option = _languageOptions[index];
                      return _buildLanguageOption(option);
                    },
                  ),
                ),
                // Save button at bottom
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _saveLanguagePreference();
                        SnackbarHelper.showSuccessSnackBar(context, 'Language saved!', showAction: false);
                        print('Selected language: $_selectedLanguage');
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
  
  Widget _buildLanguageOption(Map<String, dynamic> option) {
    final bool isSelected = _selectedLanguage == option['value'];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedLanguage = option['value'];
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
                groupValue: _selectedLanguage,
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
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
                    if (option['subtitle'] != null && option['subtitle'] != option['title']) ...[
                      const SizedBox(height: 2),
                      Text(
                        option['subtitle'],
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
