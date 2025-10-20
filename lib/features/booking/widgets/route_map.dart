import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:provider/provider.dart'; // ADD THIS
import 'package:thirikkale_rider/core/providers/ride_tracking_provider.dart'; // ADD THIS
import 'package:thirikkale_rider/core/services/direction_service.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/booking/models/custom_marker.dart';

class RouteMap extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? destLat;
  final double? destLng;
  final double bottomPadding;
  final bool showBackButton;
  final bool showDriverLocation; // ADD THIS - to enable/disable driver tracking

  const RouteMap({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    this.pickupLat,
    this.pickupLng,
    this.destLat,
    this.destLng,
    this.bottomPadding = 0,
    this.showBackButton = true,
    this.showDriverLocation = false, // ADD THIS - default to false
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = true;
  BitmapDescriptor? _driverIcon; // ADD THIS - cache the driver icon

  @override
  void initState() {
    super.initState();
    print(
      'RouteMap initState - Pickup: ${widget.pickupLat}, ${widget.pickupLng}, Dest: ${widget.destLat}, ${widget.destLng}',
    );
    _initializeMap();
    if (widget.showDriverLocation) {
      _createDriverIcon(); // ADD THIS
    }
  }

  @override
  void didUpdateWidget(RouteMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize if coordinates changed
    if (oldWidget.pickupLat != widget.pickupLat ||
        oldWidget.pickupLng != widget.pickupLng ||
        oldWidget.destLat != widget.destLat ||
        oldWidget.destLng != widget.destLng) {
      print('RouteMap coordinates updated - reinitializing');
      _initializeMap();
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // ADD THIS METHOD - Create custom driver marker icon
  Future<void> _createDriverIcon() async {
    _driverIcon = await CustomMarker.createCircleMarker(
      AppColors.primaryBlue,
      'Driver',
    );
  }

  void _initializeMap() async {
    print('RouteMap _initializeMap called');
    await _createMarkers();
    await _getDirections();

    // Ensure we always have some route visible
    if (_polylines.isEmpty &&
        widget.pickupLat != null &&
        widget.destLat != null) {
      print('RouteMap: No polylines after getDirections, creating fallback');
      _createFallbackRoute();
    }
  }

  Future<void> _createMarkers() async {
    final markers = <Marker>{};

    if (widget.pickupLat != null && widget.pickupLng != null) {
      final pickupIcon = await CustomMarker.createPillMarker('Pickup');
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(widget.pickupLat!, widget.pickupLng!),
          icon: pickupIcon,
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: widget.pickupAddress,
          ),
          anchor: const Offset(0.5, 1.0),
        ),
      );
    }

    if (widget.destLat != null && widget.destLng != null) {
      final destinationIcon = await CustomMarker.createPillMarker('Drop');
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(widget.destLat!, widget.destLng!),
          icon: destinationIcon,
          anchor: const Offset(0.5, 1.0),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
    print('RouteMap: Created ${markers.length} markers');
    _showInfoWindows();
  }

  // ADD THIS METHOD - Update markers to include driver location
  void _updateMarkersWithDriver(LatLng driverLocation) {
    final updatedMarkers = Set<Marker>.from(_markers);

    // Remove old driver marker if it exists
    updatedMarkers.removeWhere((marker) => marker.markerId.value == 'driver');

    // Add new driver marker
    if (_driverIcon != null) {
      updatedMarkers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driverLocation,
          icon: _driverIcon!,
          infoWindow: const InfoWindow(
            title: 'Driver',
            snippet: 'On the way to you',
          ),
          anchor: const Offset(0.5, 0.5),
          rotation: 0, // You can calculate bearing for better accuracy
        ),
      );
    }

    if (mounted) {
      setState(() {
        _markers = updatedMarkers;
      });

      // Optionally animate camera to show driver
      _mapController?.animateCamera(CameraUpdate.newLatLng(driverLocation));
    }
  }

  void _showInfoWindows() async {
    if (_mapController == null) return;
    await Future.delayed(const Duration(milliseconds: 500));
    if (widget.pickupLat != null) {
      _mapController!.showMarkerInfoWindow(const MarkerId('pickup'));
    }
    if (widget.destLat != null) {
      _mapController!.showMarkerInfoWindow(const MarkerId('destination'));
    }
  }

  Future<void> _getDirections() async {
    if (widget.pickupLat == null ||
        widget.pickupLng == null ||
        widget.destLat == null ||
        widget.destLng == null) {
      print('RouteMap: Missing coordinates, cannot get directions');
      if (mounted) setState(() => _isLoadingRoute = false);
      return;
    }

    if (mounted) setState(() => _isLoadingRoute = true);

    try {
      final directions = await DirectionsService.getDirections(
        origin: LatLng(widget.pickupLat!, widget.pickupLng!),
        destination: LatLng(widget.destLat!, widget.destLng!),
      );

      if (directions != null) {
        final polylinePoints = decodePolyline(directions.polylinePoints);
        if (polylinePoints.isNotEmpty) {
          final polylineLatLngs =
              polylinePoints
                  .map((p) => LatLng(p[0].toDouble(), p[1].toDouble()))
                  .toList();
          final polyline = Polyline(
            polylineId: const PolylineId('route'),
            points: polylineLatLngs,
            color: AppColors.primaryBlue,
            width: 6,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
            geodesic: true,
          );
          if (mounted) {
            setState(() {
              _polylines = {polyline};
              _isLoadingRoute = false;
            });
          }
          Future.delayed(const Duration(milliseconds: 500), _fitRouteInView);
        } else {
          _createFallbackRoute();
        }
      } else {
        _createFallbackRoute();
      }
    } catch (e) {
      print('RouteMap: Error getting directions: $e');
      _createFallbackRoute();
    }
  }

  void _createFallbackRoute() {
    if (widget.pickupLat == null ||
        widget.pickupLng == null ||
        widget.destLat == null ||
        widget.destLng == null) {
      if (mounted) setState(() => _isLoadingRoute = false);
      return;
    }

    final fallbackPolyline = Polyline(
      polylineId: const PolylineId('fallback_route'),
      points: [
        LatLng(widget.pickupLat!, widget.pickupLng!),
        LatLng(widget.destLat!, widget.destLng!),
      ],
      color: AppColors.primaryBlue,
      width: 6,
      patterns: [PatternItem.dash(15), PatternItem.gap(8)],
    );

    if (mounted) {
      setState(() {
        _polylines = {fallbackPolyline};
        _isLoadingRoute = false;
      });
    }
    Future.delayed(const Duration(milliseconds: 500), _fitRouteInView);
  }

  void _fitRouteInView() {
    if (_mapController == null || !mounted) return;

    if (widget.pickupLat != null && widget.destLat != null) {
      try {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(_calculateBounds(), 120.0),
        );
      } catch (e) {
        print('Error fitting route in view: $e');
      }
    }
  }

  LatLngBounds _calculateBounds() {
    final latitudes = [widget.pickupLat!, widget.destLat!];
    final longitudes = [widget.pickupLng!, widget.destLng!];
    final minLat = latitudes.reduce((a, b) => a < b ? a : b) - 0.005;
    final maxLat = latitudes.reduce((a, b) => a > b ? a : b) + 0.005;
    final minLng = longitudes.reduce((a, b) => a < b ? a : b) - 0.005;
    final maxLng = longitudes.reduce((a, b) => a > b ? a : b) + 0.005;
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _recenterMap() {
    print('RouteMap: Recenter button pressed');
    if (_polylines.isEmpty &&
        widget.pickupLat != null &&
        widget.destLat != null) {
      print('RouteMap: No polylines found, creating fallback route');
      _createFallbackRoute();
    }
    _fitRouteInView();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pickupLat == null || widget.destLat == null) {
      return Container(
        color: AppColors.subtleGrey,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text('Unable to load map', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              Text(
                'Location coordinates not available',
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    // MODIFY THIS - Wrap with Consumer to listen to driver location
    return widget.showDriverLocation
        ? Consumer<RideTrackingProvider>(
          builder: (context, rideTrackingProvider, child) {
            // Update driver marker when location changes
            if (rideTrackingProvider.driverLocation != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _updateMarkersWithDriver(rideTrackingProvider.driverLocation!);
              });
            }

            return _buildMapWidget();
          },
        )
        : _buildMapWidget();
  }

  // ADD THIS METHOD - Extract map widget to avoid duplication
  Widget _buildMapWidget() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            print('GoogleMap created');
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _fitRouteInView();
                _showInfoWindows();
              }
            });
          },
          padding: EdgeInsets.only(bottom: widget.bottomPadding, top: 80),
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.pickupLat!, widget.pickupLng!),
            zoom: 14,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
        // Back button (only show if showBackButton is true)
        if (widget.showBackButton)
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.textPrimary,
                  iconSize: 24,
                ),
              ),
            ),
          ),
        Positioned(
          bottom: widget.bottomPadding + 20,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _recenterMap,
              icon: const Icon(Icons.my_location),
              color: AppColors.primaryBlue,
              iconSize: 24,
            ),
          ),
        ),
        if (_isLoadingRoute) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}
