import 'dart:convert';
import 'dart:io';

import 'package:thirikkale_rider/core/services/env_service.dart';
import 'package:http/http.dart' as http;

class PlacesApiService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api';
  static const Duration _timeout = Duration(seconds: 10);

  static Future<List<Map<String, dynamic>>> getPlacePredictions(
    String input, {
    String? sessionToken,
    double? latitude,
    double? longitude,
    String language = 'en',
    List<String> types = const ['establishment', 'geocode'],
  }) async {
    if (input.trim().isEmpty) return [];

    try {
      final apiKey = EnvService.googleMapsApiKey;
      if (apiKey.isEmpty) {
        throw PlacesApiException('Google Maps API key not configured');
      }

      // Build URL with parameters
      final uri = _buildAutocompleteUri(
        input: input,
        apiKey: apiKey,
        sessionToken: sessionToken,
        latitude: latitude,
        longitude: longitude,
        language: language,
        types: types,
      );

      final response = await http.get(uri).timeout(_timeout);

      return _handleAutocompleteResponse(response);
    } on SocketException {
      throw PlacesApiException('No internet connection');
    } on HttpException {
      throw PlacesApiException('Network error occurred');
    } catch (e) {
      if (e is PlacesApiException) rethrow;
      throw PlacesApiException('Failed to fetch places: ${e.toString()}');
    }
  }

  static Uri _buildAutocompleteUri({
    required String input,
    required String apiKey,
    String? sessionToken,
    double? latitude,
    double? longitude,
    String language = 'en',
    List<String> types = const [],
  }) {
    final queryParams = <String, String>{
      'input': input,
      'key': apiKey,
      'language': language,
    };

    if (sessionToken != null) {
      queryParams['sessiontoken'] = sessionToken;
    }

    if (latitude != null && longitude != null) {
      queryParams['location'] = '$latitude,$longitude';
      queryParams['radius'] = '50000'; // 50km radius
    }

    if (types.isNotEmpty) {
      queryParams['types'] = types.join('|');
    }

    return Uri.parse(
      '$_baseUrl/place/autocomplete/json',
    ).replace(queryParameters: queryParams);
  }

  static List<Map<String, dynamic>> _handleAutocompleteResponse(
    http.Response response,
  ) {
    if (response.statusCode != 200) {
      throw PlacesApiException(
        'API request failed with status ${response.statusCode}',
      );
    }

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body);
    } catch (e) {
      throw PlacesApiException('Invalid API response format');
    }

    final status = json['status'] as String?;

    switch (status) {
      case 'OK':
        final predictions = json['predictions'] as List? ?? [];
        return predictions.map((p) => p as Map<String, dynamic>).toList();

      case 'ZERO_RESULTS':
        return []; // Valid response, just no results

      case 'INVALID_REQUEST':
        throw PlacesApiException('Invalid API request parameters');

      case 'REQUEST_DENIED':
        throw PlacesApiException('API key invalid or request denied');

      case 'OVER_QUERY_LIMIT':
        throw PlacesApiException('API quota exceeded');

      default:
        final errorMessage =
            json['error_message'] as String? ?? 'Unknown error';
        throw PlacesApiException('API Error: $errorMessage');
    }
  }

  static Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    try {
      final apiKey = EnvService.googleMapsApiKey;
      if (apiKey.isEmpty) {
        throw PlacesApiException('Google Maps API key not configured');
      }

      final uri = Uri.parse('$_baseUrl/place/details/json').replace(
        queryParameters: {
          'place_id': placeId,
          'key': apiKey,
          'fields': 'formatted_address,geometry,name,place_id,types',
        },
      );

      final response = await http.get(uri).timeout(_timeout);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);

        if (json['status'] == 'OK') {
          return json['result'] as Map<String, dynamic>?;
        }
      }
    } catch (e) {
      if (e is PlacesApiException) rethrow;
      throw PlacesApiException('Failed to get place details: ${e.toString()}');
    }

    return null;
  }
}

// Custom exception for better error handling
class PlacesApiException implements Exception {
  final String message;

  const PlacesApiException(this.message);

  @override
  String toString() => 'PlacesApiException: $message';
}
