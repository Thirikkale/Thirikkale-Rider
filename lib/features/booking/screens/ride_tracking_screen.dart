import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/booking/widgets/route_map.dart';

enum RideState {
  findingRider,
  sharedRideDetails,
  noSharedRideAvailable,
  driverOnWay,
  dropOff,
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
  RideState currentState = RideState.findingRider;
  int searchProgress = 0;
  bool isSharedRide = false;
  double sliderValue = 0.5; // Start in center
  bool isSliderActive = false;

  // Mock data
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
    isSharedRide = widget.rideType?.toLowerCase() == 'shared';
    _startRideFlow();
  }

  void _startRideFlow() {
    // Simulate finding rider process
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          searchProgress = 33;
        });
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          searchProgress = 66;
        });
      }
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          searchProgress = 100;
          currentState = isSharedRide ? RideState.sharedRideDetails : RideState.driverOnWay;
        });
      }
    });

    // Auto-accept shared ride after 15 seconds if not manually acted upon
    if (isSharedRide) {
      Future.delayed(const Duration(seconds: 21), () {
        if (mounted && currentState == RideState.sharedRideDetails && (sliderValue - 0.5).abs() < 0.2) {
          // Auto-slide to accept if user hasn't moved slider significantly from center
          _autoAcceptRide();
        }
      });
    }
  }

  void _acceptSharedRide() {
    setState(() {
      currentState = RideState.driverOnWay;
      sliderValue = 0.5; // Reset to center
      isSliderActive = false;
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
      currentState = RideState.findingRider;
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
      currentState = RideState.driverOnWay;
    });
  }

  void _completeRide() {
    setState(() {
      currentState = RideState.dropOff;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppbarName(
        title: _getAppBarTitle(),
        showBackButton: true,
      ),
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
      case RideState.findingRider:
        return 'Finding Rider';
      case RideState.sharedRideDetails:
        return 'Shared Ride Details';
      case RideState.noSharedRideAvailable:
        return 'Create Shared Ride';
      case RideState.driverOnWay:
        return 'Driver on the Way';
      case RideState.dropOff:
        return 'Trip Completed';
    }
  }

  Widget _buildBottomContent() {
    switch (currentState) {
      case RideState.findingRider:
        return _buildFindingRiderContent();
      case RideState.sharedRideDetails:
        return _buildSharedRideDetailsContent();
      case RideState.noSharedRideAvailable:
        return _buildNoSharedRideContent();
      case RideState.driverOnWay:
        return _buildDriverOnWayContent();
      case RideState.dropOff:
        return _buildDropOffContent();
    }
  }

  Widget _buildFindingRiderContent() {
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
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
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
                    Icon(
                      Icons.group,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
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
                ...currentRiders.map((rider) => Container(
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
                )),

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
                      Icon(
                        Icons.timer,
                        color: AppColors.warning,
                        size: 20,
                      ),
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
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
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
                          color: sliderValue <= 0.1
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

              Icon(
                Icons.group_off,
                size: 64,
                color: AppColors.textSecondary,
              ),

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

              // Driver info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(driverInfo['profileImage']),
                        ),
                        const SizedBox(width: 16),
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
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${driverInfo['rating']} • ${driverInfo['vehicleModel']}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                              Text(
                                driverInfo['vehicleNumber'],
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'ETA ${driverInfo['eta']}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.phone,
                                color: AppColors.primaryBlue,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Status message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.directions_car,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Your driver is on the way to pick you up',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Message',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _completeRide,
                      style: AppButtonStyles.primaryButton,
                      child: const Text('Simulate Drop-off'),
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
                      children: List.generate(5, (index) => 
                        Icon(
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
              Icon(
                Icons.circle,
                color: AppColors.success,
                size: 12,
              ),
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
              Icon(
                Icons.location_on,
                color: AppColors.error,
                size: 12,
              ),
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
                  widget.rideType?.toLowerCase() == 'shared' ? Icons.group : Icons.person,
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
    final outerCirclePaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 28, outerCirclePaint);

    // Draw border
    final borderPaint = Paint()
      ..color = AppColors.lightGrey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    canvas.drawCircle(center, 28, borderPaint);

    // Draw inner circle with gradient based on position
    final innerColor = value < 0.2
        ? AppColors.error
        : value > 0.8
            ? AppColors.success
            : AppColors.primaryBlue;

    final innerCirclePaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center, 20, innerCirclePaint);

    // Draw arrow icon
    final iconData = value < 0.2
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
