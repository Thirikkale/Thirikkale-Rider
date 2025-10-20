import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thirikkale_rider/core/config/api_config.dart';

class RideStatusService {
  static Timer? _timer;
  static StreamController<Map<String, dynamic>>? _streamController;

  static Stream<Map<String, dynamic>> startRideStatusPolling({
    required String rideId,
    required String token,
    Duration interval = const Duration(seconds: 5),
  }) {
    _streamController = StreamController<Map<String, dynamic>>.broadcast();

    _timer = Timer.periodic(interval, (timer) async {
      try {
        final rideData = await _fetchRideStatus(rideId, token);
        if (_streamController != null && !_streamController!.isClosed) {
          _streamController!.add(rideData);
        }
      } catch (e) {
        print('❌ Error fetching ride status: $e');
        if (_streamController != null && !_streamController!.isClosed) {
          _streamController!.addError(e);
        }
      }
    });

    return _streamController!.stream;
  }

  static void stopRideStatusPolling() {
    _timer?.cancel();
    _timer = null;
    _streamController?.close();
    _streamController = null;
  }

  static Future<Map<String, dynamic>> _fetchRideStatus(
    String rideId,
    String token,
  ) async {
    // Use the same endpoint pattern as the working ride request
    final url = Uri.parse('${ApiConfig.rideServiceBaseUrl}/rides/$rideId');

    print('🔄 Fetching ride status from: $url');
    print(
      '🔑 Using token: ${token.length > 50 ? '${token.substring(0, 50)}...' : token}',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('📊 Ride status response: ${response.statusCode}');
    print('📊 Ride status body: ${response.body}');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Authentication failed - please login again');
    } else {
      throw Exception(
        'Failed to fetch ride status: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<void> cancelRide({
    required String rideId,
    required String token,
    required String reason,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.cancelRide(rideId)}?reason=${Uri.encodeComponent(reason)}',
    );

    print('❌ Cancelling ride: $rideId');
    print('❌ Cancel URL with params: $url');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('❌ Cancel response: ${response.statusCode}');
    print('🚫 Cancel response body: ${response.body}');

    if (response.statusCode == 401) {
      throw Exception('Authentication failed - please login again');
    } else if (response.statusCode != 200) {
      throw Exception(
        'Failed to cancel ride: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<void> rateDriver({
    required String rideId,
    required String token,
    required int rating,
    String? comment,
  }) async {
    final url = Uri.parse('${ApiConfig.rideServiceBaseUrl}/rides/$rideId/rate');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'rating': rating, 'comment': comment}),
    );

    if (response.statusCode == 401) {
      throw Exception('Authentication failed - please login again');
    } else if (response.statusCode != 200) {
      throw Exception(
        'Failed to rate driver: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
