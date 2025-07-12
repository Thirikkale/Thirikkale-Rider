import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/activity/widgets/rebook_btn.dart';

class RideHistoryCard extends StatelessWidget {
  final String destination;
  final String date;
  final String price;
  final String vehicleIcon;
  final VoidCallback onPressed;
  final String? mapImage;

  const RideHistoryCard({
    super.key,
    required this.destination,
    required this.date,
    required this.price,
    required this.vehicleIcon,
    required this.onPressed,
    this.mapImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
      decoration: BoxDecoration(
        color: mapImage != null ? AppColors.white : AppColors.white,
        borderRadius: mapImage != null ? BorderRadius.circular(12) : null,
        boxShadow:
            mapImage != null
                ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
                : null, // No shadow if there's no image
        border:
            mapImage == null
                ? Border(
                  bottom: BorderSide(color: AppColors.subtleGrey, width: 1.0),
                )
                : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (mapImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                mapImage!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          if (mapImage != null)
            const SizedBox(height: AppDimensions.widgetSpacing),
          Row(
            children: [
              if (mapImage == null)
                Image.asset(vehicleIcon, width: 40, height: 40),
              if (mapImage == null) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      destination,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$date\n$price',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              RebookBtn(onPressed: onPressed),
            ],
          ),
        ],
      ),
    );
  }
}
