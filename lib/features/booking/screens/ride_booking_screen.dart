import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/ride_booking_provider.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/booking/widgets/Route_map.dart';
import 'package:thirikkale_rider/features/booking/widgets/ride_options_bottom_sheet.dart';
import 'package:thirikkale_rider/features/booking/widgets/payment_method_bottom_sheet.dart';

class RideBookingScreen extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? destLat;
  final double? destLng;
  final String? initialRideType;

  const RideBookingScreen({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    this.pickupLat,
    this.pickupLng,
    this.destLat,
    this.destLng,
    this.initialRideType,
  });

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  // Add a state variable to hold the sheet's current height in pixels
  double _sheetHeight = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeBooking();
      // Set the initial sheet height after the first frame
      setState(() {
        // initialChildSize is 0.6, so we calculate the initial pixel height
        _sheetHeight = MediaQuery.of(context).size.height * 0.6;
      });
    });
  }

  void _initializeBooking() {
    final bookingProvider = Provider.of<RideBookingProvider>(
      context,
      listen: false,
    );
    
    // Set initial vehicle selection FIRST if we have a ride type
    if (widget.initialRideType != null) {
      bookingProvider.setInitialVehicleByRideType(widget.initialRideType);
    }
    
    // Then set trip details, preserving the vehicle selection if we set one
    bookingProvider.setTripDetails(
      pickup: widget.pickupAddress,
      destination: widget.destinationAddress,
      pickupLat: widget.pickupLat,
      pickupLng: widget.pickupLng,
      destLat: widget.destLat,
      destLng: widget.destLng,
      preserveVehicleSelection: widget.initialRideType != null, // Preserve if we have initial ride type
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent keyboard overflow
      body: Stack(
        children: [
          // Map Section (takes up the whole screen behind the sheet)
          Consumer<RideBookingProvider>(
            builder: (context, bookingProvider, child) {
              return SizedBox.expand(
                child: RouteMap(
                  pickupAddress: bookingProvider.pickupAddress,
                  destinationAddress: bookingProvider.destinationAddress,
                  pickupLat: bookingProvider.pickupLat,
                  pickupLng: bookingProvider.pickupLng,
                  destLat: bookingProvider.destLat,
                  destLng: bookingProvider.destLng,
                  bottomPadding: _sheetHeight,
                ),
              );
            },
          ),

          // Draggable Bottom Sheet for ride options
          // Listen for scroll notifications from the sheet
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notification) {
              // When the sheet is dragged, update the state with its new pixel height
              if (mounted) {
                setState(() {
                  _sheetHeight =
                      notification.extent * MediaQuery.of(context).size.height;
                });
              }
              return true; // Stop the notification from bubbling up
            },
            child: DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              builder: (
                BuildContext context,
                ScrollController scrollController,
              ) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10.0,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: RideOptionsBottomSheet(
                    scrollController: scrollController,
                    onPaymentMethodTap: _showPaymentMethodSheet,
                    onBookRide: _handleBookRide,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodSheet() {
    final currentMethod =
        Provider.of<RideBookingProvider>(
          context,
          listen: false,
        ).selectedPaymentMethod;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8, // Limit height
      ),
      builder:
          (context) => PaymentMethodBottomSheet(
            selectedMethod: currentMethod,
            onMethodSelected: (method) {
              Provider.of<RideBookingProvider>(
                context,
                listen: false,
              ).setPaymentMethod(method);
            },
          ),
    );
  }

  void _handleBookRide(RideBookingProvider bookingProvider) async {
    try {
      await bookingProvider.bookRide();

      if (mounted) {
        // Show success message
        SnackbarHelper.showSuccessSnackBar(
          context,
          'Ride booked successfully! Driver will arrive in ${bookingProvider.selectedVehicle?.estimatedTime ?? "a few minutes"}',
        );

        // Navigate to tracking screen or go back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showErrorSnackBar(
          context,
          'Failed to book ride: ${e.toString()}',
        );
      }
    }
  }
}
