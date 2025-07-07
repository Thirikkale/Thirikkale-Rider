import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/booking/widgets/popup_option_field.dart';

class RideTypePopup extends StatefulWidget {
  final String currentSelection;
  final Function(String) onSelectionChanged;

  const RideTypePopup({
    super.key,
    required this.currentSelection,
    required this.onSelectionChanged,
  });

  @override
  State<RideTypePopup> createState() => _RideTypePopupState();
}

class _RideTypePopupState extends State<RideTypePopup> {
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
            'Choose your ride preference',
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Select between solo comfort or shared savings',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 24),

          // Options
          PopupOptionField(
            icon: Icons.person,
            title: 'Solo',
            subtitle: 'Ride alone with complete privacy and comfort',
            isSelected: selectedOption == 'Solo',
            onTap: () {
              setState(() {
                selectedOption = 'Solo';
              });
            },
          ),

          const SizedBox(height: 12),

          PopupOptionField(
            icon: Icons.people,
            title: 'Shared',
            subtitle: 'Share your ride and split the cost with others',
            isSelected: selectedOption == 'Shared',
            onTap: () {
              setState(() {
                selectedOption = 'Shared';
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
