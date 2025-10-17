import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/ride_booking_provider.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/booking/widgets/vehicle_option_card.dart';
import 'package:thirikkale_rider/features/booking/widgets/payment_method_selector.dart';

class RideOptionsBottomSheet extends StatelessWidget {
  final VoidCallback onPaymentMethodTap;
  final Function(RideBookingProvider) onBookRide;
  final ScrollController scrollController;
  final Map<String, double> vehiclePricing;
  final bool isLoadingPricing;

  const RideOptionsBottomSheet({
    super.key,
    required this.onPaymentMethodTap,
    required this.onBookRide,
    required this.scrollController,
    this.vehiclePricing = const {},
    this.isLoadingPricing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RideBookingProvider>(
      builder: (context, bookingProvider, child) {
        return Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Choose a ride',
                  style: AppTextStyles.heading2.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Scrollable vehicle options section
            Expanded(child: _buildVehicleOptions(bookingProvider)),

            // Fixed bottom section with payment and booking button
            _buildFixedBottomSection(bookingProvider),
          ],
        );
      },
    );
  }

  Widget _buildVehicleOptions(RideBookingProvider bookingProvider) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: bookingProvider.vehicleOptions.length,
      itemBuilder: (context, index) {
        final vehicle = bookingProvider.vehicleOptions[index];
        final price = vehiclePricing[vehicle.id] ?? vehicle.defaultPricePerUnit;
        
        return VehicleOptionCard(
          vehicle: vehicle,
          isSelected: bookingProvider.selectedVehicle?.id == vehicle.id,
          onTap: () => bookingProvider.setSelectVehicle(vehicle),
          overridePrice: price,
          isLoadingPrice: isLoadingPricing,
        );
      },
    );
  }

  Widget _buildFixedBottomSection(RideBookingProvider bookingProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.lightGrey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            // Distance and Duration info (if available)
            if (bookingProvider.routeDistanceText != null || 
                bookingProvider.routeDurationText != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (bookingProvider.routeDistanceText != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.route,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bookingProvider.routeDistanceText!,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    if (bookingProvider.routeDistanceText != null &&
                        bookingProvider.routeDurationText != null)
                      const SizedBox(width: 16),
                    if (bookingProvider.routeDurationText != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            bookingProvider.routeDurationText!,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              
            // Payment method selector
            PaymentMethodSelector(
              selectedMethod: bookingProvider.selectedPaymentMethod,
              onTap: onPaymentMethodTap,
            ),

            const SizedBox(height: 16),          // Book ride button
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    bookingProvider.canBookRide &&
                            !bookingProvider.isBookingRide
                        ? () => onBookRide(bookingProvider)
                        : null,
                style: AppButtonStyles.primaryButton.copyWith(
                  backgroundColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                      if (states.contains(WidgetState.disabled)) {
                        return AppColors.lightGrey;
                      }
                      return AppColors.primaryBlue;
                    },
                  ),
                  foregroundColor: WidgetStateProperty.all(AppColors.white),
                  elevation: WidgetStateProperty.all(0),
                ),
                child:
                    bookingProvider.isBookingRide
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.white,
                            ),
                          ),
                        )
                        : Text(
                          _getButtonText(bookingProvider),
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText(RideBookingProvider bookingProvider) {
    if (bookingProvider.selectedVehicle != null) {
      return 'Choose ${bookingProvider.selectedVehicle!.name}';
    }
    return 'Select a Vehicle';
  }
}
