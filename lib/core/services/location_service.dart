import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static const LocationSettings _locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  /// Check and request location permissions
  static Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are disabled. Please enable location services.',
      );
    }

    // Check current permission status
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException(
          'Location permissions are denied. Please grant location access.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permissions are permanently denied. Please enable them in settings.',
      );
    }

    return true;
  }

  /// Get current location with full details
  static Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      // check permission
      await _handleLocationPermission();

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        throw LocationServiceException(
          'Unable to get address for current location',
        );
      }

      final placemark = placemarks.first;
      final address = _formatAddress(placemark);

      return {
        'address': address,
        'shortAddress': _formatShortAddress(placemark),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp,
        'placemark': {
          'name': placemark.name ?? '',
          'street': placemark.street ?? '',
          'locality': placemark.locality ?? '',
          'administrativeArea': placemark.administrativeArea ?? '',
          'postalCode': placemark.postalCode ?? '',
          'country': placemark.country ?? '',
          'isoCountryCode': placemark.isoCountryCode ?? '',
        },
      };
    } on LocationServiceException {
      rethrow; // Re-throw our custom exceptions
    } catch (e) {
      if (e.toString().contains('location_permissions_denied')) {
        throw LocationServiceException('Location permission denied');
      } else if (e.toString().contains('location_services_disabled')) {
        throw LocationServiceException('Location services disabled');
      } else {
        throw LocationServiceException(
          'Failed to get current location: ${e.toString()}',
        );
      }
    }
  }

  /// Get last known location (faster but might be outdated)
  static Future<Map<String, dynamic>?> getLastKnownLocation() async {
    try {
      await _handleLocationPermission();

      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) return null;

      final placemark = placemarks.first;
      final address = _formatAddress(placemark);

      return {
        'address': address,
        'shortAddress': _formatShortAddress(placemark),
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp,
        'isLastKnown': true,
        'placemark': {
          'name': placemark.name ?? '',
          'street': placemark.street ?? '',
          'locality': placemark.locality ?? '',
          'administrativeArea': placemark.administrativeArea ?? '',
          'postalCode': placemark.postalCode ?? '',
          'country': placemark.country ?? '',
          'isoCountryCode': placemark.isoCountryCode ?? '',
        },
      };
    } catch (e) {
      return null;
    }
  }

  /// Get address from coordinates
  static Future<Map<String, dynamic>?> getAddressFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isEmpty) return null;

      final placemark = placemarks.first;
      final address = _formatAddress(placemark);

      return {
        'address': address,
        'shortAddress': _formatShortAddress(placemark),
        'latitude': latitude,
        'longitude': longitude,
        'placemark': {
          'name': placemark.name ?? '',
          'street': placemark.street ?? '',
          'locality': placemark.locality ?? '',
          'administrativeArea': placemark.administrativeArea ?? '',
          'postalCode': placemark.postalCode ?? '',
          'country': placemark.country ?? '',
          'isoCountryCode': placemark.isoCountryCode ?? '',
        },
      };
    } catch (e) {
      throw LocationServiceException('Failed to get address: ${e.toString()}');
    }
  }

  /// Get coordinated from address
  static Future<List<Map<String, dynamic>>> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final locations = await locationFromAddress(address);

      return locations
          .map(
            (location) => {
              'latitude': location.latitude,
              'longitude': location.longitude,
              'timestamp': DateTime.now(),
            },
          )
          .toList();
    } catch (e) {
      throw LocationServiceException(
        'Failed to get coordinates: ${e.toString()}',
      );
    }
  }

  /// Calculate distance between two points
  static double calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate bearing between two points
  static double calculateBearing({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Format address for display (full address)
  static String _formatAddress(Placemark placemark) {
    final parts = <String>[];
    
    // Add street number and name
    if (placemark.name != null && 
        placemark.name!.isNotEmpty && 
        placemark.name != placemark.locality) {
      parts.add(placemark.name!);
    }
    
    if (placemark.street != null && 
        placemark.street!.isNotEmpty &&
        placemark.street != placemark.name) {
      parts.add(placemark.street!);
    }
    
    // Add locality (city/town)
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    
    // Add administrative area (state/province) if different from locality
    if (placemark.administrativeArea != null && 
        placemark.administrativeArea!.isNotEmpty &&
        placemark.administrativeArea != placemark.locality) {
      parts.add(placemark.administrativeArea!);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }

  /// Format short address for display (street + locality)
  static String _formatShortAddress(Placemark placemark) {
    final parts = <String>[];
    
    if (placemark.name != null && placemark.name!.isNotEmpty) {
      parts.add(placemark.name!);
    } else if (placemark.street != null && placemark.street!.isNotEmpty) {
      parts.add(placemark.street!);
    }
    
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      parts.add(placemark.locality!);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : 'Current Location';
  }

  /// Check if location services are available
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current permission status
  static Future<LocationPermission> getPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Stream of position updates
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(locationSettings: _locationSettings);
  }

  /// Check if coordinates are valid
  static bool isValidCoordinate({
    required double latitude,
    required double longitude,
  }) {
    return latitude >= -90 && 
           latitude <= 90 && 
           longitude >= -180 && 
           longitude <= 180;
  }

  /// Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()}m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  /// Format duration for display
  static String formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

// Custom exception for location service errors
class LocationServiceException implements Exception {
  final String message;

  const LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}
