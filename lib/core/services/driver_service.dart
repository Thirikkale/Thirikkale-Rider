import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thirikkale_rider/core/config/api_config.dart';

class DriverService {
  /// Get driver card details for display
  Future<Map<String, dynamic>> getDriverCard(String driverId) async {
    try {
      // Validate driver ID before making the API call
      if (driverId.isEmpty || driverId == "null") {
        print('❌ Invalid driver ID provided: "$driverId"');
        throw Exception('Invalid driver ID');
      }

      print('🚗 Fetching driver card details for driver: $driverId');
      print('📍 Endpoint: ${ApiConfig.getDriverCard(driverId)}');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getDriverCard(driverId)),
            headers: ApiConfig.defaultHeaders,
          )
          .timeout(ApiConfig.connectTimeout);

      print('📨 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Driver card fetched successfully: $responseData');
        
        // Additional validation on the returned data
        if (responseData == null || responseData.isEmpty) {
          print('⚠️ Driver data is empty or null');
          throw Exception('Driver data is empty');
        }
        
        return responseData;
      } else if (response.statusCode == 404) {
        print('❌ Driver not found');
        throw Exception('Driver not found');
      } else {
        print('❌ Failed to fetch driver card: ${response.statusCode}');
        throw Exception('Failed to fetch driver details');
      }
    } catch (e) {
      print('💥 Error fetching driver card: $e');
      throw Exception('Failed to fetch driver details: $e');
    }
  }

  /// Get driver card details with authentication
  Future<Map<String, dynamic>> getDriverCardAuthenticated(
    String driverId,
    String token,
  ) async {
    try {
      // Validate driver ID before making the API call
      if (driverId.isEmpty || driverId == "null") {
        print('❌ Invalid driver ID provided: "$driverId"');
        throw Exception('Invalid driver ID');
      }
      
      // Validate token
      if (token.isEmpty) {
        print('❌ Empty authentication token provided');
        throw Exception('Empty authentication token');
      }

      print('🚗 Fetching driver card details (authenticated) for driver: $driverId');
      print('📍 Endpoint: ${ApiConfig.getDriverCard(driverId)}');

      final response = await http
          .get(
            Uri.parse(ApiConfig.getDriverCard(driverId)),
            headers: ApiConfig.getAuthHeaders(token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📨 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Driver card fetched successfully: $responseData');
        
        // Additional validation on the returned data
        if (responseData == null || responseData.isEmpty) {
          print('⚠️ Driver data is empty or null');
          throw Exception('Driver data is empty');
        }
        
        return responseData;
      } else if (response.statusCode == 404) {
        print('❌ Driver not found');
        throw Exception('Driver not found');
      } else {
        print('❌ Failed to fetch driver card: ${response.statusCode}');
        throw Exception('Failed to fetch driver details');
      }
    } catch (e) {
      print('💥 Error fetching driver card: $e');
      throw Exception('Failed to fetch driver details: $e');
    }
  }
}