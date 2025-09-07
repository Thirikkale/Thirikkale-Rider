import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:thirikkale_rider/core/config/api_config.dart';

class RiderService {
  // Register rider with Firebase token
  Future<Map<String, dynamic>> registerRider({
    required String firebaseToken,
    String? firstName,
    String? lastName,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      print('🚀 Starting rider registration/login...');
      print('📍 Endpoint: ${RiderEndpoints.register}');
      print('🎫 Token length: ${firebaseToken.length}');

      final requestBody = {
        'firebaseIdToken': firebaseToken,
        'platform': 'MOBILE_APP',
      };

      // Only add these fields if provided (for new registrations)
      if (firstName != null) requestBody['firstName'] = firstName;
      if (lastName != null) requestBody['lastName'] = lastName;
      if (emergencyContactName != null)
        requestBody['emergencyContactName'] = emergencyContactName;
      if (emergencyContactPhone != null)
        requestBody['emergencyContactPhone'] = emergencyContactPhone;

      print('📤 Request body: $requestBody');

      final response = await http
          .post(
            Uri.parse(RiderEndpoints.register),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📨 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      final responseData = jsonDecode(response.body);
      print('\n\n⭐⭐Response Data: $responseData⭐⭐\n');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Detect if this is a new registration or auto-login
        bool isNewRegistration = _isNewRegistration(responseData);

        return {
          'success': true,
          'data': responseData,
          'isNewRegistration': isNewRegistration,
          'isAutoLogin': !isNewRegistration,
          'riderId': responseData['userId'], // Use userId as riderId
          'message':
              responseData['message'] ??
              (isNewRegistration ? 'Registration successful' : 'Welcome back!'),
        };
      } else {
        // Handle error cases
        String errorMessage = _getErrorMessage(
          response.statusCode,
          responseData,
        );

        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
          'details': responseData,
        };
      }
    } catch (e) {
      print('❌ Registration/Login error: $e');
      return {
        'success': false,
        'error': 'Registration failed: $e',
        'type': 'unknown_error',
      };
    }
  }

  Future<Map<String, dynamic>> completeRiderProfile({
    required String riderId,
    required String firstName,
    required String lastName,
    required String jwtToken,
  }) async {
    try {
      print('🚀 Starting driver profile completion...');
      print('🆔 Driver ID: $riderId');
      print('👤 Name: $firstName $lastName');

      // final url = ApiConfig.completeProfile(riderId);
      final url = RiderEndpoints.completeProfile(riderId);

      final headers = {
        'Authorization': 'Bearer $jwtToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final body = jsonEncode({'firstName': firstName, 'lastName': lastName});

      print('🌐 Request URL: $url');
      print('📤 Request Body: $body');

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        return {
          'success': true,
          'data': responseData,
          'message': 'Profile completed successfully',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
          'statusCode': response.statusCode,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Driver not found',
          'statusCode': response.statusCode,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Profile completion failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Rider profile completion error: $e');
      return {
        'success': false,
        'error': 'Network error: Failed to complete profile',
      };
    }
  }

  // Login existing rider
  Future<Map<String, dynamic>> loginRider({
    required String firebaseToken,
  }) async {
    try {
      print('🚀 Starting rider login...');
      print('📍 Endpoint: ${RiderEndpoints.login}');

      final requestBody = {
        'firebaseIdToken': firebaseToken,
        'platform': 'MOBILE_APP',
      };

      final response = await http
          .post(
            Uri.parse(RiderEndpoints.login),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConfig.connectTimeout);

      print('📨 Login response status: ${response.statusCode}');
      print('📄 Login response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseData,
          'riderId': responseData['userId'],
          'message': responseData['message'] ?? 'Login successful',
        };
      } else {
        return {
          'success': false,
          'error': _getErrorMessage(response.statusCode, responseData),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {
        'success': false,
        'error': 'Login failed: $e',
        'type': 'unknown_error',
      };
    }
  }

  // Get rider profile
  Future<Map<String, dynamic>> getRiderProfile({
    required String riderId,
    required String jwtToken,
  }) async {
    try {
      print('📱 Getting rider profile for: $riderId');

      final response = await http
          .get(
            Uri.parse(RiderEndpoints.profile(riderId)),
            headers: ApiConfig.getAuthHeaders(jwtToken),
          )
          .timeout(ApiConfig.receiveTimeout);

      print('📨 Profile response status: ${response.statusCode}');
      print('📄 Profile response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Failed to get profile',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Profile error: $e');
      return {'success': false, 'error': 'Failed to get profile: $e'};
    }
  }

  // Update rider profile
  Future<Map<String, dynamic>> updateRiderProfile({
    required String riderId,
    required String jwtToken,
    String? firstName,
    String? lastName,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      print('🚀 Updating rider profile...');
      print('🆔 Rider ID: $riderId');

      final requestBody = <String, dynamic>{};

      if (firstName != null) requestBody['firstName'] = firstName;
      if (lastName != null) requestBody['lastName'] = lastName;
      if (emergencyContactName != null)
        requestBody['emergencyContactName'] = emergencyContactName;
      if (emergencyContactPhone != null)
        requestBody['emergencyContactPhone'] = emergencyContactPhone;

      print('📤 Request Body: $requestBody');

      final response = await http
          .put(
            Uri.parse(RiderEndpoints.updateProfile(riderId)),
            headers: ApiConfig.getAuthHeaders(jwtToken),
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConfig.sendTimeout);

      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
          'message': 'Profile updated successfully',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Session expired. Please login again.',
          'statusCode': response.statusCode,
        };
      } else if (response.statusCode == 404) {
        return {
          'success': false,
          'error': 'Rider not found',
          'statusCode': response.statusCode,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Profile update failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Rider profile update error: $e');
      return {
        'success': false,
        'error': 'Network error: Failed to update profile',
      };
    }
  }

  // Upload profile photo
  // Upload profile photo
  Future<Map<String, dynamic>> uploadProfilePhoto({
    required String riderId,
    required File imageFile,
    required String jwtToken,
  }) async {
    try {
      print('📤 Uploading profile photo for rider: $riderId');

      String endpoint = RiderEndpoints.profilePhoto(riderId);
      print('📍 Upload endpoint: $endpoint');

      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }

      // Check file size
      final fileSize = await imageFile.length();
      print('📏 File size: $fileSize bytes');

      if (fileSize == 0) {
        throw Exception('Image file is empty');
      }

      var request = http.MultipartRequest('POST', Uri.parse(endpoint));

      // Set headers
      request.headers.addAll(ApiConfig.getMultipartAuthHeaders(jwtToken));

      print('📤 Upload headers: ${request.headers}');

      // Determine MIME type based on file extension
      String fileName = path.basename(imageFile.path);
      String mimeType = 'image/jpeg'; // Default

      if (fileName.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (fileName.toLowerCase().endsWith('.jpg') ||
          fileName.toLowerCase().endsWith('.jpeg')) {
        mimeType = 'image/jpeg';
      }

      print('📁 File name: $fileName');
      print('🎭 MIME type: $mimeType');

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          'selfie',
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Send request
      var streamedResponse = await request.send().timeout(
        ApiConfig.sendTimeout,
      );
      var response = await http.Response.fromStream(streamedResponse);

      print('📨 Upload response status: ${response.statusCode}');
      print('📄 Upload response body: ${response.body}');

      return _handleUploadResponse(response);
    } on TimeoutException catch (e) {
      print('❌ Upload timeout: $e');
      return {
        'success': false,
        'error': 'Upload timed out. Please try again with a smaller image.',
        'type': 'timeout_error',
      };
    } on SocketException catch (e) {
      print('❌ Upload network error: $e');
      return {
        'success': false,
        'error': 'Network connection failed during upload.',
        'type': 'network_error',
      };
    } catch (e) {
      print('❌ Upload error: $e');
      return {
        'success': false,
        'error': 'Upload failed: $e',
        'type': 'unknown_error',
      };
    }
  }

  // Gender detection upload
  Future<Map<String, dynamic>> uploadGenderDetection({
    required String riderId,
    required File imageFile,
    required String jwtToken,
  }) async {
    try {
      print('📤 Uploading gender detection photo for rider: $riderId');

      String endpoint = RiderEndpoints.genderDetection(riderId);
      print('📍 Gender detection endpoint: $endpoint');

      // Validate file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file not found');
      }

      var request = http.MultipartRequest('POST', Uri.parse(endpoint));
      request.headers.addAll(ApiConfig.getMultipartAuthHeaders(jwtToken));

      String fileName = path.basename(imageFile.path);
      String mimeType =
          fileName.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'selfie',
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      var streamedResponse = await request.send().timeout(
        ApiConfig.sendTimeout,
      );
      var response = await http.Response.fromStream(streamedResponse);

      print('📨 Gender detection response status: ${response.statusCode}');
      print('📄 Gender detection response body: ${response.body}');

      return _handleUploadResponse(response);
    } catch (e) {
      print('❌ Gender detection error: $e');
      return {
        'success': false,
        'error': 'Gender detection failed: $e',
        'type': 'unknown_error',
      };
    }
  }

  // Skip gender detection - FIXED to handle empty responses
  Future<Map<String, dynamic>> skipGenderDetection({
    required String riderId,
    required String jwtToken,
  }) async {
    try {
      print('⏭️ Skipping gender detection for rider: $riderId');

      final response = await http
          .post(
            Uri.parse(RiderEndpoints.skipGender(riderId)),
            headers: ApiConfig.getAuthHeaders(jwtToken),
          )
          .timeout(ApiConfig.sendTimeout);

      print('📨 Skip gender response status: ${response.statusCode}');
      print('📄 Skip gender response body: "${response.body}"');

      // Check if response is successful
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Handle empty response body (which is causing the FormatException)
        if (response.body.trim().isEmpty) {
          print('✅ Empty response body - treating as success');
          return {
            'success': true,
            'message': 'Gender detection skipped successfully',
          };
        }

        // Try to parse JSON if response body is not empty
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'data': responseData,
            'message': 'Gender detection skipped successfully',
          };
        } catch (jsonError) {
          print('⚠️ JSON parse error but status OK: $jsonError');
          // If JSON parsing fails but HTTP status is successful, treat as success
          return {
            'success': true,
            'message': 'Gender detection skipped successfully',
          };
        }
      } else {
        // Handle error responses
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'error':
                responseData['message'] ?? 'Failed to skip gender detection',
            'statusCode': response.statusCode,
          };
        } catch (jsonError) {
          return {
            'success': false,
            'error':
                'Failed to skip gender detection (Status: ${response.statusCode})',
            'statusCode': response.statusCode,
          };
        }
      }
    } on TimeoutException catch (e) {
      print('❌ Skip timeout: $e');
      return {
        'success': false,
        'error': 'Request timed out. Please try again.',
        'type': 'timeout_error',
      };
    } on SocketException catch (e) {
      print('❌ Skip network error: $e');
      return {
        'success': false,
        'error': 'Network connection failed.',
        'type': 'network_error',
      };
    } on FormatException catch (e) {
      print(
        '✅ FormatException (likely empty response) - treating as success: $e',
      );
      // This specifically handles the FormatException you're seeing
      return {
        'success': true,
        'message': 'Gender detection skipped successfully',
      };
    } catch (e) {
      print('❌ Skip gender detection error: $e');
      return {
        'success': false,
        'error': 'Failed to skip gender detection: $e',
        'type': 'unknown_error',
      };
    }
  }

  // Get women-only access status
  Future<Map<String, dynamic>> getWomenOnlyStatus({
    required String riderId,
    required String jwtToken,
  }) async {
    try {
      print('👩 Getting women-only status for rider: $riderId');

      final response = await http
          .get(
            Uri.parse(RiderEndpoints.womenOnlyAccess(riderId)),
            headers: ApiConfig.getAuthHeaders(jwtToken),
          )
          .timeout(ApiConfig.receiveTimeout);

      print('📨 Women-only status response: ${response.statusCode}');
      print('📄 Women-only response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Failed to get women-only status',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Women-only status error: $e');
      return {'success': false, 'error': 'Failed to get women-only status: $e'};
    }
  }

  // Logout rider
  Future<Map<String, dynamic>> logoutRider({required String jwtToken}) async {
    try {
      print('🚪 Logging out rider...');

      final response = await http
          .post(
            Uri.parse(ApiConfig.logout),
            headers: ApiConfig.getAuthHeaders(jwtToken),
          )
          .timeout(ApiConfig.sendTimeout);

      print('📨 Logout response status: ${response.statusCode}');
      print('📄 Logout response body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Logged out successfully'};
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'error': responseData['message'] ?? 'Logout failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Logout error: $e');
      return {'success': false, 'error': 'Logout failed: $e'};
    }
  }

  // Refresh token
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      print('🔄 Refreshing access token...');

      final requestBody = {'refreshToken': refreshToken};

      final response = await http
          .post(
            Uri.parse(ApiConfig.refreshToken),
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(requestBody),
          )
          .timeout(ApiConfig.sendTimeout);

      print('📨 Refresh token response status: ${response.statusCode}');
      print('📄 Refresh token response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'data': responseData,
          'message': 'Token refreshed successfully',
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'] ?? 'Token refresh failed',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Refresh token error: $e');
      return {'success': false, 'error': 'Token refresh failed: $e'};
    }
  }

  // Helper methods
  bool _isNewRegistration(Map<String, dynamic> responseData) {
    if (responseData.containsKey('isNewRegistration')) {
      return responseData['isNewRegistration'] == true;
    }

    final hasCompleteProfile =
        responseData['firstName'] != null && responseData['lastName'] != null;
    return !hasCompleteProfile;
  }

  String _getErrorMessage(int statusCode, Map<String, dynamic> responseData) {
    switch (statusCode) {
      case 400:
        if (responseData['validationErrors'] != null) {
          final validationErrors = responseData['validationErrors'];
          final errorMessages = <String>[];
          validationErrors.forEach((field, message) {
            errorMessages.add('$field: $message');
          });
          return 'Validation failed: ${errorMessages.join(', ')}';
        }
        return responseData['message'] ?? 'Invalid request data';
      case 401:
        return 'Authentication failed. Please verify your phone number again.';
      case 403:
        return 'Access denied. Please check your permissions.';
      case 409:
        return 'Phone number already registered with different account.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return responseData['message'] ??
            responseData['error'] ??
            'Request failed';
    }
  }

  Map<String, dynamic> _handleUploadResponse(http.Response response) {
    if (response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'success': true, 'message': 'Upload successful'};
      } else {
        return {
          'success': false,
          'error': 'Upload failed with status ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }
    }

    final responseData = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        'data': responseData,
        'message': responseData['message'] ?? 'Upload successful',
      };
    } else {
      String errorMessage = 'Upload failed';

      switch (response.statusCode) {
        case 400:
          if (responseData['validationErrors'] != null) {
            final validationErrors = responseData['validationErrors'];
            final errorMessages = <String>[];
            validationErrors.forEach((field, message) {
              errorMessages.add('$field: $message');
            });
            errorMessage =
                'Upload validation failed: ${errorMessages.join(', ')}';
          } else {
            errorMessage = responseData['message'] ?? 'Invalid file format';
          }
          break;
        case 401:
          errorMessage = 'Authentication failed. Session expired.';
          break;
        case 403:
          errorMessage = 'Access denied. Rider not found or invalid token.';
          break;
        case 413:
          errorMessage = 'File too large. Please choose a smaller image.';
          break;
        case 415:
          errorMessage =
              'Unsupported file type. Please upload a valid image file.';
          break;
        default:
          errorMessage =
              responseData['message'] ??
              responseData['error'] ??
              'Upload failed';
      }

      return {
        'success': false,
        'error': errorMessage,
        'statusCode': response.statusCode,
        'details': responseData,
      };
    }
  }
}
