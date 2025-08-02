import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/snackbar_helper.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/booking/widgets/route_map.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/providers/ride_booking_provider.dart';
import 'package:thirikkale_rider/core/services/ride_status_service.dart';

enum RideState {
  pending, // Ride request submitted, looking for driver
  accepted, // Driver accepted, on the way to pickup
  driverArrived, // Driver has arrived at pickup location
  inProgress, // Ride is in progress
  completed, // Ride completed
  cancelled, // Ride cancelled
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
  bool isLoading = true;
  String? errorMessage;

  // Driver info
  String? driverName;
  String? driverPhone;
  String? vehicleDetails;
  double? driverRating;
  String? estimatedArrival;

  // Legacy variables for old UI components
  double sliderValue = 0.5;
  bool isSliderActive = false;
  int searchProgress = 0;
  final List<Map<String, dynamic>> currentRiders = [
    {
      'name': 'Sarah Kumar',
      'rating': 4.8,
      'profileImage': 'assets/images/default_profile.png',
      'pickupLocation': 'Colombo Fort',
      'dropLocation': 'Bambalapitiya',
    },
    {
      'name': 'John Silva',
      'rating': 4.6,
      'profileImage': 'assets/images/default_profile.png',
      'pickupLocation': 'Pettah',
      'dropLocation': 'Mount Lavinia',
    },
  ];

  final Map<String, dynamic> driverInfo = {
    'name': 'Pradeep Fernando',
    'rating': 4.9,
    'vehicleNumber': 'CAB-1234',
    'vehicleModel': 'Toyota Axio',
    'profileImage': 'assets/images/default_profile.png',
    'phoneNumber': '+94 77 123 4567',
    'eta': '5 min',
  };

  final int actualPrice = 275;
  final int savings = 45;

  @override
  void initState() {
    super.initState();
    _startRideStatusPolling();
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    RideStatusService.stopRideStatusPolling();
    super.dispose();
  }

  void _startRideStatusPolling() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final rideBookingProvider = Provider.of<RideBookingProvider>(
        context,
        listen: false,
      );

      // Get current token or refresh if needed
      String? token = await authProvider.getCurrentToken();

      // Check whether the token is expired
      token ??= await authProvider.refreshAccessToken();

      final rideId = rideBookingProvider.rideId;

      if (rideId.isEmpty) {
        setState(() {
          errorMessage =
              'Unable to track ride: Missing authentication or ride ID';
          isLoading = false;
        });
        return;
      }

      print('🎯 Starting ride tracking for ride ID: $rideId');
      print('🔑 Token length: ${token?.length}');

