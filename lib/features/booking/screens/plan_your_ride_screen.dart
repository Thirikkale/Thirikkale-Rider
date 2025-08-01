import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:thirikkale_rider/core/providers/location_provider.dart';
import 'package:thirikkale_rider/core/services/places_api_service.dart';
import 'package:thirikkale_rider/core/services/location_service.dart';
import 'package:thirikkale_rider/core/services/direction_service.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/core/utils/dialog_helper.dart';
import 'package:thirikkale_rider/features/booking/screens/ride_booking_screen.dart';
import 'package:thirikkale_rider/features/booking/screens/location_search_screen.dart';
import 'package:thirikkale_rider/features/booking/models/custom_marker.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/core/providers/ride_booking_provider.dart';

class PlanYourRideScreen extends StatefulWidget {
  const PlanYourRideScreen({super.key});

  @override
  State<PlanYourRideScreen> createState() => _PlanYourRideScreenState();
}

class _PlanYourRideScreenState extends State<PlanYourRideScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final Completer<GoogleMapController> _mapController = Completer();
  Timer? _debounce;

  int locatorHeightFromAbove = 30;

  bool _mapLoading = true;
  bool _isSelectingLocation = false;
  String _locationSelectionMode = ''; // 'pickup' or 'destination'
  LatLng? _selectedLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Timer? _geocodingTimer;
  Timer? _autoSelectionTimer;

  // Store selected coordinates from map
  LatLng? _selectedPickupCoords;
  LatLng? _selectedDestinationCoords;

  @override
  void initState() {
    super.initState();
    _initializeWithParameters();
    _focusOnCurrentLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocationProvider();
    });
  }
  // TODO: update to hsow the bottom sheet
  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Permission Required'),
            content: const Text(
              'Please enable location permission to use the map features.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await LocationService.openLocationSettings();
                },
                child: const Text('Settings'),
              ),
            ],
          ),
    );
  }
  
  Future<void> _checkLocationServices() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await LocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorMessage(
          'Location services are disabled. Please enable them in settings.',
        );
        return;
      }

      // Check permission status
      final permission = await LocationService.getPermissionStatus();
      print('Location permission status: $permission');

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _showLocationPermissionDialog();
        _showErrorMessage(
          'Location permission is required. Please grant location access.',
        );
        return;
      }

      // If all checks pass, try to get location
      await _getCurrentLocation();
    } catch (e) {
      print('Error checking location services: $e');
      _showErrorMessage('Failed to check location services');
    }
  }

  void _initializeWithParameters() {
    // Use provider values for initial addresses
    final bookingProvider = Provider.of<RideBookingProvider>(context, listen: false);
    if (bookingProvider.pickupAddress.isNotEmpty) {
      _pickupController.text = bookingProvider.pickupAddress;
    }
    if (bookingProvider.destinationAddress.isNotEmpty) {
      _destinationController.text = bookingProvider.destinationAddress;
    }
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    _debounce?.cancel();
    _geocodingTimer?.cancel();
    _autoSelectionTimer?.cancel();
    super.dispose();
  }

  void _initializeLocationProvider() {
    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      locationProvider.generateNewSessionToken();
      _checkLocationServices();
    } catch (e) {
      print('Error initializing location provider: $e');
      if (mounted) {
        _showErrorMessage('Location service initialization failed');
        setState(() {
          _pickupController.text = "Tap to set pickup location";
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );

      // Show loading state for location
      if (mounted) {
        setState(() {
          _pickupController.text = "Getting location...";
        });
      }

      await locationProvider.getLocationQuick();

      if (mounted) {
        if (locationProvider.currentLocation != null) {
          setState(() {
            _pickupController.text = locationProvider.currentLocationAddress;
            // Store current location as pickup coordinates
            _selectedPickupCoords = LatLng(
              locationProvider.currentLatitude!,
              locationProvider.currentLongitude!,
            );
          });

          print(
            'Location detected: ${locationProvider.currentLocationAddress}',
          );
          print(
            'Coordinates: ${locationProvider.currentLatitude}, ${locationProvider.currentLongitude}',
          );
        } else {
          // Handle location detection failure
          setState(() {
            _pickupController.text = "Tap to set pickup location";
          });

          if (locationProvider.locationError != null) {
            _showErrorMessage(
              'Location Error: ${locationProvider.locationError}',
            );
          } else {
            _showErrorMessage(
              'Unable to detect current location. Please select manually.',
            );
          }

          print(
            'Location detection failed: ${locationProvider.locationError ?? "Unknown error"}',
          );
        }
      }
    } catch (e) {
      print('Error in _getCurrentLocation: $e');
      if (mounted) {
        setState(() {
          _pickupController.text = "Tap to set pickup location";
        });
        _showErrorMessage(
          'Failed to get location. Please try again or select manually.',
        );
      }
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
      // Get destination coordinates from place details or use stored coordinates
      double? destLat, destLng;
      double? pickupLat, pickupLng;

      // Use stored coordinates if available (from map selection)
      if (_selectedDestinationCoords != null) {
        destLat = _selectedDestinationCoords!.latitude;
        destLng = _selectedDestinationCoords!.longitude;
      } else {
        // Fallback to place details API for text-based search
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
      }

      // Use stored pickup coordinates if available (from map selection)
      if (_selectedPickupCoords != null) {
        pickupLat = _selectedPickupCoords!.latitude;
        pickupLng = _selectedPickupCoords!.longitude;
      } else {
        pickupLat = locationProvider.currentLatitude;
        pickupLng = locationProvider.currentLongitude;
      }

      // Estimate price, duration, and distance if available from directions
      double? estimatedPrice;
      double? estimatedDuration;
      double? estimatedDistance;
      // Try to get estimates from directions service if both coordinates are available
      if (pickupLat != null && pickupLng != null && destLat != null && destLng != null) {
        final directions = await DirectionsService.getDirections(
          origin: LatLng(pickupLat, pickupLng),
          destination: LatLng(destLat, destLng),
        );
        if (directions != null) {
          // Parse duration and distance from String to double
          estimatedDuration = double.tryParse(directions.duration);
          estimatedDistance = double.tryParse(directions.distance);
        }
      }

      // Update provider with all relevant data
      final bookingProvider = Provider.of<RideBookingProvider>(context, listen: false);
      await bookingProvider.setTripDetails(
        pickup: _pickupController.text,
        destination: _destinationController.text,
        pickupLat: pickupLat,
        pickupLng: pickupLng,
        destLat: destLat,
        destLng: destLng,
      );
      bookingProvider.estimatedPrice = estimatedPrice;
      bookingProvider.estimatedDuration = estimatedDuration;
      bookingProvider.estimatedDistance = estimatedDistance;

      // Hide loading dialog
      if (mounted) Navigator.pop(context);

      // Navigate to ride booking screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => RideBookingScreen(),
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
  //TODO: better design to show loading
  void _showLoadingDialog() {
    DialogHelper.showInfoDialog(
      context: context,
      title: 'Processing Ride Request',
      content: 'Getting location details and preparing your ride...',
      buttonText: 'Please Wait',
      titleIcon: Icons.directions_car,
      titleIconColor: AppColors.primaryBlue,
    );
  }

  void _showErrorMessage(String message) {
    SnackbarHelper.showErrorSnackBar(context, message);
  }

  // Map interaction methods
  void _onCameraMove(CameraPosition position) {
    if (_isSelectingLocation) {
      // Calculate the actual position where the pin is displayed
      // The pin is positioned at locatorHeightFromAbove% from top instead of center
      final actualPosition = _calculatePinPosition(position);
      _selectedLocation = actualPosition;

      // Cancel previous timers
      if (_geocodingTimer?.isActive ?? false) {
        _geocodingTimer!.cancel();
      }

      // Start geocoding timer (1 second for address update)
      _geocodingTimer = Timer(const Duration(milliseconds: 1000), () {
        _updateAddressFromPosition(actualPosition);
      });

      // Start auto-selection timer (3 seconds to auto-select location)
      if (_autoSelectionTimer?.isActive ?? false) {
        _autoSelectionTimer!.cancel();
      }

      _autoSelectionTimer = Timer(const Duration(seconds: 2), () {
        _finishLocationSelectionAutomatically();
      });
    }
  }

  // Calculate the actual coordinates where the pin is visually positioned
  LatLng _calculatePinPosition(CameraPosition cameraPosition) {
    final locationProvider = Provider.of<LocationProvider>(
      context,
      listen: false,
    );
    return locationProvider.calculatePinPosition(
      cameraPosition,
      locatorHeightFromAbove,
    );
  }

  void _updateAddressFromPosition(LatLng position) async {
    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      final address = await locationProvider.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          if (_locationSelectionMode == 'pickup') {
            _pickupController.text = address;
            _selectedPickupCoords = position;
          } else if (_locationSelectionMode == 'destination') {
            _destinationController.text = address;
            _selectedDestinationCoords = position;
          }
        });

        print('Address updated: $address');
        print(
          'Pin position coordinates: ${position.latitude}, ${position.longitude}',
        );
        print('Location mode: $_locationSelectionMode');

        // Calculate and display route if both locations are set
        if (_selectedPickupCoords != null &&
            _selectedDestinationCoords != null) {
          _calculateAndDisplayRoute();
        }
      }
    } catch (e) {
      print('Error updating address from position: $e');

      // Last resort: use coordinates as address
      if (mounted) {
        final coordsAddress =
            '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        setState(() {
          if (_locationSelectionMode == 'pickup') {
            _pickupController.text = coordsAddress;
            _selectedPickupCoords = position;
          } else if (_locationSelectionMode == 'destination') {
            _destinationController.text = coordsAddress;
            _selectedDestinationCoords = position;
          }
        });

        _showErrorMessage(
          'Using coordinates as location. Address lookup failed.',
        );
        print('Using coordinates as fallback: $coordsAddress');

        // Calculate and display route if both locations are set
        if (_selectedPickupCoords != null &&
            _selectedDestinationCoords != null) {
          _calculateAndDisplayRoute();
        }
      }
    }
  }

  void _startLocationSelection(String mode) {
    setState(() {
      _isSelectingLocation = true;
      _locationSelectionMode = mode;
    });

    print('Started location selection for: $mode');
  }

  Future<void> _openLocationSearch(String mode) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (context) => LocationSearchScreen(
              title: mode == 'pickup' ? 'Pickup Location' : 'Destination',
              initialText:
                  mode == 'pickup'
                      ? _pickupController.text
                      : _destinationController.text,
              hintText:
                  mode == 'pickup'
                      ? 'Search for pickup location'
                      : 'Search for destination',
              isPickup: mode == 'pickup',
            ),
      ),
    );

    if (result != null && mounted) {
      if (result.containsKey('use_map')) {
        // User wants to select from map
        _startLocationSelection(mode);
      } else {
        // User selected a location
        await _handleLocationSearchResult(result, mode);

        // Add to search history
        final locationProvider = Provider.of<LocationProvider>(
          context,
          listen: false,
        );
        await locationProvider.addToSearchHistory(result);
      }
    }
  }

  Future<void> _handleLocationSearchResult(
    Map<String, dynamic> location,
    String mode,
  ) async {
    try {
      String address =
          location['description'] ??
          location['formatted_address'] ??
          'Unknown Location';
      LatLng? coordinates;

      // Extract coordinates if available
      if (location['geometry'] != null &&
          location['geometry']['location'] != null) {
        final loc = location['geometry']['location'];
        coordinates = LatLng(
          loc['lat']?.toDouble() ?? 0.0,
          loc['lng']?.toDouble() ?? 0.0,
        );
      } else if (location['place_id'] != null &&
          location['place_id'] != 'current_location') {
        // Get place details for coordinates
        final placeDetails = await PlacesApiService.getPlaceDetails(
          location['place_id'],
        );
        if (placeDetails != null && placeDetails['geometry'] != null) {
          final loc = placeDetails['geometry']['location'];
          coordinates = LatLng(
            loc['lat']?.toDouble() ?? 0.0,
            loc['lng']?.toDouble() ?? 0.0,
          );
          address = placeDetails['formatted_address'] ?? address;
        }
      }

      // Update the UI
      if (mounted) {
        setState(() {
          if (mode == 'pickup') {
            _pickupController.text = address;
            _selectedPickupCoords = coordinates;
          } else {
            _destinationController.text = address;
            _selectedDestinationCoords = coordinates;
          }
        });

        print('Selected location for $mode: $address');
        if (coordinates != null) {
          print(
            'Coordinates: ${coordinates.latitude}, ${coordinates.longitude}',
          );
        }

        // Calculate and display route if both locations are set
        if (_selectedPickupCoords != null &&
            _selectedDestinationCoords != null) {
          _calculateAndDisplayRoute();
        }
      }
    } catch (e) {
      print('Error handling location search result: $e');
      if (mounted) {
        _showErrorMessage('Failed to set location. Please try again.');
      }
    }
  }

  void _finishLocationSelectionAutomatically() {
    if (_isSelectingLocation && _selectedLocation != null) {
      final currentMode = _locationSelectionMode; // Store before resetting

      setState(() {
        _isSelectingLocation = false;
        _locationSelectionMode = '';
      });

      // Cancel timers
      _geocodingTimer?.cancel();
      _autoSelectionTimer?.cancel();

      // Show success message
      if (mounted) {
        SnackbarHelper.showSuccessSnackBar(
          context,
          currentMode == 'pickup'
              ? 'Pickup location set successfully!'
              : 'Drop-off location set successfully!',
        );
      }
    }
  }

  void _finishLocationSelectionManually() {
    if (_isSelectingLocation && _selectedLocation != null) {
      final currentMode = _locationSelectionMode; // Store before resetting

      // Cancel timers first
      _geocodingTimer?.cancel();
      _autoSelectionTimer?.cancel();

      // Immediately update the address from current position
      _updateAddressFromPosition(_selectedLocation!);

      setState(() {
        _isSelectingLocation = false;
        _locationSelectionMode = '';
      });

      // Show success message
      if (mounted) {
        SnackbarHelper.showSuccessSnackBar(
          context,
          currentMode == 'pickup'
              ? 'Pickup location set successfully!'
              : 'Drop-off location set successfully!',
        );
      }

      print('Manual location selection completed for: $currentMode');
      print(
        'Selected coordinates: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
      );
    }
  }

  void _focusOnCurrentLocation() async {
    try {
      final locationProvider = Provider.of<LocationProvider>(
        context,
        listen: false,
      );
      const double latOffset = 0.002;

      if (locationProvider.currentLocation != null) {
        final controller = await _mapController.future;
        await controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(
                locationProvider.currentLatitude! - latOffset,
                locationProvider.currentLongitude!,
              ),
              zoom: 16,
            ),
          ),
        );
      } else {
        _showErrorMessage('Current location not available');
      }
    } catch (e) {
      print('Error focusing on current location: $e');
      _showErrorMessage('Error focusing on current location');
    }
  }

  void _toggleSchedule() {
    final bookingProvider = Provider.of<RideBookingProvider>(context, listen: false);
    bookingProvider.setOptions(
      isSolo: bookingProvider.isSolo,
      isRideScheduled: !bookingProvider.isRideScheduled,
      isWomenOnly: bookingProvider.isWomenOnly,
    );
    SnackbarHelper.showInfoSnackBar(
      context,
      !bookingProvider.isRideScheduled ? 'Ride set for now' : 'Ride scheduled for later',
    );
    setState(() {}); // To trigger UI update
  }

  void _toggleRideType() {
    final bookingProvider = Provider.of<RideBookingProvider>(context, listen: false);
    bookingProvider.setOptions(
      isSolo: !bookingProvider.isSolo,
      isRideScheduled: bookingProvider.isRideScheduled,
      isWomenOnly: bookingProvider.isWomenOnly,
    );
    SnackbarHelper.showInfoSnackBar(
      context,
      bookingProvider.isSolo ? 'Solo ride selected' : 'Shared ride selected',
    );
    setState(() {}); // To trigger UI update
  }

  void _toggleWomenOnly() {
    final bookingProvider = Provider.of<RideBookingProvider>(context, listen: false);
    bookingProvider.setOptions(
      // isSolo: bookingProvider.isSolo,
      // isRideScheduled: bookingProvider.isRideScheduled,
      isWomenOnly: !bookingProvider.isWomenOnly,
    );
    SnackbarHelper.showInfoSnackBar(
      context,
      bookingProvider.isWomenOnly ? 'Women Only option enabled' : 'Women Only option disabled',
    );
    setState(() {}); // To trigger UI update
  }
  
  // Showing the path in the map
  Future<void> _calculateAndDisplayRoute() async {
    // Check if we have both pickup and destination coordinates
    if (_selectedPickupCoords == null || _selectedDestinationCoords == null) {
      return;
    }

    try {
      // Import DirectionService at the top level and use it here
      final directions = await DirectionsService.getDirections(
        origin: _selectedPickupCoords!,
        destination: _selectedDestinationCoords!,
      );

      if (directions != null) {
        // Decode the polyline points using google_polyline_algorithm
        final polylinePoints = decodePolyline(directions.polylinePoints);
        final List<LatLng> routeCoords =
            polylinePoints
                .map((p) => LatLng(p[0].toDouble(), p[1].toDouble()))
                .toList();

        // Create polyline
        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          points: routeCoords,
          color: AppColors.primaryBlue,
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          jointType: JointType.round,
          geodesic: true,
        );

        // Create custom markers for pickup and destination like in RouteMap
        final pickupIcon = await CustomMarker.createPillMarker('Pickup');
        final destinationIcon = await CustomMarker.createPillMarker('Drop');

        final pickupMarker = Marker(
          markerId: const MarkerId('pickup'),
          position: _selectedPickupCoords!,
          icon: pickupIcon,
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: _pickupController.text,
          ),
          anchor: const Offset(0.5, 1.0), // Bottom center for pill marker
        );

        final destinationMarker = Marker(
          markerId: const MarkerId('destination'),
          position: _selectedDestinationCoords!,
          icon: destinationIcon,
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: _destinationController.text,
          ),
          anchor: const Offset(0.5, 1.0), // Bottom center for pill marker
        );

        // Update the map with route and markers
        if (mounted) {
          setState(() {
            _polylines.clear();
            _polylines.add(polyline);
            _markers.clear();
            _markers.addAll([pickupMarker, destinationMarker]);
          });

          // Adjust camera to show entire route
          _fitCameraToRoute(routeCoords);
        }

        print('Route displayed with ${routeCoords.length} points');
        print(
          'Distance: ${directions.distance}, Duration: ${directions.duration}',
        );
      } else {
        // Fallback to direct line if directions service fails
        _showMarkersOnly();
      }
    } catch (e) {
      print('Error calculating route: $e');
      // Still show markers even if route calculation fails
      _showMarkersOnly();
    }
  }

  void _showMarkersOnly() async {
    if (_selectedPickupCoords == null || _selectedDestinationCoords == null) {
      return;
    }

    // Create custom markers for pickup and destination like in RouteMap
    final pickupIcon = await CustomMarker.createPillMarker('Pickup');
    final destinationIcon = await CustomMarker.createPillMarker('Drop');

    final pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: _selectedPickupCoords!,
      icon: pickupIcon,
      infoWindow: InfoWindow(
        title: 'Pickup Location',
        snippet: _pickupController.text,
      ),
      anchor: const Offset(0.5, 1.0), // Bottom center for pill marker
    );

    final destinationMarker = Marker(
      markerId: const MarkerId('destination'),
      position: _selectedDestinationCoords!,
      icon: destinationIcon,
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: _destinationController.text,
      ),
      anchor: const Offset(0.5, 1.0), // Bottom center for pill marker
    );

    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.addAll([pickupMarker, destinationMarker]);
      });
    }
  }

  void _fitCameraToRoute(List<LatLng> routeCoords) async {
    if (routeCoords.isEmpty) return;

    try {
      final controller = await _mapController.future;

      // Calculate bounds
      double minLat = routeCoords.first.latitude;
      double maxLat = routeCoords.first.latitude;
      double minLng = routeCoords.first.longitude;
      double maxLng = routeCoords.first.longitude;

      for (final coord in routeCoords) {
        minLat = math.min(minLat, coord.latitude);
        maxLat = math.max(maxLat, coord.latitude);
        minLng = math.min(minLng, coord.longitude);
        maxLng = math.max(maxLng, coord.longitude);
      }

      // Add padding
      const padding = 0.01;
      final bounds = LatLngBounds(
        southwest: LatLng(minLat - padding, minLng - padding),
        northeast: LatLng(maxLat + padding, maxLng + padding),
      );

      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } catch (e) {
      print('Error fitting camera to route: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(title: 'Plan your ride', showBackButton: true),
      body: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.zero,
              child: Consumer<LocationProvider>(
                builder: (context, locationProvider, child) {
                  return GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController.complete(controller);
                      setState(() {
                        _mapLoading = false;
                      });
                      print('Google Map created successfully');
                    },
                    // onTap: _onMapTap,
                    onCameraMove: _onCameraMove,
                    markers: _markers,
                    polylines: _polylines,
                    initialCameraPosition: CameraPosition(
                      target:
                          locationProvider.currentLocation != null
                              ? LatLng(
                                locationProvider.currentLatitude!,
                                locationProvider.currentLongitude!,
                              )
                              : LatLng(6.9271, 79.8612), // Default to Colombo
                      zoom: 15,
                    ),
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false, // We'll add our own button
                    mapType: MapType.normal,
                    compassEnabled: true,
                    tiltGesturesEnabled: true,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                  );
                },
              ),
            ),
          ),

          if (_mapLoading)
            Positioned.fill(
              child: Container(
                color: AppColors.surfaceLight,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),

          // Center crosshair for location selection
          if (_isSelectingLocation)
            Stack(
              children: [
                // Location selection instruction - moved higher up from bottom
                Positioned(
                  top:
                      kToolbarHeight -
                      locatorHeightFromAbove, // Increased distance from appbar (locatorHeightFromAbove) to lift it higher from bottom
                  left: AppDimensions.pageHorizontalPadding,
                  right: AppDimensions.pageHorizontalPadding,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.pageHorizontalPadding,
                      vertical: AppDimensions.subSectionSpacingDown / 3,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _locationSelectionMode == 'pickup'
                              ? AppColors.success.withValues(alpha: 0.9)
                              : AppColors.primaryBlue.withValues(alpha: 0.9),
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
                          _locationSelectionMode == 'pickup'
                              ? Icons.my_location
                              : Icons.location_on,
                          color: AppColors.white,
                          size: 20,
                        ),
                        const SizedBox(
                          width: AppDimensions.subSectionSpacingDown * 2,
                        ),
                        Expanded(
                          child: Text(
                            _locationSelectionMode == 'pickup'
                                ? 'Selecting pickup location...'
                                : 'Selecting drop-off location...',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: AppColors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _isSelectingLocation = false;
                              _locationSelectionMode = '';
                            });
                            _geocodingTimer?.cancel();
                            _autoSelectionTimer?.cancel();
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: 24,
                            minHeight: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Manual confirm button at bottom during selection
                if (_isSelectingLocation)
                  Positioned(
                    bottom: 200,
                    left: AppDimensions.pageHorizontalPadding,
                    right: AppDimensions.pageHorizontalPadding,
                    child: ElevatedButton(
                      style:
                          _locationSelectionMode == 'pickup'
                              ? AppButtonStyles.primaryButton.copyWith(
                                backgroundColor: WidgetStateProperty.all(
                                  AppColors.success,
                                ),
                              )
                              : AppButtonStyles.primaryButton,
                      onPressed: () {
                        if (_selectedLocation != null) {
                          _finishLocationSelectionManually();
                        }
                      },
                      child: Text(
                        'Confirm ${_locationSelectionMode == 'pickup' ? 'Pickup' : 'Drop-off'} Location',
                      ),
                    ),
                  ),

                // Center crosshair - lifted higher from bottom
                Positioned(
                  left: 0,
                  right: 0,
                  top:
                      MediaQuery.of(context).size.height *
                      locatorHeightFromAbove /
                      100, // Position at 35% from top instead of center
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drop pin shadow and icon
                      Container(
                        width: 46,
                        height: 46,
                        alignment: Alignment.bottomCenter,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Pin shadow
                            Positioned(
                              bottom: 2,
                              child: Container(
                                width: 16,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            // Drop pin
                            Icon(
                              Icons.place,
                              color:
                                  _locationSelectionMode == 'pickup'
                                      ? AppColors.success
                                      : AppColors.primaryBlue,
                              size: 46,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

          // All buttons in a single column (right side)
          Positioned(
            right: AppDimensions.pageHorizontalPadding,
            bottom: kToolbarHeight + 255,
            child: Consumer<RideBookingProvider>(
              builder: (context, bookingProvider, _) {
                // All three buttons use the same constraints and padding for perfect alignment
                const buttonConstraints = BoxConstraints(minWidth: 76);
                final buttonPadding = EdgeInsets.symmetric(
                  horizontal: AppDimensions.subSectionSpacingDown * 3,
                  vertical: AppDimensions.subSectionSpacingDown * 3,
                );
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Schedule button with text
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _toggleSchedule,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: buttonConstraints,
                          padding: buttonPadding,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                !bookingProvider.isRideScheduled ? Icons.access_time : Icons.schedule,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                              SizedBox(width: AppDimensions.subSectionSpacingDown),
                              Text(
                                !bookingProvider.isRideScheduled ? 'Now' : 'Scheduled',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.widgetSpacing - 5),

                    // Ride type button with text
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _toggleRideType,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: buttonConstraints,
                          padding: buttonPadding,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                bookingProvider.isSolo ? Icons.person : Icons.people,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                              SizedBox(width: AppDimensions.subSectionSpacingDown),
                              Text(
                                bookingProvider.isSolo ? 'Solo' : 'Shared',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.widgetSpacing - 5),

                    // Women Only button with text
                    Material(
                      elevation: 2,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _toggleWomenOnly,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: buttonConstraints,
                          padding: buttonPadding,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.female,
                                color: AppColors.primaryBlue,
                                size: 20,
                              ),
                              SizedBox(width: AppDimensions.subSectionSpacingDown),
                              Text(
                                bookingProvider.isWomenOnly ? 'Women Only' : 'Any',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppDimensions.widgetSpacing - 8),

                    FloatingActionButton(
                      heroTag: "focus_btn",
                      mini: true,
                      backgroundColor: AppColors.white,
                      elevation: 2,
                      onPressed: _focusOnCurrentLocation,
                      child: Icon(Icons.my_location, color: AppColors.primaryBlue),
                    ),
                  ],
                );
              },
            ),
          ),

          // pickup drop collecting container - styled like bottom sheet
          Align(
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
                          Text(
                            'PICKUP',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          SizedBox(
                            height: AppDimensions.subSectionSpacingDown * 2,
                          ),

                          TextField(
                            controller: _pickupController,
                            readOnly: true,
                            onTap: () => _openLocationSearch('pickup'),
                            decoration: InputDecoration(
                              hintText:
                                  _pickupController.text.isEmpty
                                      ? 'Tap refresh to get location'
                                      : 'Location Fetched',
                              prefixIcon: Icon(Icons.my_location),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.refresh,
                                      color: AppColors.primaryBlue,
                                    ),
                                    onPressed: _checkLocationServices,
                                    tooltip: 'Refresh location',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.map,
                                      color: AppColors.primaryBlue,
                                    ),
                                    onPressed:
                                        () => _startLocationSelection('pickup'),
                                    tooltip: 'Select from map',
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.widgetSpacing,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceLight,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.widgetSpacing),

                          Text(
                            'DROP',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          SizedBox(
                            height: AppDimensions.subSectionSpacingDown * 2,
                          ),

                          TextField(
                            controller: _destinationController,
                            readOnly: true,
                            onTap: () => _openLocationSearch('destination'),
                            decoration: InputDecoration(
                              hintText: 'Where are you going?',
                              prefixIcon: Icon(Icons.location_on),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_destinationController.text.isNotEmpty)
                                    IconButton(
                                      icon: Icon(
                                        Icons.clear,
                                        color: AppColors.primaryBlue,
                                      ),
                                      onPressed: () async {
                                        final confirmed =
                                            await DialogHelper.showConfirmationDialog(
                                              context: context,
                                              title: 'Clear Destination',
                                              content:
                                                  'Are you sure you want to clear the selected destination?',
                                              confirmText: 'Clear',
                                              cancelText: 'Cancel',
                                              titleIcon: Icons.clear_all,
                                              titleIconColor: AppColors.error,
                                              confirmButtonColor:
                                                  AppColors.error,
                                            );

                                        if (confirmed == true) {
                                          setState(() {
                                            _destinationController.clear();
                                            _selectedDestinationCoords = null;
                                          });
                                        }
                                      },
                                      tooltip: 'Clear destination',
                                    ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.map,
                                      color: AppColors.primaryBlue,
                                    ),
                                    onPressed:
                                        () => _startLocationSelection(
                                          'destination',
                                        ),
                                    tooltip: 'Select from map',
                                  ),
                                ],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.widgetSpacing,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: AppColors.surfaceLight,
                            ),
                            onChanged: _onDestinationChanged,
                          ),
                          const SizedBox(
                            height: AppDimensions.sectionSpacing / 2,
                          ),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: AppButtonStyles.primaryButton,
                              onPressed: () async {
                                if (_pickupController.text.isNotEmpty &&
                                    _destinationController.text.isNotEmpty) {
                                  // Show confirmation dialog before proceeding
                                  final confirmed =
                                      await DialogHelper.showConfirmationDialog(
                                        context: context,
                                        title: 'Confirm Ride Details',
                                        content:
                                            'Pickup: ${_pickupController.text}\n\nDrop-off: ${_destinationController.text}',
                                        confirmText: 'Book Ride',
                                        cancelText: 'Edit Locations',
                                        titleIcon: Icons.confirmation_number,
                                        titleIconColor: AppColors.primaryBlue,
                                        confirmButtonColor:
                                            AppColors.primaryBlue,
                                      );

                                  if (confirmed == true) {
                                    _navigateToRideBooking({
                                      'description':
                                          _destinationController.text,
                                      'place_id': null,
                                    });
                                  }
                                } else {
                                  _showErrorMessage(
                                    'Please enter pickup and drop locations',
                                  );
                                }
                              },
                              child: Text(
                                'Book Ride',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: AppDimensions.widgetSpacing + 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
