import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/ride_booking_provider.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/booking/widgets/route_map.dart';
import 'package:thirikkale_rider/features/booking/screens/ride_tracking_screen.dart';

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
  int locatorHeightFromAbove = 30;
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
    
    // Fetch available promotions
    bookingProvider.fetchAvailablePromotions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppbarName(
        title: 'Summary',
        showBackButton: true,
      ),
      resizeToAvoidBottomInset: false,
      body: Consumer<RideBookingProvider>(
        builder: (context, bookingProvider, child) {
          return Stack(
            children: [
              // Map Section (takes up the whole screen behind the sheet)
              SizedBox.expand(
                child: RouteMap(
                  pickupAddress: bookingProvider.pickupAddress,
                  destinationAddress: bookingProvider.destinationAddress,
                  pickupLat: bookingProvider.pickupLat,
                  pickupLng: bookingProvider.pickupLng,
                  destLat: bookingProvider.destLat,
                  destLng: bookingProvider.destLng,
                  bottomPadding: MediaQuery.of(context).size.height * 0.35, // Reserve space for bottom sheet
                  showBackButton: false, // Hide back button since it's in the app bar
                ),
              ),

              // Promotion banner (only show if promotion is available)
              if (bookingProvider.hasPromotion) _buildPromotionBanner(bookingProvider),

              // Bottom sheet with ride details
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomDetailsContainer(bookingProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPromotionBanner(RideBookingProvider bookingProvider) {
    final discountPercentage = bookingProvider.promotionDiscountPercentage;
    final basePrice = bookingProvider.selectedVehicle?.price ?? 0;
    final discountAmount = (basePrice * discountPercentage / 100).round();
    
    return Positioned(
      top: kToolbarHeight - locatorHeightFromAbove, // Position it just below the app bar
      left: AppDimensions.pageHorizontalPadding,
      right: AppDimensions.pageHorizontalPadding,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontalPadding,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_offer,
              color: AppColors.white,
              size: 20,
            ),
            const SizedBox(
              width: AppDimensions.subSectionSpacingDown * 2,
            ),
            Expanded(
              child: Text(
                '${bookingProvider.promotionText ?? 'Special Offer!'} - Save LKR $discountAmount',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomDetailsContainer(RideBookingProvider bookingProvider) {
    final selectedVehicle = bookingProvider.selectedVehicle;
    final basePrice = selectedVehicle?.price ?? 0;
    final discountPercentage = bookingProvider.hasPromotion ? bookingProvider.promotionDiscountPercentage : 0.0;
    final discountAmount = (basePrice * discountPercentage / 100).round();
    final totalPrice = basePrice - discountAmount;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        // Add solid white background to prevent see-through
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar like bottom sheet
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(
                  top: AppDimensions.widgetSpacing * 0.75,
                  bottom: AppDimensions.pageHorizontalPadding,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.pageHorizontalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            
            if (selectedVehicle != null) ...[
              // Vehicle image at the top center (bigger)
              Center(
                child: Container(
                  width: 140,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.lightGrey,
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      selectedVehicle.iconAsset,
                      fit: BoxFit.contain,
                      width: 120,
                      height: 80,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Vehicle details row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side - Vehicle name and capacity
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            selectedVehicle.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.person,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          Text(
                            '${selectedVehicle.capacity}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedVehicle.estimatedTime,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  
                  // Right side - Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'LKR ${totalPrice.toInt()}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (discountAmount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'LKR ${basePrice.toInt()}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Features row (centered)
              Center(
                child: Text(
                  selectedVehicle.features.join(', '),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Separator line
              Container(
                height: 1,
                color: AppColors.lightGrey,
                margin: const EdgeInsets.symmetric(vertical: 8),
              ),
              
              // Payment method
              _buildPaymentMethodRow(bookingProvider),
              
              // Separator line after payment
              Container(
                height: 1,
                color: AppColors.lightGrey,
                margin: const EdgeInsets.symmetric(vertical: 16),
              ),
              
              // Choose Ride button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppButtonStyles.primaryButton.copyWith(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  onPressed: bookingProvider.isBookingRide 
                    ? null 
                    : () => _confirmBooking(bookingProvider),
                  child: Text(
                    bookingProvider.isBookingRide 
                      ? _getLoadingText() 
                      : 'Choose Ride',
                    style: AppTextStyles.button,
                  ),
                ),
              ),
            ],
            
                    // Bottom safe area
                    SizedBox(height: AppDimensions.widgetSpacing + 2),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentMethodRow(RideBookingProvider bookingProvider) {
    final paymentMethod = bookingProvider.selectedPaymentMethod;
    final paymentInfo = _getPaymentMethodInfo(paymentMethod);
    
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            paymentInfo['icon'] as IconData,
            color: AppColors.primaryBlue,
            size: 20,
          ),
        ),
        const SizedBox(width: AppDimensions.widgetSpacing),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                paymentInfo['name'] as String,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                bookingProvider.hasPromotion 
                  ? 'You save LKR${((bookingProvider.selectedVehicle?.price ?? 0) * bookingProvider.promotionDiscountPercentage / 100).toStringAsFixed(0)}'
                  : paymentInfo['description'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getPaymentMethodInfo(String paymentMethod) {
    switch (paymentMethod) {
      case 'cash':
        return {
          'id': 'cash',
          'name': 'Cash Payment',
          'icon': Icons.money,
          'description': 'Pay with cash when you arrive'
        };
      case 'card':
        return {
          'id': 'card',
          'name': 'Credit/Debit Card',
          'icon': Icons.credit_card,
          'description': 'Pay securely with your card'
        };
      case 'digital':
        return {
          'id': 'digital',
          'name': 'Digital Wallet',
          'icon': Icons.account_balance_wallet,
          'description': 'Use mobile wallet or UPI'
        };
      default:
        return {
          'id': 'cash',
          'name': 'Cash Payment',
          'icon': Icons.money,
          'description': 'Pay with cash when you arrive'
        };
    }
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
        final selectedVehicle = bookingProvider.selectedVehicle;
        final estimatedPrice = (selectedVehicle?.price ?? 0).toInt();
        
        // Navigate to ride tracking screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RideTrackingScreen(
              pickupAddress: widget.pickupAddress,
              destinationAddress: widget.destinationAddress,
              pickupLat: widget.pickupLat,
              pickupLng: widget.pickupLng,
              destLat: widget.destLat,
              destLng: widget.destLng,
              scheduledDateTime: widget.scheduledDateTime,
              rideType: widget.rideType,
              estimatedPrice: estimatedPrice,
            ),
          ),
        );
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
