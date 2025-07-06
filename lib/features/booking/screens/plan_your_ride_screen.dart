import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/location_provider.dart';
import 'package:thirikkale_rider/core/services/places_api_service.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/booking/widgets/location_input_card.dart';
import 'package:thirikkale_rider/features/booking/widgets/plan_ride_btn_header.dart';
import 'package:thirikkale_rider/features/booking/widgets/search_results.dart';
import 'package:thirikkale_rider/features/booking/screens/ride_booking_screen.dart'; // Add this import
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class PlanYourRideScreen extends StatefulWidget {
  const PlanYourRideScreen({super.key});

  @override
  State<PlanYourRideScreen> createState() => _PlanYourRideScreenState();
}

class _PlanYourRideScreenState extends State<PlanYourRideScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationProvider();
    });
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _initializeLocationProvider() {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    locationProvider.generateNewSessionToken();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    await locationProvider.getLocationQuick();

    if (mounted && locationProvider.currentLocation != null) {
      _pickupController.text = locationProvider.currentLocationAddress;
    }
  }

  void _onDestinationChanged(String input) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        final locationProvider = Provider.of<LocationProvider>(
          context,
          listen: false,
        );
        locationProvider.searchPlaces(input);
      }
    });
  }

  void _onLocationSelected(Map<String, dynamic> prediction) async {
    final description = prediction['description'] ?? '';
    _destinationController.text = description;

    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    locationProvider.clearSearchResults();
    locationProvider.generateNewSessionToken();

    FocusScope.of(context).unfocus();

    // Navigate to ride booking screen when destination is selected
    await _navigateToRideBooking(prediction);
  }

  Future<void> _navigateToRideBooking(
    Map<String, dynamic> destinationPrediction,
  ) async {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );

    // Check if we have pickup location
    if (_pickupController.text.isEmpty ||
        locationProvider.currentLocation == null) {
      _showErrorMessage('Please select a pickup location first');
      return;
    }

    // Check if we have destination
    if (_destinationController.text.isEmpty) {
      _showErrorMessage('Please select a destination');
      return;
    }

    // Show loading indicator
    _showLoadingDialog();

    try {
      // Get destination coordinates from place details
      double? destLat, destLng;

      final placeId = destinationPrediction['place_id'];
      if (placeId != null) {
        final placeDetails = await PlacesApiService.getPlaceDetails(placeId);
        if (placeDetails != null) {
          final geometry = placeDetails['geometry'];
          final location = geometry?['location'];
          if (location != null) {
            destLat = location['lat']?.toDouble();
            destLng = location['lng']?.toDouble();
          }
        }
      }

      // Hide loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to ride booking screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RideBookingScreen(
                  pickupAddress: _pickupController.text,
                  destinationAddress: _destinationController.text,
                  pickupLat: locationProvider.currentLatitude,
                  pickupLng: locationProvider.currentLongitude,
                  destLat: destLat,
                  destLng: destLng,
                ),
          ),
        );
      }
    } catch (e) {
      // Hide loading dialog
      if (mounted) Navigator.pop(context);

      print('Error getting destination coordinates: $e');
      _showErrorMessage('Unable to get location details. Please try again.');
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _onPickupTap() {
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(
        title: "Plan your ride",
        showBackButton: true,
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          return Column(
            children: [
              PlanRideBtnHeader(
                onScheduleChanged: (schedule) {
                  print('Schedule changed to: $schedule');
                },
                onRideTypeChanged: (rideType) {
                  print('Ride type changed to: $rideType');
                },
              ),

              LocationInputCard(
                pickupController: _pickupController,
                destinationController: _destinationController,
                onDestinationChanged: _onDestinationChanged,
                onPickupChanged: (value) {
                  print('Pickup changed: $value');
                },
                onPickupTap: _onPickupTap,
              ),

              const Divider(height: 1, color: AppColors.lightGrey),

              // Search Results
              Expanded(
                child: SearchResults(
                  locationProvider: locationProvider,
                  onLocationSelected: _onLocationSelected,
                  onRetryLocation: _getCurrentLocation,
                  destinationQuery: _destinationController.text,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
