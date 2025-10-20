import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/ride_tracking_provider.dart';
import 'package:thirikkale_rider/core/services/web_socket_service.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/core/utils/dialog_helper.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/booking/widgets/route_map.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/providers/ride_booking_provider.dart';
import 'package:thirikkale_rider/core/services/ride_status_service.dart';
import 'package:url_launcher/url_launcher.dart'; // ✅ Add this for phone calls

enum RideState {
  pending,
  accepted,
  driverArrived,
  inProgress,
  completed,
  cancelled,
}

class RideTrackingScreen extends StatefulWidget {
  final String pickupAddress;
  final String destinationAddress;
  final double? pickupLat;
  final double? pickupLng;
  final double? destLat;
  final double? destLng;
  final DateTime scheduledDateTime;
  final String? rideType;
  final int estimatedPrice;

  const RideTrackingScreen({
    super.key,
    required this.pickupAddress,
    required this.destinationAddress,
    this.pickupLat,
    this.pickupLng,
    this.destLat,
    this.destLng,
    required this.scheduledDateTime,
    this.rideType,
    required this.estimatedPrice,
  });

  @override
  State<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends State<RideTrackingScreen> {
  RideState currentState = RideState.pending;
  Map<String, dynamic>? currentRideData;
  StreamSubscription<Map<String, dynamic>>? _statusSubscription;
  StreamSubscription<Map<String, dynamic>>? _rideUpdatesSubscription;
  StreamSubscription<Map<String, dynamic>>? _rideAcceptedSubscription;

  bool isLoading = true;
  String? errorMessage;

  // Driver info
  String? driverName;
  String? driverPhone;
  String? vehicleDetails;
  double? driverRating;
  String? estimatedArrival;

  double? _currentPickupLat;
  double? _currentPickupLng;
  double? _currentDestLat;
  double? _currentDestLng;

  int searchProgress = 0;
  Timer? _searchProgressTimer;

  final WebSocketService _webSocketService = WebSocketService();

  @override
  void initState() {
    super.initState();
    _startRideMonitoring();
    _subscribeToRideAcceptance();
    _startSearchAnimation(); // ✅ Add search animation
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _rideUpdatesSubscription?.cancel();
    _rideAcceptedSubscription?.cancel();
    _searchProgressTimer?.cancel(); // ✅ Cancel timer
    super.dispose();
  }

  // ✅ Add search animation for pending state
  void _startSearchAnimation() {
    _searchProgressTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (currentState == RideState.pending && mounted) {
        setState(() {
          searchProgress = (searchProgress + 1) % 101;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startRideMonitoring() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final rideBookingProvider = Provider.of<RideBookingProvider>(
        context,
        listen: false,
      );

      String? token = await authProvider.getCurrentToken();
      token ??= await authProvider.refreshAccessToken();

      final rideId = rideBookingProvider.rideId;

      if (rideId.isEmpty) {
        setState(() {
          errorMessage = 'Unable to track ride: Missing ride ID';
          isLoading = false;
        });
        return;
      }

      print('🎯 Starting ride monitoring for ride ID: $rideId');

      _subscribeToRideAcceptance();
      _subscribeToRideUpdates(rideId);
      _startPollingFallback(rideId, token!);
    } catch (e) {
      setState(() {
        errorMessage = 'Error starting ride tracking: $e';
        isLoading = false;
      });
    }
  }

  void _subscribeToRideAcceptance() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final riderId = authProvider.userId;

    if (riderId != null) {
      if (!_webSocketService.isConnected) {
        _webSocketService.connectionStream.listen((isConnected) {
          if (isConnected) {
            _performRideAcceptanceSubscription(riderId);
          }
        });
      } else {
        _performRideAcceptanceSubscription(riderId);
      }
    }
  }

  void _performRideAcceptanceSubscription(String riderId) {
    _webSocketService.subscribeToRideAcceptance(riderId);

    _rideAcceptedSubscription = _webSocketService.rideAcceptedStream.listen(
      (data) {
        print('✅ Ride accepted notification received');
        _handleRideAccepted(data);
      },
      onError: (error) {
        print('❌ Error in ride accepted stream: $error');
      },
    );
  }

  void _handleRideAccepted(Map<String, dynamic> data) {
    if (!mounted) return;

    print('📨📨📨 FLUTTER: Ride accepted event received');
    print('📨 Data: $data');
    print('📨 Keys in data: ${data.keys.toList()}');

    // Extract ALL fields from the message
    setState(() {
      currentState = RideState.accepted;
      isLoading = false;

      driverName = data['driverName']?.toString() ?? 'Driver';
      driverPhone = data['driverPhone']?.toString();

      if (data['driverRating'] != null) {
        driverRating = (data['driverRating'] as num).toDouble();
      }

      String? vehicleModel = data['vehicleModel']?.toString();
      String? plateNumber = data['vehiclePlateNumber']?.toString();

      if (vehicleModel != null && plateNumber != null) {
        vehicleDetails = '$vehicleModel • $plateNumber';
      } else {
        vehicleDetails = 'Vehicle details pending';
      }

      estimatedArrival = 'Arriving in 5-10 mins';

      print('✅ Driver details extracted:');
      print('   Name: $driverName');
      print('   Phone: $driverPhone');
      print('   Vehicle: $vehicleDetails');
      print('   Rating: $driverRating');
    });

    if (driverName != null && driverName != 'Driver' && driverName != 'null') {
      SnackbarHelper.showSuccessSnackBar(
        context,
        'Driver $driverName accepted your ride!',
      );
    }
  }

  void _startPollingFallback(String rideId, String token) {
    _statusSubscription = RideStatusService.startRideStatusPolling(
      rideId: rideId,
      token: token,
      interval: const Duration(seconds: 10),
    ).listen(
      (rideData) {
        setState(() {
          currentRideData = rideData;
          isLoading = false;
          errorMessage = null;
          _updateRideState(rideData);
        });
      },
      onError: (error) {
        if (error.toString().contains('Authentication failed')) {
          _handleAuthError();
        } else {
          setState(() {
            errorMessage = 'Failed to get ride updates: $error';
            isLoading = false;
          });
        }
      },
    );
  }

  void _subscribeToRideUpdates(String rideId) {
    if (!_webSocketService.isConnected) {
      print('⚠️ WebSocket not connected. Waiting for connection...');
      _webSocketService.connectionStream.listen((isConnected) {
        if (isConnected && mounted) {
          _performRideUpdatesSubscription(rideId);
        }
      });
    } else {
      _performRideUpdatesSubscription(rideId);
    }
  }

  void _performRideUpdatesSubscription(String rideId) {
    final updateStream = _webSocketService.subscribeToRideUpdates(rideId);

    if (updateStream == null) {
      print('⚠️ Could not subscribe to ride updates');
      return;
    }

    _rideUpdatesSubscription = updateStream.listen(
      (updateData) {
        print('📬 Received real-time ride update: $updateData');

        if (mounted) {
          setState(() {
            currentRideData = updateData;
            isLoading = false;
            errorMessage = null;
            _updateRideState(updateData);
          });
        }
      },
      onError: (error) {
        print('❌ Error in ride updates stream: $error');
      },
    );

    print('✅ Subscribed to ride updates via WebSocket');
  }

  void _updateRideState(Map<String, dynamic> rideData) {
    final status = rideData['status'] as String?;

    _currentPickupLat = (rideData['pickupLatitude'] as num?)?.toDouble();
    _currentPickupLng = (rideData['pickupLongitude'] as num?)?.toDouble();
    _currentDestLat = (rideData['dropoffLatitude'] as num?)?.toDouble();
    _currentDestLng = (rideData['dropoffLongitude'] as num?)?.toDouble();

    switch (status) {
      case 'PENDING':
        currentState = RideState.pending;
        break;
      case 'ACCEPTED':
        currentState = RideState.accepted;
        _updateDriverInfo(rideData);
        _subscribeToLocationUpdates(rideData['id'] as String);
        break;
      case 'DRIVER_ARRIVED':
        currentState = RideState.driverArrived;
        _updateDriverInfo(rideData);
        break;
      case 'IN_PROGRESS':
        currentState = RideState.inProgress;
        _updateDriverInfo(rideData);
        break;
      case 'COMPLETED':
        currentState = RideState.completed;
        _updateDriverInfo(rideData);
        break;
      case 'CANCELLED':
      case 'CANCELLED_BY_RIDER':
      case 'CANCELLED_BY_DRIVER':
      case 'CANCELLED_BY_SYSTEM':
        currentState = RideState.cancelled;
        break;
      default:
        currentState = RideState.pending;
    }

    print('📊 Ride state updated to: $currentState');
  }

  void _subscribeToLocationUpdates(String rideId) {
    final rideTrackingProvider = Provider.of<RideTrackingProvider>(
      context,
      listen: false,
    );

    rideTrackingProvider.startTracking(rideId);
    print('📍 Started tracking driver location for ride: $rideId');
  }

  void _updateDriverInfo(Map<String, dynamic> rideData) {
    if (!mounted) return;

    print('📋 Updating driver info from ride data');
    print('📋 Ride data keys: ${rideData.keys.toList()}');

    setState(() {
      // ✅ Extract driver details from ride response
      driverName = rideData['driverName']?.toString();
      driverPhone = rideData['driverPhone']?.toString();

      if (rideData['driverRating'] != null) {
        driverRating = (rideData['driverRating'] as num).toDouble();
      }

      // ✅ Extract vehicle details
      String? vehicleModel = rideData['vehicleModel']?.toString();
      String? plateNumber = rideData['vehiclePlateNumber']?.toString();

      if (vehicleModel != null && plateNumber != null) {
        vehicleDetails = '$vehicleModel • $plateNumber';
      } else {
        vehicleDetails = 'Vehicle details pending';
      }

      estimatedArrival = 'Arriving soon';

      print('📋 Driver info updated from API:');
      print('   Name: $driverName');
      print('   Phone: $driverPhone');
      print('   Vehicle: $vehicleDetails');
      print('   Rating: $driverRating');
    });

    // ✅ Only show snackbar if we have actual driver info
    if (driverName != null &&
        driverName!.isNotEmpty &&
        driverName != 'null' &&
        driverName != 'Driver') {
      SnackbarHelper.showSuccessSnackBar(
        context,
        'Driver $driverName is on the way!',
      );
    }
  }

  void _handleAuthError() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final newToken = await authProvider.refreshAccessToken();

      if (newToken != null) {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
        _startRideMonitoring();
      } else {
        setState(() {
          errorMessage = 'Session expired. Please login again.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Authentication error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppbarName(title: _getAppBarTitle(), showBackButton: true),
      body: Stack(
        children: [
          SizedBox.expand(
            child: RouteMap(
              pickupAddress: widget.pickupAddress,
              destinationAddress: widget.destinationAddress,
              pickupLat: _currentPickupLat ?? widget.pickupLat,
              pickupLng: _currentPickupLng ?? widget.pickupLng,
              destLat: _currentDestLat ?? widget.destLat,
              destLng: _currentDestLng ?? widget.destLng,
              bottomPadding: MediaQuery.of(context).size.height * 0.4,
              showBackButton: false,
              showDriverLocation:
                  currentState == RideState.accepted ||
                  currentState == RideState.driverArrived ||
                  currentState == RideState.inProgress,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomContent(),
          ),
        ],
      ),
    );
  }

  String _getAppBarTitle() {
    switch (currentState) {
      case RideState.pending:
        return 'Finding Driver...';
      case RideState.accepted:
        return 'Driver On The Way';
      case RideState.driverArrived:
        return 'Driver Has Arrived';
      case RideState.inProgress:
        return 'In Progress';
      case RideState.completed:
        return 'Ride Completed';
      case RideState.cancelled:
        return 'Ride Cancelled';
    }
  }

  Widget _buildBottomContent() {
    print('🎨 Building bottom sheet for state: $currentState');
    print('🎨 Driver name: $driverName, Vehicle: $vehicleDetails');

    if (isLoading) {
      return _buildLoadingContent();
    } else if (errorMessage != null) {
      return _buildErrorContent();
    }

    switch (currentState) {
      case RideState.pending:
        return _buildPendingContent();

      case RideState.accepted:
        // ✅ IMPROVED: Check for actual driver data, not just 'Driver' placeholder
        final hasDriverInfo =
            driverName != null &&
            driverName != 'null' &&
            driverName!.isNotEmpty &&
            driverName != 'Driver' &&
            driverName != 'N/A';

        if (hasDriverInfo) {
          print('✅ Showing driver card with info: $driverName');
          return _buildDriverOnWayContent();
        } else {
          print('⏳ Still waiting for driver details, showing pending');
          return _buildPendingContent(); // ⏳ Still waiting for driver details
        }

      case RideState.driverArrived:
        return _buildDriverArrivedContent();
      case RideState.inProgress:
        return _buildInProgressContent();
      case RideState.completed:
        return _buildCompletedContent();
      case RideState.cancelled:
        return _buildCancelledContent();
    }
  }

  Widget _buildLoadingContent() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Loading ride information...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Unknown error occurred',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isLoading = true;
                errorMessage = null;
              });
              _startRideMonitoring();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingContent() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search,
                  size: 40,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Finding the best ride for you...',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a few moments',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Searching...',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '$searchProgress%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: searchProgress / 100,
                    backgroundColor: AppColors.lightGrey,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTripDetailsCard(),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => _showCancelConfirmation(context),
                  child: const Text(
                    'Cancel Ride',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ NEW: Complete Driver On Way Content with all details
  Widget _buildDriverOnWayContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Status Header
                Text(
                  'Driver On The Way',
                  style: AppTextStyles.heading2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your driver will arrive at the pickup location soon',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 24),

                // ✅ DRIVER CARD
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      // Driver Photo
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: Text(
                          driverName != null && driverName!.isNotEmpty
                              ? driverName!.substring(0, 1).toUpperCase()
                              : 'D',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Driver Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverName ?? 'Driver',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (driverRating != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    driverRating!.toStringAsFixed(1),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            if (vehicleDetails != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                vehicleDetails!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Action Buttons
                      Column(
                        children: [
                          // Call Button
                          IconButton(
                            icon: const Icon(Icons.phone, color: Colors.green),
                            onPressed: () => _callDriver(),
                          ),
                          // Message Button
                          IconButton(
                            icon: const Icon(Icons.message, color: Colors.blue),
                            onPressed: () {
                              SnackbarHelper.showInfoSnackBar(
                                context,
                                'Messaging feature coming soon',
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ETA Info
                if (estimatedArrival != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          estimatedArrival!,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.orange[800],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Trip Details
                _buildTripDetailsCard(),

                const SizedBox(height: 24),

                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _showCancelConfirmation(context),
                    child: const Text(
                      'Cancel Ride',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Add call driver functionality
  Future<void> _callDriver() async {
    if (driverPhone == null) {
      SnackbarHelper.showErrorSnackBar(
        context,
        'Driver phone number not available',
      );
      return;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: driverPhone);

    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (mounted) {
          SnackbarHelper.showErrorSnackBar(
            context,
            'Could not launch phone dialer',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showErrorSnackBar(context, 'Error making call: $e');
      }
    }
  }

  Widget _buildDriverArrivedContent() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_on, color: Colors.green, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Driver has arrived!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your driver is waiting at the pickup location',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          if (currentRideData != null) _buildDriverInfoCard(),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentState = RideState.inProgress;
                });
              },
              child: const Text('Start Ride'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressContent() {
    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Icon(Icons.directions_car, color: Colors.blue, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Ride in progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enjoy your journey!',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          if (currentRideData != null) _buildDriverInfoCard(),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  currentState = RideState.completed;
                });
              },
              child: const Text('Complete Ride'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedContent() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Ride completed!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Thank you for choosing Thirikkale',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Text(
                  'Trip Summary',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount:'),
                    Text(
                      'LKR ${widget.estimatedPrice}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRatingDialog(),
                  child: const Text('Rate Driver'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelledContent() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const Icon(Icons.cancel, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Ride cancelled',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your ride has been cancelled',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Home'),
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Rate Your Driver'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('How was your experience?'),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) => IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Thank you for rating ${index + 1} stars!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.star_border),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Skip'),
              ),
            ],
          ),
    );
  }

  Widget _buildTripDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Details',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.pickupAddress,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.destinationAddress,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Cancel Ride?',
      content:
          'Are you sure you want to cancel this ride? You may be charged a cancellation fee.',
      confirmText: 'Cancel Ride',
      cancelText: 'Keep Ride',
      confirmButtonColor: AppColors.error,
      titleIcon: Icons.warning,
      titleIconColor: AppColors.warning,
      onConfirm: () {
        _cancelRide();
      },
    );
  }

  void _cancelRide() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final rideBookingProvider = Provider.of<RideBookingProvider>(
        context,
        listen: false,
      );
      final token = await authProvider.getCurrentToken();
      final rideId = rideBookingProvider.rideId;

      if (token != null && rideId.isNotEmpty) {
        await RideStatusService.cancelRide(
          rideId: rideId,
          token: token,
          reason: 'User requested cancellation',
        );

        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        final refreshedToken = await authProvider.refreshAccessToken();
        if (refreshedToken != null && rideId.isNotEmpty) {
          await RideStatusService.cancelRide(
            rideId: rideId,
            token: refreshedToken,
            reason: "User requested cancellation",
          );

          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            SnackbarHelper.showErrorSnackBar(
              context,
              "Session expired. Please login again.",
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.showErrorSnackBar(context, "Failed to cancel ride: $e");
      }
    }
  }

  Widget _buildDriverInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue,
            child: Text(
              driverName?.substring(0, 1).toUpperCase() ?? 'D',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driverName ?? 'Driver',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (vehicleDetails != null)
                  Text(
                    vehicleDetails!,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
              ],
            ),
          ),
          if (driverPhone != null)
            IconButton(
              onPressed: _callDriver,
              icon: const Icon(Icons.phone, color: Colors.green),
            ),
        ],
      ),
    );
  }
}
