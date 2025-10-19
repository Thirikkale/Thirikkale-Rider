import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/services/scheduled_ride_service.dart';
import 'package:thirikkale_rider/core/services/driver_service.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/dialog_helper.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/booking/widgets/route_map.dart';
import 'package:geocoding/geocoding.dart';

class ScheduledRideDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> ride;
  final Map<String, dynamic>? raw;
  const ScheduledRideDetailsScreen({super.key, required this.ride, this.raw});

  @override
  State<ScheduledRideDetailsScreen> createState() => _ScheduledRideDetailsScreenState();
}

class _ScheduledRideDetailsScreenState extends State<ScheduledRideDetailsScreen> {
  bool _cancelling = false;
  String? _error;
  double? _pickupLat, _pickupLng, _destLat, _destLng;
  Map<String, dynamic>? _driverDetails;
  bool _loadingDriver = false;

  @override
  void initState() {
    super.initState();
    // Log the ride data received by this screen
    print('📱 ScheduledRideDetailsScreen initialized with ride data:');
    print('📝 Ride: ${widget.ride}');
    if (widget.raw != null) {
      print('📝 Raw: ${widget.raw}');
    }
    
    // Log driver ID specifically
    final driverId = widget.ride['driverId'];
    print('🚕 Driver ID in ride: $driverId (${driverId.runtimeType})');
    
    _geocodeAddresses();
    _fetchDriverDetails();
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    final isShared = (ride['status']?.toString().toUpperCase() == 'SHARED') || (ride['isSharedRide'] == true);
    final participants = _extractParticipants(widget.raw ?? ride);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: const CustomAppbarName(title: 'Scheduled Ride', showBackButton: true),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.pageHorizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildChildren(ride, isShared, participants),
        ),
      ),
    );
  }



  List<Map<String, String>> _extractParticipants(Map<String, dynamic> raw) {
    final list = <Map<String, String>>[];
    final members = raw['participants'] ?? raw['members'] ?? raw['riders'];
    if (members is List) {
      for (final m in members) {
        if (m is Map) {
          list.add({
            'name': (m['name'] ?? m['fullName'] ?? m['username'] ?? '').toString(),
            'phone': (m['phone'] ?? m['mobile'] ?? m['contact'] ?? '').toString(),
          });
        }
      }
    }
    return list;
  }

  Future<void> _confirmCancel() async {
    DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Cancel Scheduled Ride',
      content: 'Are you sure you want to cancel this scheduled ride?',
      confirmText: 'YES',
      cancelText: 'NO',
      titleIcon: Icons.schedule_outlined,
      titleIconColor: AppColors.warning,
      confirmButtonColor: AppColors.error,
      onConfirm: _cancelRide,
    );
  }

  Future<void> _cancelRide() async {
    setState(() {
      _cancelling = true;
      _error = null;
    });
    try {
      final id = widget.ride['tripId'] ?? widget.ride['id']?.toString();
      final auth = context.read<AuthProvider?>();
      final token = await auth?.getCurrentToken();
      if (id == null || id.toString().isEmpty) {
        throw Exception('Invalid ride id');
      }
      await ScheduledRideService.cancelById(id.toString(), token: token);
      if (!mounted) return;
      Navigator.pop(context, true); // indicate cancelled
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _cancelling = false;
        });
      }
    }
  }

  Future<void> _geocodeAddresses() async {
    final pickupAddress = widget.ride['pickupLocation'] ?? widget.ride['pickupAddress'] ?? '';
    final destAddress = widget.ride['destination'] ?? widget.ride['dropoffAddress'] ?? '';
    try {
      final pickupLocations = await locationFromAddress(pickupAddress);
      if (pickupLocations.isNotEmpty) {
        setState(() {
          _pickupLat = pickupLocations.first.latitude;
          _pickupLng = pickupLocations.first.longitude;
        });
      }
      final destLocations = await locationFromAddress(destAddress);
      if (destLocations.isNotEmpty) {
        setState(() {
          _destLat = destLocations.first.latitude;
          _destLng = destLocations.first.longitude;
        });
      }
    } catch (e) {
      print('Geocoding error: $e');
    }
  }

  Future<void> _fetchDriverDetails() async {
    final rawRide = widget.raw ?? {};
    final status = (widget.ride['status'] ?? '').toString().toUpperCase();
    
    
    // Look for the driverId field - this is the ID of the driver assigned to the ride
    String? driverId;
    
    // Check ride object
    driverId = widget.ride['driverId']?.toString();
    
    // Check raw data if available
    if ((driverId == null || driverId == "null" || driverId.isEmpty) && rawRide.isNotEmpty) {
      driverId = rawRide['driverId']?.toString();
    }
    
    // If no driver ID is found, there's no driver assigned yet
    if (driverId == null || driverId == "null" || driverId.isEmpty) {
      print('❌ No driver ID found for this ride');
      return;
    }
    
    // From the logs, we found that sometimes driverId is the same as riderId,
    // which is not correct (a user cannot be their own driver)
    final riderId = widget.ride['riderId']?.toString() ?? '';
    if (driverId == riderId) {
      print('⚠️ Driver ID matches Rider ID - this is likely a data error');
      // We still proceed in case this is somehow intentional
    }
    
    print('🚗 Found driver ID: $driverId - Fetching driver details');
    setState(() {
      _loadingDriver = true;
    });

    try {
      final driverService = DriverService();
      final auth = context.read<AuthProvider?>();
      final token = await auth?.getCurrentToken();
      print('📊 Requesting driver data for ID: $driverId');

      final driverData = token != null
          ? await driverService.getDriverCardAuthenticated(driverId, token)
          : await driverService.getDriverCard(driverId);
      
      print('📊 Driver data received: $driverData');

      if (mounted) {
        setState(() {
          _driverDetails = driverData;
          _loadingDriver = false;
        });
      }
    } catch (e) {
      print('Failed to fetch driver details: $e');
      if (mounted) {
        setState(() {
          _loadingDriver = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CANCELLED':
        return AppColors.error;
      case 'DISPATCHED':
        return AppColors.primaryBlue;
      case 'CONFIRMED':
        return AppColors.primaryGreen;
      case 'PENDING':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'CANCELLED':
        return 'Cancelled';
      case 'DISPATCHED':
        return 'Dispatched';
      case 'CONFIRMED':
        return 'Confirmed';
      case 'PENDING':
        return 'Pending';
      default:
        return status;
    }
  }

  Widget _buildLocationInfo({
    required IconData icon,
    required String title,
    required String location,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                location,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildChildren(Map<String, dynamic> ride, bool isShared, List<Map<String, String>> participants) {
    final rideStatus = ride['status']?.toString().toUpperCase();
    final list = <Widget>[];
    
    // Header section like the card
    list.add(Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(ride['vehicleIcon'] ?? 'assets/icons/vehicles/tuk.png', width: 32, height: 32),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Scheduled Ride',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (rideStatus != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getStatusColor(rideStatus),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getStatusText(rideStatus),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${ride['scheduledDate'] ?? ''} at ${ride['scheduledTime'] ?? ''}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
    
    list.add(const SizedBox(height: 16));
    
    // Driver details section (only show when driver is available)
    if (_driverDetails != null) {
      list.add(Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Driver profile picture or avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
              backgroundImage: _driverDetails!['profilePicUrl'] != null
                  ? NetworkImage(_driverDetails!['profilePicUrl'])
                  : null,
              child: _driverDetails!['profilePicUrl'] == null
                  ? Icon(Icons.person, color: AppColors.primaryBlue, size: 24)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    _driverDetails!['name'] ?? 'Driver',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (_driverDetails!['contactNumber'] != null)
                    Text(
                      _driverDetails!['contactNumber'],
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryBlue,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Assigned',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ));
      list.add(const SizedBox(height: 16));
    } else if (_loadingDriver) {
      // Show loading indicator while fetching driver details
      list.add(Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.lightGrey,
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Driver',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    'Loading driver details...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ));
      list.add(const SizedBox(height: 16));
    }
    
    // Map section
    list.add(Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.lightGrey,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: RouteMap(
          pickupAddress: ride['pickupLocation'] ?? ride['pickupAddress'] ?? '',
          destinationAddress: ride['destination'] ?? ride['dropoffAddress'] ?? '',
          pickupLat: _pickupLat ?? ride['pickupLat']?.toDouble(),
          pickupLng: _pickupLng ?? ride['pickupLng']?.toDouble(),
          destLat: _destLat ?? ride['destLat']?.toDouble(),
          destLng: _destLng ?? ride['destLng']?.toDouble(),
          showBackButton: false,
        ),
      ),
    ));
    
    list.add(const SizedBox(height: 16));
    
    // Location section like the card
    list.add(_buildLocationInfo(
      icon: Icons.location_on_outlined,
      title: 'Pickup',
      location: ride['pickupLocation'] ?? ride['pickupAddress'] ?? '',
      color: AppColors.primaryGreen,
    ));
    list.add(const Padding(
      padding: EdgeInsets.only(left: 12),
      child: SizedBox(
        height: 16,
        child: VerticalDivider(
          width: 1,
          thickness: 2,
          color: AppColors.subtleGrey,
        ),
      ),
    ));
    list.add(_buildLocationInfo(
      icon: Icons.location_on,
      title: 'Destination',
      location: ride['destination'] ?? ride['dropoffAddress'] ?? '',
      color: AppColors.primaryBlue,
    ));
    
    list.add(const SizedBox(height: 16));
    
    // Fare section
    if (ride['estimatedFare'] != null) {
      list.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estimated Fare',
                style: AppTextStyles.bodySmall,
              ),
              Text(
                ride['estimatedFare'],
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // No additional cancelled message needed - status badge shows the state
        ],
      ));
      list.add(const SizedBox(height: 16));
    }
    if (isShared) {
      list.add(Text('Participants', style: AppTextStyles.heading3));
      list.add(const SizedBox(height: 8));
      if (participants.isEmpty) {
        list.add(Text('No participants listed', style: AppTextStyles.bodyMedium));
      }
      // } else {
      //   // Show rider details in card-like rows when driver is available
      //   final driverAvailable = ride['driverId'] != null && ride['driverId'].toString().isNotEmpty;

      //   if (driverAvailable) {
      //     for (var participant in participants) {
      //       list.add(Container(
      //         margin: const EdgeInsets.only(bottom: 8),
      //         padding: const EdgeInsets.all(12),
      //         decoration: BoxDecoration(
      //           color: AppColors.surfaceLight,
      //           borderRadius: BorderRadius.circular(8),
      //           border: Border.all(color: AppColors.lightGrey),
      //         ),
      //         child: Row(
      //           children: [
      //             CircleAvatar(
      //               backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
      //               child: Icon(Icons.person, color: AppColors.primaryBlue),
      //             ),
      //             const SizedBox(width: 12),
      //             Expanded(
      //               child: Column(
      //                 crossAxisAlignment: CrossAxisAlignment.start,
      //                 children: [
      //                   Text(
      //                     participant['name'] ?? 'Rider',
      //                     style: AppTextStyles.bodyMedium.copyWith(
      //                       fontWeight: FontWeight.w500,
      //                     ),
      //                   ),
      //                   if (participant['phone'] != null && participant['phone'].toString().isNotEmpty)
      //                     Text(
      //                       participant['phone'].toString(),
      //                       style: AppTextStyles.bodySmall.copyWith(
      //                         color: AppColors.textSecondary,
      //                       ),
      //                     ),
      //                 ],
      //               ),
      //             ),
      //             Container(
      //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      //               decoration: BoxDecoration(
      //                 color: AppColors.primaryGreen.withValues(alpha: 0.1),
      //                 borderRadius: BorderRadius.circular(4),
      //               ),
      //               child: Text(
      //                 'Joined',
      //                 style: AppTextStyles.bodySmall.copyWith(
      //                   color: AppColors.primaryGreen,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ));
      //     }
      //   } else {
      //     // Fallback to list tiles for other statuses
      //     list.addAll(participants.map((p) => ListTile(
      //           leading: const CircleAvatar(child: Icon(Icons.person)),
      //           title: Text(p['name'] ?? 'Rider'),
      //           subtitle: Text(p['phone'] ?? ''),
      //         )));
      //   }
      // }
      list.add(const SizedBox(height: 16));
    }
    if (_error != null) {
      list.add(Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)));
    }
    list.add(const Spacer());
    
    // cancel button
    final status = ride['status']?.toString().toUpperCase();
    if (status == 'SCHEDULED' || status == 'GROUPING') {
      list.add(SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.cancel),
          style: AppButtonStyles.primaryButton.copyWith(
            backgroundColor: WidgetStateProperty.all(AppColors.error),
          ),
          onPressed: _cancelling ? null : _confirmCancel,
          label: Text(_cancelling ? 'Cancelling...' : 'Cancel Ride'),
        ),
      ));
    }
    // No message or button shown for CANCELLED or other statuses
    return list;
  }
}
