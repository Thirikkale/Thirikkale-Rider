import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/services/scheduled_ride_service.dart';
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

  @override
  void initState() {
    super.initState();
    _geocodeAddresses();
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
      list.addAll(participants.map((p) => ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(p['name'] ?? 'Rider'),
            subtitle: Text(p['phone'] ?? ''),
          )));
      list.add(const SizedBox(height: 16));
    }
    if (_error != null) {
      list.add(Text(_error!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)));
    }
    list.add(const Spacer());
    
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
