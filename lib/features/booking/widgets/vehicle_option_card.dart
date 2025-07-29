import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/booking/models/vehicle_option.dart';

class VehicleOptionCard extends StatelessWidget {
  final VehicleOption vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const VehicleOptionCard({
    super.key,
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          // Only set vehicle type, do not set isRideScheduled or any other flags
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? AppColors.primaryBlue.withValues(alpha: 0.1)
                    : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.primaryBlue : AppColors.lightGrey,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Vehicle image
              Image.asset(vehicle.iconAsset, fit: BoxFit.contain, width: 80.0,),

              const SizedBox(width: 12),

              // Vehicle info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          vehicle.name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                isSelected
                                    ? AppColors.primaryBlue
                                    : AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(width: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            Text(
                              '${vehicle.capacity}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    Text(
                      vehicle.estimatedTime,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              Text(
                'Rs.${vehicle.defaultPricePerUnit.toInt()}',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color:
                      isSelected
                          ? AppColors.primaryBlue
                          : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
