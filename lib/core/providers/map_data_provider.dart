import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapDataProvider extends ChangeNotifier {
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = false;
  double? _pickupLat;
  double? _pickupLng;
  double? _destLat;
  double? _destLng;

  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  bool get isLoading => _isLoading;
  double? get pickupLat => _pickupLat;
  double? get pickupLng => _pickupLng;
  double? get destLat => _destLat;
  double? get destLng => _destLng;

  void setRoute({
    required double pickupLat,
    required double pickupLng,
    required double destLat,
    required double destLng,
    required Set<Marker> markers,
    required Set<Polyline> polylines,
  }) {
    _pickupLat = pickupLat;
    _pickupLng = pickupLng;
    _destLat = destLat;
    _destLng = destLng;
    _markers = markers;
    _polylines = polylines;
    notifyListeners();
  }

  void clear() {
    _markers = {};
    _polylines = {};
    _pickupLat = null;
    _pickupLng = null;
    _destLat = null;
    _destLng = null;
    notifyListeners();
  }
}
