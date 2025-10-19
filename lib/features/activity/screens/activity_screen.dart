import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/dialog_helper.dart';
import 'package:thirikkale_rider/features/activity/widgets/ride_history_card.dart';
import 'package:thirikkale_rider/features/activity/widgets/scheduled_ride_card.dart';
import 'package:thirikkale_rider/features/activity/widgets/ongoing_ride_card.dart';
import 'package:thirikkale_rider/features/activity/widgets/completed_ride_card.dart';
import 'package:thirikkale_rider/features/activity/widgets/cancelled_ride_card.dart';
import 'package:thirikkale_rider/features/activity/widgets/complaint_ride_card.dart';
import 'package:thirikkale_rider/features/activity/widgets/activity_tabs.dart';
import 'package:thirikkale_rider/features/activity/screens/trip_details_screen.dart';
import 'package:thirikkale_rider/features/activity/screens/scheduled_ride_details_screen.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/services/scheduled_ride_service.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class ActivityScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const ActivityScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  late int _selectedTabIndex;
  // State for scheduled rides from API
  bool _scheduledLoading = false;
  String? _scheduledError;
  List<Map<String, dynamic>> _scheduledApiActivities = [];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex;
    // Preload scheduled rides if landing on Scheduled tab
    if (_selectedTabIndex == 1) {
      _loadScheduledRides();
    }
  }

  // Sample data for different activity types
  final List<Map<String, dynamic>> _ongoingActivities = [
    {
      'tripId': 'ID555551315',
      'destination': 'Wickramaarachchi Opticians & Hearing Care Galle',
      'pickupLocation': 'Viraj Road, Katana, Gampaha',
      'date': 'Today, 3:45 PM',
      'price': 'LKR 212.00',
      'estimatedFare': 'LKR 144.01',
      'actualFare': 'LKR 144.01',
      'vehicleIcon': 'assets/icons/vehicles/tuk.png',
      'vehicleType': 'Tuk',
      'status': 'En route',
      'driverName': 'Mahesh',
      'driverRating': 4.8,
      'vehicleNumber': 'BCD0579',
      'duration': '5 minutes 34 seconds',
      'distance': '2.5 km',
      'rating': 4.8,
    },
  ];

  final List<Map<String, dynamic>> _completedActivities = [
    {
      'tripId': 'ID555551314',
      'destination': 'Wickramaarachchi Opticians & Hearing Care Galle',
      'pickupLocation': 'Viraj Road, Katana, Gampaha',
      'date': 'Jun 6, 5:00 PM',
      'price': 'LKR 212.00',
      'estimatedFare': 'LKR 144.01',
      'actualFare': 'LKR 144.01',
      'vehicleIcon': 'assets/icons/vehicles/tuk.png',
      'vehicleType': 'Tuk',
      'status': 'Completed',
      'mapImage': 'assets/images/map_placeholder.png',
      'driverName': 'Rohan',
      'driverRating': 4.9,
      'vehicleNumber': 'ABC1234',
      'duration': '15 minutes 22 seconds',
      'distance': '8.2 km',
      'rating': 5.0,
    },
    {
      'tripId': 'ID555551313',
      'destination': 'Unity Plaza',
      'pickupLocation': 'Home Location',
      'date': 'Jun 5, 5:00 PM',
      'price': 'LKR 212.00',
      'estimatedFare': 'LKR 180.00',
      'actualFare': 'LKR 212.00',
      'vehicleIcon': 'assets/icons/vehicles/tuk.png',
      'vehicleType': 'Tuk',
      'status': 'Completed',
      'driverName': 'Sunil',
      'driverRating': 4.7,
      'vehicleNumber': 'DEF5678',
      'duration': '12 minutes 45 seconds',
      'distance': '6.8 km',
      'rating': 4.0,
    },
    {
      'tripId': 'ID555551312',
      'destination': '35 Reid Ave',
      'pickupLocation': 'Office Location',
      'date': 'May 23, 4:09 PM',
      'price': 'LKR 255.00',
      'estimatedFare': 'LKR 220.00',
      'actualFare': 'LKR 255.00',
      'vehicleIcon': 'assets/icons/vehicles/tuk.png',
      'vehicleType': 'Tuk',
      'status': 'Completed',
      'driverName': 'Kamal',
      'driverRating': 4.6,
      'vehicleNumber': 'GHI9012',
      'duration': '18 minutes 30 seconds',
      'distance': '12.1 km',
      'rating': 4.5,
    },
    {
      'tripId': 'ID555551311',
      'destination': 'Sudewila Road',
      'pickupLocation': 'Shopping Mall',
      'date': 'May 20, 3:10 PM',
      'price': 'LKR 181.00',
      'estimatedFare': 'LKR 160.00',
      'actualFare': 'LKR 181.00',
      'vehicleIcon': 'assets/icons/vehicles/tuk.png',
      'vehicleType': 'Tuk',
      'status': 'Completed',
      'driverName': 'Nimal',
      'driverRating': 4.8,
      'vehicleNumber': 'JKL3456',
      'duration': '10 minutes 15 seconds',
      'distance': '4.5 km',
      'rating': 4.2,
    },
    {
      'tripId': 'ID555551310',
      'destination': 'Univeristy of Colombo School of Computing (UCSC)',
      'pickupLocation': 'Boarding House',
      'date': 'May 12, 9:10 PM',
      'price': 'LKR 232.00',
      'estimatedFare': 'LKR 200.00',
      'actualFare': 'LKR 232.00',
      'vehicleIcon': 'assets/icons/vehicles/tuk.png',
      'vehicleType': 'Tuk',
      'status': 'Completed',
      'driverName': 'Pradeep',
      'driverRating': 4.9,
      'vehicleNumber': 'MNO7890',
      'duration': '25 minutes 40 seconds',
      'distance': '15.3 km',
      'rating': 4.8,
    },
    {
      'tripId': 'ID555551309',
      'destination': 'Athurugiriya Clock Tower',
      'pickupLocation': 'Train Station',
      'date': 'April 21, 2:18 PM',
      'price': 'LKR 378.00',
      'estimatedFare': 'LKR 350.00',
      'actualFare': 'LKR 378.00',
      'vehicleIcon': 'assets/icons/vehicles/ride.png',
      'vehicleType': 'Ride',
      'status': 'Completed',
      'driverName': 'Chaminda',
      'driverRating': 4.7,
      'vehicleNumber': 'PQR1234',
      'duration': '35 minutes 12 seconds',
      'distance': '22.7 km',
      'rating': 4.6,
    },
    {
      'tripId': 'ID555551308',
      'destination': 'Maharagama Clock Tower',
      'pickupLocation': 'Friend\'s House',
      'date': 'April 16, 2:40 PM',
      'price': 'LKR 439.10',
      'estimatedFare': 'LKR 400.00',
      'actualFare': 'LKR 439.10',
      'vehicleIcon': 'assets/icons/vehicles/tuk.png',
      'vehicleType': 'Tuk',
      'status': 'Completed',
      'driverName': 'Lasantha',
      'driverRating': 4.5,
      'vehicleNumber': 'STU5678',
      'duration': '28 minutes 55 seconds',
      'distance': '18.9 km',
      'rating': 4.3,
    },
  ];

  // Scheduled rides data
  final List<Map<String, dynamic>> _scheduledActivities = [
    {
      'tripId': 'ID555551401',
      'destination': 'Colombo Fort Railway Station',
      'pickupLocation': 'Home',
      'scheduledDate': 'Tomorrow',
      'scheduledTime': '7:30 AM',
      'estimatedFare': 'LKR 350.00',
      'vehicleIcon': 'assets/icons/vehicles/tuk.png',
      'vehicleType': 'Tuk',
      'status': 'Scheduled',
    },
    {
      'tripId': 'ID555551402',
      'destination': 'Bandaranaike International Airport',
      'pickupLocation': 'Office',
      'scheduledDate': 'Oct 15',
      'scheduledTime': '5:00 PM',
      'estimatedFare': 'LKR 1,200.00',
      'vehicleIcon': 'assets/icons/vehicles/ride.png',
      'vehicleType': 'Ride',
      'status': 'Scheduled',
    },
    {
      'tripId': 'ID555551403',
      'destination': 'Majestic City',
      'pickupLocation': 'Home',
      'scheduledDate': 'Oct 20',
      'scheduledTime': '10:30 AM',
      'estimatedFare': 'LKR 280.00',
      'vehicleIcon': 'assets/icons/vehicles/tuk.png',
      'vehicleType': 'Tuk',
      'status': 'Scheduled',
    },
  ];

  final List<Map<String, dynamic>> _complaintActivities = [
    {
      'tripId': 'ID555551307',
      'destination': 'Galle Fort',
      'pickupLocation': 'Hotel Lobby',
      'date': 'Jun 1, 2:30 PM',
      'price': 'LKR 180.00',
      'estimatedFare': 'LKR 150.00',
      'actualFare': 'LKR 180.00',
      'vehicleIcon': 'assets/icons/vehicles/tuk.png',
      'vehicleType': 'Tuk',
      'status': 'Complaint',
      'complaint': 'Driver was late and took wrong route',
      'driverName': 'Saman',
      'driverRating': 3.2,
      'vehicleNumber': 'VWX9012',
      'duration': '35 minutes 20 seconds',
      'distance': '12.5 km',
      'rating': 2.0,
    },
  ];

  final List<Map<String, dynamic>> _cancelledActivities = [
    {
      'tripId': 'ID555551306',
      'destination': 'Colombo Airport',
      'pickupLocation': 'Home',
      'date': 'May 28, 6:00 AM',
      'price': 'LKR 1,200.00',
      'estimatedFare': 'LKR 1,200.00',
      'vehicleIcon': 'assets/icons/vehicles/ride.png',
      'vehicleType': 'Ride',
      'status': 'Cancelled',
      'cancelReason': 'Flight cancelled',
      'distance': '45.2 km',
    },
    {
      'tripId': 'ID555551305',
      'destination': 'Kandy City Center',
      'pickupLocation': 'Bus Stand',
      'date': 'May 15, 10:00 AM',
      'price': 'LKR 2,500.00',
      'estimatedFare': 'LKR 2,500.00',
      'vehicleIcon': 'assets/icons/vehicles/ride.png',
      'vehicleType': 'Ride',
      'status': 'Cancelled',
      'cancelReason': 'No driver found',
      'distance': '120.5 km',
    },
  ];

  void _onTabChanged(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
    if (index == 1) {
      _loadScheduledRides();
    }
  }

  Future<void> _loadScheduledRides() async {
    final auth = context.read<AuthProvider?>();
    final riderId = auth?.userId;
    final token = await auth?.getCurrentToken();
    if (riderId == null) {
      setState(() {
        _scheduledError = 'Not logged in';
        _scheduledApiActivities = [];
      });
      return;
    }
    setState(() {
      _scheduledLoading = true;
      _scheduledError = null;
    });
    try {
      final list = await ScheduledRideService.getRidesByRider(
          riderId: riderId, token: token);
      setState(() {
        _scheduledApiActivities = list
            .map<Map<String, dynamic>>((e) => _mapScheduledRideToCard(e))
            .toList();
      });
    } catch (e) {
      setState(() {
        _scheduledError = e.toString();
        _scheduledApiActivities = [];
      });
    } finally {
      setState(() {
        _scheduledLoading = false;
      });
    }
  }

  Map<String, dynamic> _mapScheduledRideToCard(Map<String, dynamic> e) {
    String vehicleType = (e['vehicleType'] ?? '').toString();
    String icon = _vehicleIconFor(vehicleType);
    // Parse ISO time and present simple date/time strings
    String scheduledIso = (e['scheduledTime'] ?? e['scheduled_at'] ?? '')
        .toString();
    DateTime? dt;
    try {
      if (scheduledIso.isNotEmpty) dt = DateTime.parse(scheduledIso).toLocal();
    } catch (_) {}
    String scheduledDate = dt != null
        ? _formatDate(dt)
        : (e['scheduledDate']?.toString() ?? '');
    String scheduledTime = dt != null
        ? _formatTime(dt)
        : (e['scheduledTime']?.toString() ?? '');
    return {
      'tripId': e['id']?.toString() ?? '',
      'destination': e['dropoffAddress'] ?? e['dropoff_address'] ?? '',
      'pickupLocation': e['pickupAddress'] ?? e['pickup_address'] ?? '',
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'estimatedFare': _formatLkr(e['maxFare'] ?? e['estimatedFare']),
      'vehicleIcon': icon,
      'vehicleType': vehicleType,
      'status': (e['status'] ?? 'Scheduled').toString(),
    };
  }

  String _vehicleIconFor(String vehicleType) {
    switch (vehicleType.toUpperCase()) {
      case 'TUK':
        return 'assets/icons/vehicles/tuk.png';
      case 'RIDE':
      case 'PRIME_RIDE':
        return 'assets/icons/vehicles/ride.png';
      case 'RUSH':
        return 'assets/icons/vehicles/rush.png';
      case 'SQUAD':
        return 'assets/icons/vehicles/squad.png';
      default:
        return 'assets/icons/vehicles/ride.png';
    }
  }

  String _formatDate(DateTime dt) {
    // Simple: e.g., Oct 19
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
    }

  String _formatLkr(dynamic v) {
    if (v == null) return '';
    try {
      final n = (v is num) ? v : num.parse(v.toString());
      return 'LKR ${n.toStringAsFixed(2)}';
    } catch (_) {
      return v.toString();
    }
  }

  List<Map<String, dynamic>> _getCurrentActivities() {
    switch (_selectedTabIndex) {
      case 0:
        return _ongoingActivities;
      case 1:
        // Prefer API data when available
        if (_scheduledLoading) {
          return [];
        }
        if (_scheduledApiActivities.isNotEmpty) {
          return _scheduledApiActivities;
        }
        return _scheduledActivities;
      case 2:
        return _completedActivities;
      case 3:
        return _complaintActivities;
      case 4:
        return _cancelledActivities;
      default:
        return _completedActivities;
    }
  }

  String _getEmptyStateMessage() {
    switch (_selectedTabIndex) {
      case 0:
        return 'You don\'t have any ongoing trips at the moment';
      case 1:
        return 'You don\'t have any scheduled rides';
      case 2:
        return 'You don\'t have any completed trips';
      case 3:
        return 'You don\'t have any complaints';
      case 4:
        return 'You don\'t have any cancelled trips';
      default:
        return 'No activities found';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentActivities = _getCurrentActivities();
    
    return Scaffold(
      appBar: CustomAppbarName(title: 'Activity', showBackButton: true),
      bottomNavigationBar: BottomNavbar(currentIndex: 2),
      body: Column(
        children: [
          // Activity tabs
          ActivityTabs(
            onTabChanged: _onTabChanged,
            initialTabIndex: _selectedTabIndex,
          ),
          
          // Activity content
          Expanded(
            child: (_selectedTabIndex == 1 && _scheduledLoading)
                ? const Center(child: CircularProgressIndicator())
                : currentActivities.isEmpty
                    ? _buildEmptyState()
                    : _buildActivityList(currentActivities),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateMessage(),
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(List<Map<String, dynamic>> activities) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pageHorizontalPadding,
          vertical: AppDimensions.pageVerticalPadding,
        ),
        child: Column(
          children: [
            if (_selectedTabIndex == 1 && _scheduledLoading)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            if (_selectedTabIndex == 1 && _scheduledError != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _scheduledError!,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.error),
                ),
              ),
            ...activities.map((activity) {
            return Column(
              children: [
                // Choose widget based on tab/activity type
                _buildActivityCard(activity),
                const SizedBox(height: AppDimensions.widgetSpacing),
              ],
            );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityCard(Map<String, dynamic> activity) {
    // Select appropriate widget based on the selected tab
    switch (_selectedTabIndex) {
      case 0: // Ongoing tab
        return OngoingRideCard(
          destination: activity['destination'],
          pickupLocation: activity['pickupLocation'],
          estimatedFare: activity['estimatedFare'],
          vehicleIcon: activity['vehicleIcon'],
          status: activity['status'],
          driverName: activity['driverName'],
          driverRating: activity['driverRating'],
          vehicleNumber: activity['vehicleNumber'],
          onCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsScreen(
                  tripData: activity,
                ),
              ),
            );
          },
          onViewLiveLocationPressed: () {
            // Implement live location tracking
          },
        );
        
      case 1: // Scheduled tab
        final status = activity['status']?.toString().toUpperCase();
        return ScheduledRideCard(
          destination: activity['destination'],
          pickupLocation: activity['pickupLocation'],
          scheduledDate: activity['scheduledDate'],
          scheduledTime: activity['scheduledTime'],
          estimatedFare: activity['estimatedFare'],
          vehicleIcon: activity['vehicleIcon'],
          status: status,
          onCardTap: () {
            // Navigate to scheduled ride details screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScheduledRideDetailsScreen(
                  ride: activity,
                  raw: activity,
                ),
              ),
            );
          },
          onCancelPressed: (status == 'CANCELLED' || status == 'DISPATCHED') ? null : () {
            _showCancelConfirmationDialog(activity['tripId']);
          },
        );
        
      case 2: // Completed tab
        return CompletedRideCard(
          destination: activity['destination'],
          pickupLocation: activity['pickupLocation'],
          date: activity['date'],
          price: activity['actualFare'] ?? activity['price'],
          vehicleIcon: activity['vehicleIcon'],
          driverName: activity['driverName'],
          driverRating: activity['driverRating'],
          userRating: activity['rating'],
          duration: activity['duration'],
          distance: activity['distance'],
          mapImage: activity['mapImage'],
          onCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsScreen(
                  tripData: activity,
                ),
              ),
            );
          },
          onRebookPressed: () {
            // Implement rebook functionality
          },
        );
        
      case 3: // Complaint tab
        return ComplaintRideCard(
          destination: activity['destination'],
          pickupLocation: activity['pickupLocation'],
          date: activity['date'],
          price: activity['price'] ?? activity['actualFare'],
          vehicleIcon: activity['vehicleIcon'],
          complaint: activity['complaint'],
          driverName: activity['driverName'],
          driverRating: activity['driverRating'],
          userRating: activity['rating'],
          vehicleNumber: activity['vehicleNumber'],
          distance: activity['distance'],
          onCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsScreen(
                  tripData: activity,
                ),
              ),
            );
          },
          onContactSupportPressed: () {
            // Implement contact support functionality
          },
        );
        
      case 4: // Cancelled tab
        return CancelledRideCard(
          destination: activity['destination'],
          pickupLocation: activity['pickupLocation'],
          date: activity['date'],
          estimatedFare: activity['estimatedFare'] ?? activity['price'],
          vehicleIcon: activity['vehicleIcon'],
          cancelReason: activity['cancelReason'] ?? 'Cancelled by user',
          distance: activity['distance'],
          onCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsScreen(
                  tripData: activity,
                ),
              ),
            );
          },
          onRebookPressed: () {
            // Implement rebook functionality
          },
        );
        
      default: // Fallback to basic ride history card
        return RideHistoryCard(
          mapImage: activity['mapImage'],
          destination: activity['destination'],
          date: activity['date'] ?? activity['scheduledDate'],
          price: activity['price'] ?? activity['estimatedFare'],
          vehicleIcon: activity['vehicleIcon'],
          onCardTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripDetailsScreen(
                  tripData: activity,
                ),
              ),
            );
          },
          onRebookPressed: () {
            // Empty for future implementation
          },
        );
    }
  }
  
  void _showCancelConfirmationDialog(String tripId) {
    DialogHelper.showConfirmationDialog(
      context: context,
      title: 'Cancel Scheduled Ride',
      content: 'Are you sure you want to cancel this scheduled ride?',
      confirmText: 'YES',
      cancelText: 'NO',
      titleIcon: Icons.schedule_outlined,
      titleIconColor: AppColors.warning,
      confirmButtonColor: AppColors.error,
      onConfirm: () async {
        try {
          final auth = context.read<AuthProvider?>();
          final token = await auth?.getCurrentToken();
          await ScheduledRideService.cancelById(tripId, token: token);
          // Refresh the list
          await _loadScheduledRides();
        } catch (e) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cancellation failed: ${e.toString()}')),
          );
        }
      },
    );
  }
}
