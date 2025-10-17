import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thirikkale_rider/core/config/api_config.dart';

class PricingService {
	/// Get all active pricing configurations (ignores OTHER type)
	static Future<List<Map<String, dynamic>>> getAllPricings() async {
		try {
			final url = ApiConfig.pricingAll;
			print('[PricingService] Fetching all pricings from: $url');
			
			final response = await http.get(
				Uri.parse(url),
				headers: ApiConfig.defaultHeaders,
			);
			
			print('[PricingService] Response status: ${response.statusCode}');
			print('[PricingService] Response body: ${response.body}');
			
			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				print('[PricingService] Decoded ${data.length} pricing entries');
				
				// Only include active and not OTHER
				final filtered = data
						.where((json) => json['active'] == true && json['vehicleType'] != 'OTHER')
						.map((json) => Map<String, dynamic>.from(json))
						.toList();
				
				print('[PricingService] Filtered to ${filtered.length} active entries (excluding OTHER)');
				return filtered;
			} else {
				throw Exception('Failed to get pricing data: ${response.statusCode} - ${response.body}');
			}
		} catch (e, stack) {
			print('[PricingService] Exception in getAllPricings: $e');
			print('[PricingService] Stack trace: $stack');
			rethrow;
		}
	}

	/// Get pricing for a specific vehicle type
	static Future<Map<String, dynamic>?> getPricingByVehicleType(String vehicleType) async {
			final response = await http.get(
				Uri.parse(ApiConfig.getPricingByVehicle(vehicleType)),
				headers: ApiConfig.defaultHeaders,
			);
		if (response.statusCode == 200) {
			final data = json.decode(response.body);
			if (data['active'] == true && data['vehicleType'] != 'OTHER') {
				return Map<String, dynamic>.from(data);
			}
			return null;
		} else {
			return null;
		}
	}

	/// Calculate price for a ride
	static Future<Map<String, dynamic>?> calculatePrice({
		required String vehicleType,
		required double distanceKm,
		double waitingTimeMin = 0.0,
	}) async {
		try {
			final url = ApiConfig.pricingCalculate;
			final requestBody = {
				'vehicleType': vehicleType,
				'distanceKm': distanceKm,
				'waitingTimeMin': waitingTimeMin,
			};
			
			print('[PricingService] Calculating price for $vehicleType');
			print('[PricingService] URL: $url');
			print('[PricingService] Request body: $requestBody');
			
			final response = await http.post(
				Uri.parse(url),
				headers: ApiConfig.defaultHeaders,
				body: json.encode(requestBody),
			);
			
			print('[PricingService] Calculate response status: ${response.statusCode}');
			print('[PricingService] Calculate response body: ${response.body}');
			
			if (response.statusCode == 200) {
				final data = json.decode(response.body);
				print('[PricingService] Total price for $vehicleType: ${data['totalPrice']} ${data['currency']}');
				return Map<String, dynamic>.from(data);
			} else {
				print('[PricingService] Failed to calculate price: ${response.statusCode} - ${response.body}');
				return null;
			}
		} catch (e, stack) {
			print('[PricingService] Exception in calculatePrice: $e');
			print('[PricingService] Stack trace: $stack');
			rethrow;
		}
	}
}
