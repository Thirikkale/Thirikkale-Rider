import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/ride_booking_provider.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/features/booking/widgets/Route_map.dart';
import 'package:thirikkale_rider/features/booking/widgets/ride_options_bottom_sheet.dart';
import 'package:thirikkale_rider/features/booking/widgets/payment_method_bottom_sheet.dart';
import 'package:thirikkale_rider/features/booking/screens/pickup_time_screen.dart';
import 'package:thirikkale_rider/features/booking/screens/ride_summary_screen.dart';

class RideBookingScreen extends StatefulWidget {
  const RideBookingScreen({super.key});

  @override
  State<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends State<RideBookingScreen> {
  // Add a state variable to hold the sheet's current height in pixels
  double _sheetHeight =8;

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
    // No longer needed: all state is in provider, set by previous screen
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
      // Debug: Print the current schedule type
      print('Current isRideScheduled: ${bookingProvider.isRideScheduled}');
      // Check if the ride is scheduled
      if (bookingProvider.isRideScheduled) {
        print('Navigating to pickup time screen for scheduled ride');
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PickupTimeScreen(),
            ),
          );
        }
        return;
      }

      print('Proceeding with immediate ride booking');
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideSummaryScreen(),
          ),
        );
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
