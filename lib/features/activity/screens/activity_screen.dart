import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/activity/widgets/ride_history_card.dart';
import 'package:thirikkale_rider/features/activity/widgets/activity_tabs.dart';
import 'package:thirikkale_rider/features/activity/screens/trip_details_screen.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _selectedTabIndex = 0;

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
  }

  List<Map<String, dynamic>> _getCurrentActivities() {
    switch (_selectedTabIndex) {
      case 0:
        return _ongoingActivities;
      case 1:
        return _completedActivities;
      case 2:
        return _complaintActivities;
      case 3:
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
        return 'You don\'t have any completed trips';
      case 2:
        return 'You don\'t have any complaints';
      case 3:
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
            child: currentActivities.isEmpty
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
          children: activities.map((activity) {
            return Column(
              children: [
                RideHistoryCard(
                  mapImage: activity['mapImage'],
                  destination: activity['destination'],
                  date: activity['date'],
                  price: activity['price'],
                  vehicleIcon: activity['vehicleIcon'],
                  onCardTap: () {
                    // Navigate to trip details screen
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
                ),
                const SizedBox(height: AppDimensions.widgetSpacing),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
