import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/services/location_service.dart';
import 'package:thirikkale_rider/core/services/places_api_service.dart';
import 'package:thirikkale_rider/core/services/search_history_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationProvider extends ChangeNotifier {
  // Current location state
  Map<String, dynamic>? _currentLocation;
  bool _isLoadingCurrentLocation = false;
  String? _locationError;

  // Places search state
  List<Map<String, dynamic>> _placePredictions = [];
  bool _isSearchingPlaces = false;
  String? _searchError;

  // Session management
  String _sessionToken = '';

  // Getters
  Map<String, dynamic>? get currentLocation => _currentLocation;
  bool get isLoadingCurrentLocation => _isLoadingCurrentLocation;
  String? get locationError => _locationError;

  List<Map<String, dynamic>> get placePredictions => _placePredictions;
  bool get isSearchingPlaces => _isSearchingPlaces;
  String? get searchError => _searchError;

  String get sessionToken => _sessionToken;

  // Helper methods for state management
  void _setLoadingCurrentLocation(bool loading) {
    _isLoadingCurrentLocation = loading;
    notifyListeners();
  }

  void _setCurrentLocation(Map<String, dynamic>? location) {
    _currentLocation = location;
    notifyListeners();
  }

  void _setLocationError(String? error) {
    _locationError = error;
    notifyListeners();
  }

  void _setSearchingPlaces(bool searching) {
    _isSearchingPlaces = searching;
    notifyListeners();
  }

  void _setPlacePredictions(List<Map<String, dynamic>> predictions) {
    _placePredictions = predictions;
    notifyListeners();
  }

  void _setSearchError(String? error) {
    _searchError = error;
    notifyListeners();
  }

  void _resetLocationState() {
    _currentLocation = null;
    _isLoadingCurrentLocation = false;
    _locationError = null;
  }

  void _resetSearchState() {
    _placePredictions = [];
    _isSearchingPlaces = false;
    _searchError = null;
  }

  // Current Location Methods
  Future<void> getCurrentLocation() async {
    _setLoadingCurrentLocation(true);
    _setLocationError(null);

    try {
      final location = await LocationService.getCurrentLocation();
      _setCurrentLocation(location);
      _setLocationError(null);
    } on LocationServiceException catch (e) {
      _setLocationError(e.message);
      _setCurrentLocation(null);
    } catch (e) {
      _setLocationError('Failed to get location: ${e.toString()}');
      _setCurrentLocation(null);
    } finally {
      _setLoadingCurrentLocation(false);
    }
  }

  // Try to get last known location first (faster)
  Future<void> getLocationQuick() async {
    _setLoadingCurrentLocation(true);
    _setLocationError(null);

    try {
      // Try last known location first
      final lastKnown = await LocationService.getLastKnownLocation();
      if (lastKnown != null) {
        _setCurrentLocation(lastKnown);
      }

      // Then get fresh location
      final location = await LocationService.getCurrentLocation();
      _setCurrentLocation(location);
      _setLocationError(null);
    } on LocationServiceException catch (e) {
      _setLocationError(e.message);
      if (_currentLocation == null) {
        _setCurrentLocation(null);
      }
    } catch (e) {
      _setLocationError('Failed to get location: ${e.toString()}');
      if (_currentLocation == null) {
        _setCurrentLocation(null);
      }
    } finally {
      _setLoadingCurrentLocation(false);
    }
  }

  // Places Search Methods
  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      clearSearchResults();
      return;
    }

    _setSearchingPlaces(true);
    _setSearchError(null);

    try {
      final predictions = await PlacesApiService.getPlacePredictions(
        query,
        sessionToken: _sessionToken,
        latitude: _currentLocation?['latitude'],
        longitude: _currentLocation?['longitude'],
      );

      _setPlacePredictions(predictions);
      _setSearchError(null);
    } on PlacesApiException catch (e) {
      _setSearchError(e.message);
      _setPlacePredictions([]);
    } catch (e) {
      _setSearchError('Search failed. Please try again.');
      _setPlacePredictions([]);
    } finally {
      _setSearchingPlaces(false);
    }
  }

  void clearSearchResults() {
    _setPlacePredictions([]);
  }

  void generateNewSessionToken() {
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Get formatted address string
  String get currentLocationAddress {
    if (_currentLocation != null) {
      return _currentLocation!['shortAddress'] ??
          _currentLocation!['address'] ??
          'Current Location';
    }
    return 'Current Location';
  }

  // Check if location permission is needed
  bool get needsLocationPermission =>
      _currentLocation == null && _locationError != null;

  // Get coordinates
  double? get currentLatitude => _currentLocation?['latitude'];
  double? get currentLongitude => _currentLocation?['longitude'];

  // Reset all states
  void reset() {
    _resetLocationState();
    _resetSearchState();
    generateNewSessionToken();
    notifyListeners();
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await LocationService.openLocationSettings();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await LocationService.openAppSettings();
  }

  // Search History Methods
  Future<List<Map<String, dynamic>>> getSearchHistory() async {
    return await SearchHistoryService.getSearchHistory();
  }

  Future<List<Map<String, dynamic>>> getRecentSearchesWithFallback() async {
    return await SearchHistoryService.getRecentSearchesWithFallback();
  }

  Future<void> addToSearchHistory(Map<String, dynamic> location) async {
    await SearchHistoryService.addToHistory(location);
  }

  Future<void> clearSearchHistory() async {
    await SearchHistoryService.clearHistory();
  }

  // Reverse Geocoding Methods
  Future<String> reverseGeocode(double latitude, double longitude) async {
    try {
      // Try Places API first for better formatted addresses
      final placeDetails = await getPlaceDetailsFromCoordinates(latitude, longitude);
      if (placeDetails != null && placeDetails['formatted_address'] != null) {
        return placeDetails['formatted_address'];
      }
      
      // Fallback to geocoding package
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return formatPlacemark(placemarks.first);
      }
      
      return 'Unknown Location';
    } catch (e) {
      print('Error in reverse geocoding: $e');
      return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
    }
  }

  String formatPlacemark(Placemark placemark) {
    List<String> addressParts = [];
    
    // Add more detailed address information
    if (placemark.name?.isNotEmpty == true) {
      addressParts.add(placemark.name!);
    }
    if (placemark.street?.isNotEmpty == true && placemark.street != placemark.name) {
      addressParts.add(placemark.street!);
    }
    if (placemark.subLocality?.isNotEmpty == true) {
      addressParts.add(placemark.subLocality!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true && placemark.administrativeArea != placemark.locality) {
      addressParts.add(placemark.administrativeArea!);
    }
    
    final address = addressParts.isNotEmpty ? addressParts.join(', ') : 'Unknown Location';
    print('Formatted address: $address');
    return address;
  }

  Future<Map<String, dynamic>?> getPlaceDetailsFromCoordinates(double latitude, double longitude) async {
    try {
      // Use reverse geocoding first to get address
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final address = formatPlacemark(placemark);
        
        // Create a detailed location name using available data
        String locationName = address;
        if (placemark.name?.isNotEmpty == true) {
          locationName = placemark.name!;
        } else if (placemark.subLocality?.isNotEmpty == true) {
          locationName = placemark.subLocality!;
        } else if (placemark.locality?.isNotEmpty == true) {
          locationName = placemark.locality!;
        }
        
        print('Place details from coordinates - Name: $locationName, Address: $address');
        
        // Return the geocoded address with coordinates
        return {
          'formatted_address': address,
          'geometry': {
            'location': {
              'lat': latitude,
              'lng': longitude,
            }
          },
          'place_id': 'custom_${latitude}_${longitude}', // Custom place ID
          'name': locationName,
          'types': ['point_of_interest'],
        };
      }
      return null;
    } catch (e) {
      print('Error getting place details from coordinates: $e');
      return null;
    }
  }

  // Map Pin Position Calculation
  LatLng calculatePinPosition(CameraPosition cameraPosition, int locatorHeightFromAbove) {
    // The pin is displayed at locatorHeightFromAbove% from top instead of center (50%)
    // We need to calculate the latitude offset based on this visual difference
    
    final double pinPositionRatio = locatorHeightFromAbove / 100.0; // Convert to ratio (0.30 for 30%)
    final double centerRatio = 0.5; // Camera center is at 50% from top
    final double offsetRatio = pinPositionRatio - centerRatio; // Negative means pin is above center
    
    // Calculate the latitude offset based on the zoom level and screen position difference
    // Higher zoom levels need smaller offsets, lower zoom levels need larger offsets
    final double zoomFactor = cameraPosition.zoom;
    final double baseLatOffset = 0.001; // Base offset for zoom level 15
    final double scaledLatOffset = baseLatOffset * (15.0 / zoomFactor); // Scale based on zoom
    
    // Apply the offset - negative offsetRatio means we move north (increase latitude)
    final double latitudeOffset = -offsetRatio * scaledLatOffset * 4; // Multiply by 4 for more precise adjustment
    
    return LatLng(
      cameraPosition.target.latitude + latitudeOffset,
      cameraPosition.target.longitude, // Longitude stays the same as pin is centered horizontally
    );
  }
}
