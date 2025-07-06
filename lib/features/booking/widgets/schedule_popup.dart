import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/booking/widgets/popup_option_field.dart';

class SchedulePopup extends StatefulWidget {
  final String currentSelection;
  final Function(String) onSelectionChanged;

  const SchedulePopup({
    super.key,
    required this.currentSelection,
    required this.onSelectionChanged,
  });

  @override
  State<SchedulePopup> createState() => _SchedulePopupState();
}

class _SchedulePopupState extends State<SchedulePopup> {
  late String selectedOption;

  @override
  void initState() {
    super.initState();
    selectedOption = widget.currentSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            'How soon do you need your ride?',
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Choose the perfect timing for your journey',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Options
          PopupOptionField(
            icon: Icons.bolt,
            title: 'Right Now',
            subtitle: 'Get a ride immediately and start your journey',
            isSelected: selectedOption == 'Now',
            onTap: () {
              setState(() {
                selectedOption = 'Now';
              });
            },
          ),

          const SizedBox(height: 12),

          PopupOptionField(
            icon: Icons.schedule,
            title: 'Schedule Later',
            subtitle: 'Plan ahead for a stress-free travel experience',
            isSelected: selectedOption == 'Later',
            onTap: () {
              setState(() {
                selectedOption = 'Later';
              });
            },
          ),

          const SizedBox(height: 24),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onSelectionChanged(selectedOption);
                Navigator.pop(context);
              },
              style: AppButtonStyles.primaryButton,
              child: const Text('Confirm'),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
