import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:thirikkale_rider/core/config/api_config.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  StompClient? _stompClient;
  bool _isConnected = false;
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _isConnected;

  void connect(String accessToken) {
    if (_isConnected) {
      print('🔗 WebSocket is already connected.');
      return;
    }

    print('🔗 Connecting WebSocket...');
    _stompClient = StompClient(
      config: StompConfig(
        url: '${ApiConfig.rideServiceSocketUrl}/ws/ride-tracking',
        onConnect: (StompFrame frame) {
          print('✅ WebSocket connected successfully');
          _isConnected = true;
          _connectionController.add(true);
        },
        onWebSocketError: (dynamic error) {
          print('❌ WebSocket error: $error');
          _isConnected = false;
          _connectionController.add(false);
        },
        onStompError: (StompFrame frame) {
          print('❌ STOMP error: ${frame.body}');
          _isConnected = false;
          _connectionController.add(false);
        },
        onDisconnect: (StompFrame frame) {
          print('🔌 WebSocket disconnected');
          _isConnected = false;
          _connectionController.add(false);
        },
        webSocketConnectHeaders: {'Authorization': 'Bearer $accessToken'},
        useSockJS: true,
        connectionTimeout: const Duration(seconds: 20),
      ),
    );

    _stompClient!.activate();
  }

  /// Subscribe to ride status updates for a specific ride
  /// This receives "RIDE_ACCEPTED", "DRIVER_ARRIVED", etc. updates
  Stream<Map<String, dynamic>>? subscribeToRideUpdates(String rideId) {
    if (!_isConnected || _stompClient == null) {
      print('⚠️ Cannot subscribe to ride updates, WebSocket is not connected.');
      return null;
    }

    final streamController = StreamController<Map<String, dynamic>>.broadcast();
    final destination = '/topic/ride/$rideId/updates';

    print('🔔 Subscribing to ride updates: $destination');

    final unsubscribe = _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final data = json.decode(frame.body!) as Map<String, dynamic>;
            print('📬 Received ride update: $data');
            streamController.add(data);
          } catch (e) {
            print('❌ Error parsing ride update: $e');
          }
        }
      },
    );

    streamController.onCancel = () {
      print('🔕 Unsubscribing from $destination');
      unsubscribe();
    };

    return streamController.stream;
  }

  /// Subscribes to the location topic for a specific ride.
  /// Returns a Stream that will emit location updates as Maps.
  Stream<Map<String, dynamic>>? subscribeToRideLocation(String rideId) {
    if (!_isConnected || _stompClient == null) {
      print('⚠️ Cannot subscribe, WebSocket is not connected.');
      return null;
    }

    final streamController = StreamController<Map<String, dynamic>>.broadcast();
    final destination = '/topic/ride/$rideId/location';

    print('🔔 Subscribing to $destination');

    // The STOMP client returns a function that can be used to unsubscribe
    final unsubscribe = _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            final data = json.decode(frame.body!) as Map<String, dynamic>;
            streamController.add(data);
          } catch (e) {
            print('❌ Error parsing location update: $e');
          }
        }
      },
    );

    // When the stream is cancelled, automatically unsubscribe from the topic
    streamController.onCancel = () {
      print('🔕 Unsubscribing from $destination');
      unsubscribe();
    };

    return streamController.stream;
  }

  void disconnect() {
    if (_stompClient != null) {
      _stompClient!.deactivate();
      _stompClient = null;
    }
    _isConnected = false;
    print('🔌 WebSocket disconnected.');
  }

  void dispose() {
    _connectionController.close();
    disconnect();
  }
}