      _statusSubscription = RideStatusService.startRideStatusPolling(
        rideId: rideId,
        token: token!,
        interval: const Duration(seconds: 5),
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
          setState(() {
            errorMessage = 'Failed to get ride updates: $error';
            isLoading = false;
          });

          // If it's an auth error, try to refresh token and retry
          if (error.toString().contains('Authentication failed')) {
            _handleAuthError();
          }
        },
      );
    } catch (e) {
      setState(() {
        errorMessage = 'Error starting ride tracking: $e';
        isLoading = false;
      });
    }
  }

  void _updateRideState(Map<String, dynamic> rideData) {
    final status = rideData['status'] as String?;

    switch (status) {
      case 'PENDING':
        currentState = RideState.pending;
        break;
      case 'ACCEPTED':
        currentState = RideState.accepted;
        _updateDriverInfo(rideData);
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
        currentState = RideState.cancelled;
        break;
      default:
        currentState = RideState.pending;
    }

    print('📊 Ride state updated to: $currentState');
  }

  void _updateDriverInfo(Map<String, dynamic> rideData) {
    driverName = rideData['driverName'] as String?;
    driverPhone = rideData['driverPhone'] as String?;
    vehicleDetails = rideData['vehicleDetails'] as String?;
    // You can add driver rating and ETA calculation here
  }

  void _handleAuthError() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final newToken = await authProvider.refreshAccessToken();

      if (newToken != null) {
        // Retry with new token
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
        _startRideStatusPolling();
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

  void _acceptSharedRide() {
    setState(() {
      currentState = RideState.accepted;
      sliderValue = 0.5; // Reset to center
      isSliderActive = false;
    });
  }

  void _startRideFlow() {
    // Start a new search for rides
    setState(() {
      currentState = RideState.pending;
      isLoading = true;
      errorMessage = null;
    });

    // Simulate searching for a new ride
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        searchProgress = (searchProgress + 2).clamp(0, 100);
      });

      if (searchProgress >= 100) {
        timer.cancel();
        // You can add logic here to either find a new ride or show no rides available
      }
    });
  }

  void _autoAcceptRide() {
    // Animate slider to accept position
    setState(() {
      sliderValue = 1.0;
    });
    // Small delay to show the animation then accept
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _acceptSharedRide();
      }
    });
  }

  void _rejectSharedRide() {
    setState(() {
      currentState = RideState.pending;
      searchProgress = 0;
      sliderValue = 0.5; // Reset to center
      isSliderActive = false;
    });
    // Start finding another ride
    _startRideFlow();
  }

  void _onSliderChanged(double value) {
    setState(() {
      sliderValue = value;
      if (value >= 0.9) {
        // Accept ride when slider is almost at the end
        _acceptSharedRide();
      } else if (value <= 0.1) {
        // Reject ride when slider is moved to the start
        _rejectSharedRide();
      }

      // Mark slider as active once it's moved significantly from center (0.5)
      if ((value - 0.5).abs() > 0.2) {
        isSliderActive = true;
      }
    });
  }

  void _createNewSharedRide() {
    setState(() {
      currentState = RideState.accepted;
    });
  }

  void _completeRide() {
    setState(() {
      currentState = RideState.completed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppbarName(title: _getAppBarTitle(), showBackButton: true),
      body: Stack(
        children: [
          // Map background
          SizedBox.expand(
            child: RouteMap(
              pickupAddress: widget.pickupAddress,
              destinationAddress: widget.destinationAddress,
              pickupLat: widget.pickupLat,
              pickupLng: widget.pickupLng,
              destLat: widget.destLat,
              destLng: widget.destLng,
              bottomPadding: MediaQuery.of(context).size.height * 0.4,
              showBackButton: false,
            ),
          ),

          // Bottom content based on current state
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
    if (isLoading) {
      return _buildLoadingContent();
    } else if (errorMessage != null) {
      return _buildErrorContent();
    }

    switch (currentState) {
      case RideState.pending:
        return _buildPendingContent();
      case RideState.accepted:
        return _buildDriverOnWayContent();
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
              _startRideStatusPolling();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingContent() {
    return SafeArea(
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress indicator
            const SizedBox(height: 20),
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),

            // Status text
            const Center(
              child: Text(
                'Finding a driver for you...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'This usually takes less than 3 minutes',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 30),

            // Trip details
            _buildTripDetailsCard(),

            const Spacer(),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showCancelConfirmation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel Ride'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverOnWayContent() {
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
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Searching animation
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

              // Progress bar
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

              // Trip details
              _buildTripDetailsCard(),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildSharedRideDetailsContent() {
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Header
                Row(
                  children: [
                    Icon(Icons.group, color: AppColors.primaryBlue, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      'Shared Ride Found!',
                      style: AppTextStyles.heading2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Driver info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(driverInfo['profileImage']),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driverInfo['name'],
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  size: 16,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${driverInfo['rating']}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${driverInfo['vehicleModel']} • ${driverInfo['vehicleNumber']}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Current Riders (${currentRiders.length})',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                // Current riders list
                ...currentRiders.map(
                  (rider) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(rider['profileImage']),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    rider['name'],
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.star,
                                    size: 14,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${rider['rating']}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                              Text(
                                '${rider['pickupLocation']} → ${rider['dropLocation']}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Auto-accept countdown
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'This ride will be auto-accepted in 15 seconds',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Slider to accept/reject
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Slide to Accept or Reject',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          // Background track
                          Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.error.withValues(alpha: 0.3),
                                  AppColors.lightGrey,
                                  AppColors.success.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),
                          // Labels
                          Positioned.fill(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.close,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Reject',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 20),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Accept',
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.success,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.check,
                                        color: AppColors.success,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 60,
                              activeTrackColor: Colors.transparent,
                              inactiveTrackColor: Colors.transparent,
                              thumbShape: CustomSliderThumb(),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 0,
                              ),
                              trackShape: const RoundedRectSliderTrackShape(),
                            ),
                            child: Slider(
                              value: sliderValue,
                              min: 0.0,
                              max: 1.0,
                              onChanged: _onSliderChanged,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        sliderValue <= 0.1
                            ? 'Finding another ride...'
                            : sliderValue >= 0.9
                            ? 'Ride accepted!'
                            : sliderValue > 0.7
                            ? 'Slide right to accept...'
                            : sliderValue < 0.3
                            ? 'Slide left to reject...'
                            : 'Slide to make your choice',
                        style: AppTextStyles.bodySmall.copyWith(
                          color:
                              sliderValue <= 0.1
                                  ? AppColors.error
                                  : sliderValue >= 0.9
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoSharedRideContent() {
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
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Icon(Icons.group_off, size: 64, color: AppColors.textSecondary),

              const SizedBox(height: 16),

              Text(
                'No Shared Rides Available',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Would you like to create a new shared ride? Other riders can join your trip.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.lightGrey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _createNewSharedRide,
                      style: AppButtonStyles.primaryButton,
                      child: const Text('Create Shared Ride'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropOffContent() {
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
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Success icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 40,
                  color: AppColors.success,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                'Trip Completed!',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                'Thank you for choosing Thirikkale',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Price breakdown
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Summary',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated Price',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          'LKR ${widget.estimatedPrice}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                    if (savings > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Savings',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            '- LKR $savings',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Final Amount',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'LKR $actualPrice',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Driver rating
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Column(
                  children: [
                    Text(
                      'Rate your driver',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => Icon(
                          Icons.star_border,
                          color: AppColors.warning,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.lightGrey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Download Receipt',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to home screen
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home', // Navigate to home route
                          (route) => false, // Remove all previous routes
                        );
                      },
                      style: AppButtonStyles.primaryButton,
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTripDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trip Details',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.circle, color: AppColors.success, size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.pickupAddress,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.error, size: 12),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.destinationAddress,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
          if (widget.rideType != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  widget.rideType?.toLowerCase() == 'shared'
                      ? Icons.group
                      : Icons.person,
                  color: AppColors.primaryBlue,
                  size: 12,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.rideType} Ride • Estimated: LKR ${widget.estimatedPrice}',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Ride?'),
            content: const Text(
              'Are you sure you want to cancel this ride? You may be charged a cancellation fee.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Keep Ride'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _cancelRide();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Cancel Ride'),
              ),
            ],
          ),
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

      print("Cancel token: $token");

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
        SnackbarHelper.showErrorSnackBar(
          context,
          "'Failed to cancel ride: $e'",
        );
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
              onPressed: () {
                // Add call functionality
              },
              icon: const Icon(Icons.phone, color: Colors.green),
            ),
        ],
      ),
    );
  }
}

class CustomSliderThumb extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(56, 56);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Draw outer circle (white background)
    final outerCirclePaint =
        Paint()
          ..color = AppColors.white
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 28, outerCirclePaint);

    // Draw border
    final borderPaint =
        Paint()
          ..color = AppColors.lightGrey
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawCircle(center, 28, borderPaint);

    // Draw inner circle with gradient based on position
    final innerColor =
        value < 0.2
            ? AppColors.error
            : value > 0.8
            ? AppColors.success
            : AppColors.primaryBlue;

    final innerCirclePaint =
        Paint()
          ..color = innerColor
          ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 20, innerCirclePaint);

    // Draw arrow icon
    final iconData =
        value < 0.2
            ? Icons.close
            : value > 0.8
            ? Icons.check
            : Icons.drag_handle;

    final textSpan = TextSpan(
      text: String.fromCharCode(iconData.codePoint),
      style: TextStyle(
        fontSize: 20,
        fontFamily: iconData.fontFamily,
        color: AppColors.white,
        fontWeight: FontWeight.w600,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }
}
