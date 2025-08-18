import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapCache {
  static Set<Marker>? markers;
  static Set<Polyline>? polylines;
  static double? pickupLat;
  static double? pickupLng;
  static double? destLat;
  static double? destLng;

  static void setRoute({
    required double pickupLat,
    required double pickupLng,
    required double destLat,
    required double destLng,
    required Set<Marker> markers,
    required Set<Polyline> polylines,
  }) {
    MapCache.pickupLat = pickupLat;
    MapCache.pickupLng = pickupLng;
    MapCache.destLat = destLat;
    MapCache.destLng = destLng;
    MapCache.markers = markers;
    MapCache.polylines = polylines;
  }

  static void clear() {
    markers = null;
    polylines = null;
    pickupLat = null;
    pickupLng = null;
    destLat = null;
    destLng = null;
  }
}
