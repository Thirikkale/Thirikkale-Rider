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

  final StreamController<Map<String, dynamic>> _rideAcceptedController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get rideAcceptedStream =>
      _rideAcceptedController.stream;

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
          // Optional: Implement retry logic here
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

  Stream<Map<String, dynamic>>? subscribeToRideLocation(String rideId) {
    if (!_isConnected || _stompClient == null) {
      print('❌ Cannot subscribe to ride location: WebSocket not connected.');
      return null;
    }
    final streamController = StreamController<Map<String, dynamic>>.broadcast();
    final destination = '/topic/ride/$rideId/location';

    print('🔔 Subscribing to $destination');
    final unsubscribeFn = _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            streamController.add(json.decode(frame.body!));
          } catch (e) {
            print('❌ Error parsing location update: $e');
          }
        }
      },
    );

    // When the stream listener is cancelled, automatically unsubscribe from the STOMP topic
    streamController.onCancel = () {
      print('🔕 Unsubscribing from $destination');
      unsubscribeFn();
    };

    return streamController.stream;
  }

  Stream<Map<String, dynamic>>? subscribeToRideUpdates(String riderId) {
    if (!_isConnected || _stompClient == null) {
      print('❌ Cannot subscribe to ride updates: WebSocket not connected.');
      return null;
    }
    final streamController = StreamController<Map<String, dynamic>>.broadcast();
    final destination = '/user/$riderId/queue/ride-updates';

    print('🔔 Subscribing to $destination');
    final unsubscribeFn = _stompClient!.subscribe(
      destination: destination,
      callback: (StompFrame frame) {
        if (frame.body != null) {
          try {
            streamController.add(json.decode(frame.body!));
          } catch (e) {
            print('❌ Error parsing ride update: $e');
          }
        }
      },
    );

    streamController.onCancel = () {
      print('🔕 Unsubscribing from $destination');
      unsubscribeFn();
    };

    return streamController.stream;
  }

  void subscribeToRideAcceptance(String riderId) {
    if (_stompClient == null || !_isConnected) {
      print('⚠️ Cannot subscribe to ride acceptance - not connected');
      return;
    }

    _stompClient!.subscribe(
      destination: '/user/$riderId/queue/ride-accepted',
      callback: (StompFrame frame) {
        print('📨📨📨 FLUTTER: Ride accepted event received');
        print('📨📨📨 FLUTTER: Frame body: ${frame.body}');

        if (frame.body != null) {
          try {
            final data = jsonDecode(frame.body!);
            print('📨📨📨 FLUTTER: Parsed ride accepted data: $data');
            _rideAcceptedController.add(data);
          } catch (e) {
            print('❌❌❌ FLUTTER: Error parsing ride accepted event: $e');
          }
        }
      },
    );

    print('🔔 Subscribed to ride acceptance events for rider: $riderId');
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
