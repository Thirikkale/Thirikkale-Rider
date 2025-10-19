import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class ScheduledRideCard extends StatelessWidget {
  final String destination;
  final String pickupLocation;
  final String scheduledDate;
  final String scheduledTime;
  final String estimatedFare;
  final String vehicleIcon;
  final String? status;
  final String? driverId; // Added driverId
  final VoidCallback onCardTap;
  final VoidCallback? onCancelPressed;

  const ScheduledRideCard({
    super.key,
    required this.destination,
    required this.pickupLocation,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.estimatedFare,
    required this.vehicleIcon,
    this.status,
    this.driverId, // Added driverId
    required this.onCardTap,
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCardTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(vehicleIcon, width: 32, height: 32),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Scheduled Ride',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (status != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getStatusText(status!),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$scheduledDate at $scheduledTime',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLocationInfo(
              icon: Icons.location_on_outlined,
              title: 'Pickup',
              location: pickupLocation,
              color: AppColors.primaryGreen,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: SizedBox(
                height: 16,
                child: VerticalDivider(
                  width: 1,
                  thickness: 2,
                  color: AppColors.subtleGrey,
                ),
              ),
            ),
            _buildLocationInfo(
              icon: Icons.location_on,
              title: 'Destination',
              location: destination,
              color: AppColors.primaryBlue,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated Fare',
                      style: AppTextStyles.bodySmall,
                    ),
                    Text(
                      estimatedFare,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (onCancelPressed != null && (status == 'SCHEDULED' || status == 'GROUPING')) ...[
                  TextButton(
                    onPressed: onCancelPressed,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      backgroundColor: AppColors.error.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ] else ...[
                  const SizedBox.shrink(),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationInfo({
    required IconData icon,
    required String title,
    required String location,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall,
              ),
              Text(
                location,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CANCELLED':
        return AppColors.error;
      case 'DISPATCHED':
        return AppColors.primaryBlue;
      case 'CONFIRMED':
        return AppColors.primaryGreen;
      case 'PENDING':
        return AppColors.warning;
      case 'SCHEDULED':
        return AppColors.primaryBlue;
      case 'GROUPING':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'CANCELLED':
        return 'Cancelled';
      case 'DISPATCHED':
        return 'Dispatched';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PENDING':
        return 'Pending';
      case 'SCHEDULED':
        return 'Scheduled';
      case 'GROUPING':
        return 'Grouping';
      default:
        return status;
    }
  }
}