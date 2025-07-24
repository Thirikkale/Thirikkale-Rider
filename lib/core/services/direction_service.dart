import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:thirikkale_rider/core/services/env_service.dart';

class DirectionsService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  static Future<DirectionsResult?> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    try {
      final apiKey = EnvService.googleMapsApiKey;
      if (apiKey.isEmpty) {
        print('DirectionsService: Google Maps API key not configured');
        return null;
      }

      print('DirectionsService: Using API key: ${apiKey.substring(0, 10)}...');

      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'key': apiKey,
          'mode': 'driving',
        },
      );

      print('DirectionsService: Making request to: ${uri.toString()}');

      final response = await http.get(uri);

      print('DirectionsService: Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        print('DirectionsService: API status: ${json['status']}');
        
        if (json['status'] == 'OK' && json['routes'].isNotEmpty) {
          final route = json['routes'][0];
          final leg = route['legs'][0];
          
          print('DirectionsService: Success - Distance: ${leg['distance']['text']}, Duration: ${leg['duration']['text']}');
          
          return DirectionsResult(
            polylinePoints: route['overview_polyline']['points'],
            distance: leg['distance']['text'],
            duration: leg['duration']['text'],
          );
        } else {
          print('DirectionsService: No routes found or API error: ${json['status']}');
          if (json['error_message'] != null) {
            print('DirectionsService: Error message: ${json['error_message']}');
          }
        }
      } else {
        print('DirectionsService: HTTP Error: ${response.statusCode}');
        print('DirectionsService: Response body: ${response.body}');
      }
    } catch (e) {
      print('DirectionsService: Exception getting directions: $e');
    }

    return null;
  }
}

class DirectionsResult {
  final String polylinePoints;
  final String distance;
  final String duration;

  DirectionsResult({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
  });
}