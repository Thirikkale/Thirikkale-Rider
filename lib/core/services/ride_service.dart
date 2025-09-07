import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:thirikkale_rider/core/config/api_config.dart';

class RideService {
  static Future<Map<String, dynamic>> requestRide({
    required String userId,
    required String pickupLocation,
    required double pickupLatitude,
    required double pickupLongitude,
    required String dropoffLocation,
    required double dropoffLatitude,
    required double dropoffLongitude,
    required String rideType,
    required String token,
  }) async {
    final url = Uri.parse(ApiConfig.requestRide);
    final headers = ApiConfig.getAuthHeaders(token);

    final body = jsonEncode({
      'userId': userId,
      'pickupLocation': pickupLocation,
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'dropoffLocation': dropoffLocation,
      'dropoffLatitude': dropoffLatitude,
      'dropoffLongitude': dropoffLongitude,
      'rideType': rideType,
      // You can add other optional fields from the DTO here if needed
      // 'passengerCount': 1,
      // 'isSharedRide': false,
    });

    print('--- 🚗🚗🚗RideService: Requesting Ride ---');
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    try {
      final response = await http.post(url, headers: headers, body: body);

      // --- DEBUG PRINTS ---
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      // --------------------

      return _handleResponse(response);
    } catch (e) {
      // --- PRINT ---
      print('Error in requestRide: $e');
      // -----------------
      throw Exception('Failed to request ride: $e');
    }
  }

  // a generic method to handle HTTP responses
  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      // --- PRINT ---
      print('API Error: Status ${response.statusCode}, Body: ${response.body}');
      // -----------------
      throw Exception(
        'API call failed with status code: ${response.statusCode}',
      );
    }
  }
}
