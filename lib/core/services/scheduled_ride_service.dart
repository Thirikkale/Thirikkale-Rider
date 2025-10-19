import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thirikkale_rider/core/config/api_config.dart';

class ScheduledRideCreateRequestDto {
  final String riderId;
  final String pickupAddress;
  final double pickupLatitude;
  final double pickupLongitude;
  final String dropoffAddress;
  final double dropoffLatitude;
  final double dropoffLongitude;
  final int passengers;
  final bool isSharedRide;
  final String scheduledTime; // ISO 8601 UTC
  final String rideType;
  final String vehicleType;
  final double? distanceKm;
  final int? waitingTimeMin;
  final bool? isWomenOnly;
  final String? driverId;
  final double? maxFare;
  final String? specialRequests;

  ScheduledRideCreateRequestDto({
    required this.riderId,
    required this.pickupAddress,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.dropoffAddress,
    required this.dropoffLatitude,
    required this.dropoffLongitude,
    required this.passengers,
    required this.isSharedRide,
    required this.scheduledTime,
    required this.rideType,
    required this.vehicleType,
    this.distanceKm,
    this.waitingTimeMin,
    this.isWomenOnly,
    this.driverId,
    this.maxFare,
    this.specialRequests,
  });

  Map<String, dynamic> toJson() => {
        'riderId': riderId,
        'pickupAddress': pickupAddress,
        'pickupLatitude': pickupLatitude,
        'pickupLongitude': pickupLongitude,
        'dropoffAddress': dropoffAddress,
        'dropoffLatitude': dropoffLatitude,
        'dropoffLongitude': dropoffLongitude,
        'passengers': passengers,
        'isSharedRide': isSharedRide,
        'scheduledTime': scheduledTime,
        'rideType': rideType,
        'vehicleType': vehicleType,
        if (distanceKm != null) 'distanceKm': distanceKm,
        if (waitingTimeMin != null) 'waitingTimeMin': waitingTimeMin,
        if (isWomenOnly != null) 'isWomenOnly': isWomenOnly,
        if (driverId != null) 'driverId': driverId,
        if (maxFare != null) 'maxFare': maxFare,
        if (specialRequests != null) 'specialRequests': specialRequests,
      };
}

class ScheduledRideService {
  static Future<Map<String, dynamic>> createScheduledRide(
      ScheduledRideCreateRequestDto dto) async {
    final url = ScheduledRideEndpoints.create;
    final response = await http.post(
      Uri.parse(url),
      headers: ApiConfig.defaultHeaders,
      body: jsonEncode(dto.toJson()),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['status'] != null && !(data['status'] as String).startsWith('ERROR:')) {
      return data;
    } else {
      // Backend may return 200 with status = "ERROR: ..."
      final errorMsg = data['status'] ?? data['message'] ?? 'Failed to schedule ride';
      throw Exception(errorMsg);
    }
  }

  // Fetch scheduled rides for a rider
  static Future<List<Map<String, dynamic>>> getRidesByRider(
      {required String riderId, String? token}) async {
    final url = ScheduledRideEndpoints.byRider(riderId);
    print('📲 Fetching scheduled rides from: $url');
    
    final headers = {
      ...ApiConfig.defaultHeaders,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    
    
    final response = await http.get(Uri.parse(url), headers: headers);
    
    print('📥 Scheduled rides response status: ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('❌ Failed to fetch scheduled rides: ${response.statusCode}');
      throw Exception('Failed to fetch scheduled rides (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    print('🔍 Decoded scheduled rides data type: ${data.runtimeType}');
    
    if (data is List) {
      print('📋 Found ${data.length} scheduled rides (list format)');
      final result = data.cast<Map<String, dynamic>>();
      // Log a sample of the first ride's data
      if (result.isNotEmpty) {
        print('🚕 Sample ride data: ${result.first}');
        print('🚕 Sample ride driverId: ${result.first['driverId']}');
      }
      return result;
    }
    
    if (data is Map && data['data'] is List) {
      print('📋 Found ${(data['data'] as List).length} scheduled rides (map.data format)');
      final result = (data['data'] as List).cast<Map<String, dynamic>>();
      // Log a sample of the first ride's data
      if (result.isNotEmpty) {
        print('🚕 Sample ride data: ${result.first}');
        print('🚕 Sample ride driverId: ${result.first['driverId']}');
      }
      return result;
    }
    
    print('⚠️ Unexpected scheduled rides response format: $data');
    throw Exception('Unexpected scheduled rides response format');
  }

  // Cancel a scheduled ride by ID
  static Future<void> cancelById(String rideId, {String? token}) async {
    final url = ScheduledRideEndpoints.deleteById(rideId);
    final headers = {
      ...ApiConfig.defaultHeaders,
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final response = await http.delete(Uri.parse(url), headers: headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to cancel ride (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    if (data is Map && data['status'] != null && data['status'].toString().startsWith('ERROR:')) {
      throw Exception(data['status']);
    }
  }
}
