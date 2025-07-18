import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/ride_booking_provider.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class RideSummaryScreen extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? destLat;
  final double? destLng;
  final DateTime scheduledDateTime;
  final String? rideType;

  const RideSummaryScreen({
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
  State<RideSummaryScreen> createState() => _RideSummaryScreenState();
}

class _RideSummaryScreenState extends State<RideSummaryScreen> {
  @override
  void initState() {
    super.initState();
    // Ensure the provider has the trip details
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBookingProvider();
    });
  }

  void _initializeBookingProvider() {
    final bookingProvider = Provider.of<RideBookingProvider>(
      context,
      listen: false,
    );
    
    // Set trip details if not already set
    if (bookingProvider.pickupAddress != widget.pickupAddress ||
        bookingProvider.destinationAddress != widget.destinationAddress) {
      bookingProvider.setTripDetails(
        pickup: widget.pickupAddress,
        destination: widget.destinationAddress,
        pickupLat: widget.pickupLat,
        pickupLng: widget.pickupLng,
        destLat: widget.destLat,
        destLng: widget.destLng,
      );
    }
    
    // Set scheduled datetime
    bookingProvider.setScheduledDateTime(widget.scheduledDateTime);
    
    // Determine if this is an immediate ride or scheduled ride
    final now = DateTime.now();
    final isImmediate = widget.scheduledDateTime.difference(now).inMinutes < 5; // If within 5 minutes, consider it immediate
    
    bookingProvider.setScheduleType(isImmediate ? 'now' : 'schedule_later');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppbarName(
        title: 'Booking Summary',
        showBackButton: true,
      ),
      body: Consumer<RideBookingProvider>(
        builder: (context, bookingProvider, child) {
          return Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Trip Details Card
                        _buildTripDetailsCard(),
                        const SizedBox(height: AppDimensions.widgetSpacing),
                        
                        // Scheduled Time Card
                        _buildScheduledTimeCard(),
                        const SizedBox(height: AppDimensions.widgetSpacing),
                        
                        // Vehicle Details Card
                        _buildVehicleDetailsCard(bookingProvider),
                        const SizedBox(height: AppDimensions.widgetSpacing),
                        
                        // Payment Details Card
                        _buildPaymentDetailsCard(bookingProvider),
                        const SizedBox(height: AppDimensions.widgetSpacing),
                        
                        // Price Breakdown Card
                        _buildPriceBreakdownCard(bookingProvider),
                        const SizedBox(height: AppDimensions.sectionSpacing),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Fixed bottom button
              Container(
                padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                    top: BorderSide(color: AppColors.lightGrey),
                  ),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: AppButtonStyles.primaryButton,
                      onPressed: bookingProvider.isBookingRide 
                        ? null 
                        : () => _confirmBooking(bookingProvider),
                      child: Text(
                        bookingProvider.isBookingRide 
                          ? _getLoadingText() 
                          : _getButtonText(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTripDetailsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.route,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.subSectionSpacingDown),
                Text(
                  'Trip Details',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.widgetSpacing),
            
            // Pickup location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppDimensions.subSectionSpacingDown),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Location',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.pickupAddress,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.widgetSpacing),
            
            // Destination location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppDimensions.subSectionSpacingDown),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destination',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.destinationAddress,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledTimeCard() {
    final now = DateTime.now();
    final isImmediate = widget.scheduledDateTime.difference(now).inMinutes < 5;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isImmediate ? Icons.directions_car : Icons.schedule,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.subSectionSpacingDown),
                Text(
                  isImmediate ? 'Ride Type' : 'Scheduled Time',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.widgetSpacing),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isImmediate ? 'Ride Request' : 'Pickup Time',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isImmediate ? 'Book Now' : _formatDateTime(widget.scheduledDateTime),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetailsCard(RideBookingProvider bookingProvider) {
    final selectedVehicle = bookingProvider.selectedVehicle;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.directions_car,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.subSectionSpacingDown),
                Text(
                  'Vehicle',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.widgetSpacing),
            
            if (selectedVehicle != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    // Vehicle icon/image
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: AppColors.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.widgetSpacing),
                    
                    // Vehicle details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedVehicle.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            selectedVehicle.features.join(' • '),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Estimated time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          selectedVehicle.estimatedTime,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ETA',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else ...[
              Text(
                'No vehicle selected',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsCard(RideBookingProvider bookingProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getPaymentIcon(bookingProvider.selectedPaymentMethod),
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.subSectionSpacingDown),
                Text(
                  'Payment Method',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.widgetSpacing),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primaryBlue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getPaymentIcon(bookingProvider.selectedPaymentMethod),
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                  const SizedBox(width: AppDimensions.widgetSpacing),
                  Text(
                    _getPaymentMethodDisplay(bookingProvider.selectedPaymentMethod),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdownCard(RideBookingProvider bookingProvider) {
    final selectedVehicle = bookingProvider.selectedVehicle;
    final basePrice = selectedVehicle?.price ?? 0;
    final serviceFee = (basePrice * 0.1).round();
    final totalPrice = basePrice + serviceFee;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.widgetSpacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: AppDimensions.subSectionSpacingDown),
                Text(
                  'Price Breakdown',
                  style: AppTextStyles.heading3.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.widgetSpacing),
            
            _buildPriceRow('Base Fare', 'Rs. $basePrice'),
            _buildPriceRow('Service Fee', 'Rs. $serviceFee'),
            const Divider(color: AppColors.lightGrey),
            _buildPriceRow('Total', 'Rs. $totalPrice', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : AppTextStyles.bodyMedium,
          ),
          Text(
            amount,
            style: isTotal
                ? AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  )
                : AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodDisplay(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Cash Payment';
      case 'card':
        return 'Credit/Debit Card';
      case 'wallet':
        return 'Digital Wallet';
      default:
        return paymentMethod;
    }
  }

  IconData _getPaymentIcon(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return Icons.money;
      case 'card':
        return Icons.credit_card;
      case 'wallet':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final scheduleDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    String dateText;
    if (scheduleDate == today) {
      dateText = 'Today';
    } else if (scheduleDate == tomorrow) {
      dateText = 'Tomorrow';
    } else {
      // Format date manually
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dateText = '${months[dateTime.month - 1]} ${dateTime.day}, ${dateTime.year}';
    }
    
    // Format time manually
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final timeText = '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    
    return '$dateText at $timeText';
  }

  String _getButtonText() {
    final now = DateTime.now();
    final isImmediate = widget.scheduledDateTime.difference(now).inMinutes < 5;
    return isImmediate ? 'Book Now' : 'Schedule Ride';
  }

  String _getLoadingText() {
    final now = DateTime.now();
    final isImmediate = widget.scheduledDateTime.difference(now).inMinutes < 5;
    return isImmediate ? 'Booking Ride...' : 'Scheduling Ride...';
  }

  void _confirmBooking(RideBookingProvider bookingProvider) async {
    try {
      await bookingProvider.bookRide();

      if (mounted) {
        final now = DateTime.now();
        final isImmediate = widget.scheduledDateTime.difference(now).inMinutes < 5;
        
        // Show success message
        SnackbarHelper.showSuccessSnackBar(
          context,
          isImmediate 
            ? 'Ride booked successfully! Driver will arrive in ${bookingProvider.selectedVehicle?.estimatedTime ?? "a few minutes"}'
            : 'Ride scheduled successfully! You will receive a confirmation shortly.',
        );

        // Navigate back to the main screen
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        final now = DateTime.now();
        final isImmediate = widget.scheduledDateTime.difference(now).inMinutes < 5;
        
        SnackbarHelper.showErrorSnackBar(
          context,
          isImmediate 
            ? 'Failed to book ride: ${e.toString()}'
            : 'Failed to schedule ride: ${e.toString()}',
        );
      }
    }
  }
}
