import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/providers/location_provider.dart';

class LocationErrorCard extends StatelessWidget {
  final LocationProvider locationProvider;
  final VoidCallback onRetryLocation;

  const LocationErrorCard({
    super.key,
    required this.locationProvider,
    required this.onRetryLocation,
  });

  @override
  Widget build(BuildContext context) {
    if (locationProvider.locationError == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_off,
            color: AppColors.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Access Needed',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  locationProvider.locationError!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              TextButton(
                onPressed: onRetryLocation,
                child: const Text('Retry'),
              ),
              TextButton(
                onPressed: () => locationProvider.openLocationSettings(),
                child: const Text('Settings'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}