import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thirikkale_rider/core/config/api_config.dart';

/// Network connectivity test widget for multi-device setup
/// This helps verify that your Flutter app can reach the backend server
class NetworkTestWidget extends StatefulWidget {
  const NetworkTestWidget({super.key});

  @override
  State<NetworkTestWidget> createState() => _NetworkTestWidgetState();
}

class _NetworkTestWidgetState extends State<NetworkTestWidget> {
  bool _isLoading = false;
  String? _testResult;
  Color _resultColor = Colors.grey;

  // Test backend connectivity
  Future<void> _testConnectivity() async {
    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      // Test 1: Basic health check
      final healthResponse = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/health'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(const Duration(seconds: 10));

      if (healthResponse.statusCode == 200) {
        setState(() {
          _testResult = '✅ Backend connection successful!\nStatus: ${healthResponse.statusCode}';
          _resultColor = Colors.green;
        });
      } else {
        setState(() {
          _testResult = '⚠️ Backend responded with status: ${healthResponse.statusCode}';
          _resultColor = Colors.orange;
        });
      }
    } catch (e) {
      // Check specific error types
      String errorMessage;
      if (e.toString().contains('SocketException')) {
        errorMessage = '❌ Cannot reach backend server\n'
            'Check:\n'
            '• Backend IP address\n'
            '• Backend is running\n'
            '• Network connectivity\n'
            '• Firewall settings';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = '⏱️ Connection timeout\n'
            'Backend might be slow or network latency is high';
      } else {
        errorMessage = '❌ Connection failed: $e';
      }

      setState(() {
        _testResult = errorMessage;
        _resultColor = Colors.red;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Test specific endpoints
  Future<void> _testEndpoints() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing endpoints...';
    });

    final results = <String>[];

    // Test endpoints
    final endpoints = [
      {'name': 'Health Check', 'url': '${ApiConfig.baseUrl}/health'},
      {'name': 'Rider Register', 'url': ApiConfig.riderRegister},
      {'name': 'Rider Login', 'url': ApiConfig.riderLogin},
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await http.get(
          Uri.parse(endpoint['url']!),
          headers: ApiConfig.defaultHeaders,
        ).timeout(const Duration(seconds: 5));

        results.add('${endpoint['name']}: ✅ ${response.statusCode}');
      } catch (e) {
        results.add('${endpoint['name']}: ❌ Failed');
      }
    }

    setState(() {
      _testResult = results.join('\n');
      _resultColor = Colors.blue;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Network Connectivity Test',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Current configuration display
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Configuration:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Base URL: ${ApiConfig.baseUrl}'),
                Text('Connect Timeout: ${ApiConfig.connectTimeout.inSeconds}s'),
                Text('Receive Timeout: ${ApiConfig.receiveTimeout.inSeconds}s'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Test buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testConnectivity,
                  child: const Text('Test Connection'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _testEndpoints,
                  child: const Text('Test Endpoints'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Loading indicator
          if (_isLoading)
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Testing connection...'),
                ],
              ),
            ),

          // Test results
          if (_testResult != null && !_isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _resultColor.withOpacity(0.1),
                border: Border.all(color: _resultColor),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _testResult!,
                style: TextStyle(
                  color: _resultColor,
                  fontFamily: 'monospace',
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Configuration instructions
          ExpansionTile(
            title: const Text('Configuration Help'),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'To configure for your backend device:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('1. Find your backend device IP address:'),
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Windows: ipconfig\nmacOS/Linux: ifconfig',
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    const Text('2. Update lib/core/config/api_config.dart:'),
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Replace YOUR_BACKEND_IP with actual IP\nExample: http://192.168.1.100:8081',
                        style: TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                    const Text('3. Ensure backend runs on 0.0.0.0:8081'),
                    const Text('4. Configure firewall to allow port 8081'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
