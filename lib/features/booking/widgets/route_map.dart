import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:thirikkale_rider/core/services/direction_service.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';

class RouteMap extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? destLat;
  final double? destLng;
  final double bottomPadding;

  const RouteMap({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    this.pickupLat,
    this.pickupLng,
    this.destLat,
    this.destLng,
    this.bottomPadding = 0,
  });

  @override
  State<RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<RouteMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoadingRoute = true;
  // String? _duration;

  @override
  void initState() {
    super.initState();
    print(
      'RouteMap initState - Pickup: ${widget.pickupLat}, ${widget.pickupLng}, Dest: ${widget.destLat}, ${widget.destLng}',
    );
    _initializeMap();
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

  Future<BitmapDescriptor> _createCircleMarker(Color color, String text) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 100.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 2, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _createSquareMarker(Color color, String text) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 100.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, size - 8, size - 8),
      const Radius.circular(8),
    );
    canvas.drawRRect(rect, paint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawRRect(rect, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List());
  }

  Future<void> _createMarkers() async {
    final markers = <Marker>{};

    if (widget.pickupLat != null && widget.pickupLng != null) {
      final pickupIcon = await _createCircleMarker(AppColors.primaryBlue, 'P');
      markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: LatLng(widget.pickupLat!, widget.pickupLng!),
          icon: pickupIcon,
          infoWindow: InfoWindow(
            title: 'Pickup Location',
            snippet: widget.pickupAddress,
          ),
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }

    if (widget.destLat != null && widget.destLng != null) {
      final destinationIcon =
          await _createSquareMarker(AppColors.primaryBlue, 'D');
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(widget.destLat!, widget.destLng!),
          icon: destinationIcon,
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: widget.destinationAddress,
          ),
          anchor: const Offset(0.5, 0.5),
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
          final polylineLatLngs = polylinePoints
              .map((p) => LatLng(p[0].toDouble(), p[1].toDouble()))
              .toList();
          final polyline = Polyline(
            polylineId: const PolylineId('route'),
            points: polylineLatLngs,
            color: AppColors.primaryBlue,
            width: 3,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
            geodesic: true,
          );
          if (mounted) {
            setState(() {
              _polylines = {polyline};
              // _duration = directions.duration;
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
      width: 3,
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
              Icon(Icons.location_off, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text('Unable to load map', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              Text('Location coordinates not available', style: AppTextStyles.bodySmall),
            ],
          ),
        ),
      );
    }

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
                    color: Colors.black.withOpacity(0.1),
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
                  color: Colors.black.withOpacity(0.1),
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
        // if (_duration != null && !_isLoadingRoute)
        //   Positioned(
        //     top: 80,
        //     left: 0,
        //     right: 0,
        //     child: Center(
        //       child: Container(
        //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //         decoration: BoxDecoration(
        //           color: Colors.black87,
        //           borderRadius: BorderRadius.circular(20),
        //         ),
        //         child: Row(
        //           mainAxisSize: MainAxisSize.min,
        //           children: [
        //             const Icon(Icons.access_time, color: Colors.white, size: 16),
        //             const SizedBox(width: 4),
        //             Text(
        //               _duration!,
        //               style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        if (_isLoadingRoute)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}