import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class LocationConnector extends StatelessWidget {
  const LocationConnector({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pickup point (circle)
          Container(
            margin: const EdgeInsets.only(top: 16),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          
          // Connecting line
          Expanded(
            child: Container(
              width: 2.5,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),

          // Destination point (square)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}