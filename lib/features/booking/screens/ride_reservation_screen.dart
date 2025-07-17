import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/booking/screens/ride_selection_screen.dart';

class RideReservationScreen extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? destLat;
  final double? destLng;
  final DateTime scheduledDateTime;
  final String? rideType;

  const RideReservationScreen({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    this.pickupLat,
    this.pickupLng,
    this.destLat,
    this.destLng,
    required this.scheduledDateTime,
    this.rideType,
  });

  @override
  State<RideReservationScreen> createState() => _RideReservationScreenState();
}

class _RideReservationScreenState extends State<RideReservationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: const CustomAppbarName(
        title: 'Schedule ride',
        showBackButton: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.black,
              Color(0xFF1A1A1A),
            ],
          ),
        ),
        child: Column(
          children: [
            // Hero Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/ride_hero_image.png'), // You'll need to add this
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Content Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reserve Title
                    Text(
                      'Reserve',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.widgetSpacing),

                    // Schedule Info
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: AppColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.subSectionSpacingDown),
                        Text(
                          'Choose your exact pickup time up to 30 days in advance',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.widgetSpacing),

                    // Wait Time Info
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: AppColors.white,
                          size: 20,
                        ),
                        const SizedBox(width: AppDimensions.subSectionSpacingDown),
                        Text(
                          'Extra wait time included to meet your ride',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.sectionSpacing),

                    // Ride Details Card
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scheduled for:',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(widget.scheduledDateTime),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.subSectionSpacingDown),
                          Text(
                            'From: ${widget.pickupAddress}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'To: ${widget.destinationAddress}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Reserve Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGrey,
                          foregroundColor: AppColors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _reserveRide,
                        child: Text(
                          'Reserve a ride',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.widgetSpacing),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : hour == 0 ? 12 : hour;
    
    return '$month $day, ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  void _reserveRide() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideSelectionScreen(
          pickupLocation: widget.pickupAddress,
          dropoffLocation: widget.destinationAddress,
          selectedDate: widget.scheduledDateTime,
          selectedTime: TimeOfDay.fromDateTime(widget.scheduledDateTime),
        ),
      ),
    );
  }
}
