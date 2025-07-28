import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/features/home/widgets/destination_search_bar.dart';
import 'package:thirikkale_rider/features/home/widgets/explore_option_card.dart';
import 'package:thirikkale_rider/features/home/widgets/ride_option_card.dart';
import 'package:thirikkale_rider/features/home/widgets/ride_type_tabs.dart';
import 'package:thirikkale_rider/widgets/common/section_header.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';
import 'package:thirikkale_rider/features/services/screens/services_screen.dart';
import 'package:thirikkale_rider/features/booking/screens/plan_your_ride_screen.dart';
import 'package:thirikkale_rider/features/home/screens/ride_option_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/ride_booking_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedRideTypeIndex = 0; // 0 = Solo, 1 = Shared

  // Solo ride options
  static const List<Map<String, dynamic>> soloRideOptions = [
    {
      'icon': 'assets/icons/vehicles/ride.png',
      'title': 'Ride',
      'rideType': 'Solo',
      'isPromo': false,
      'flags': {
        'isSolo': true,
        'isRideScheduled': false,
        'isWomenOnly': false
      }
    },
    {
      'icon': 'assets/icons/vehicles/scheduledRide.png',
      'title': 'Scheduled',
      'rideType': 'Solo',
      'schedule': 'Scheduled',
      'isPromo': false,
      'flags': {
        'isSolo': true,
        'isRideScheduled': true,
        'isWomenOnly': false
      }
    },
    {
      'icon': 'assets/icons/vehicles/tuk.png',
      'title': 'Tuk',
      'rideType': 'Tuk',
      'isPromo': true,
      'flags': {
        'isSolo': true,
        'isRideScheduled': false,
        'isWomenOnly': false,
      }
    },
    {
      'icon': 'assets/icons/vehicles/rush.png',
      'title': 'Rush',
      'rideType': 'Rush',
      'isPromo': false,
      'flags': {
        'isSolo': true,
        'isRideScheduled': false,
        'isWomenOnly': false,
      }
    },
    {
      'icon': 'assets/icons/vehicles/primeRide.png',
      'title': 'Prime',
      'rideType': 'Prime',
      'isPromo': false,
      'flags': {
        'isSolo': true,
        'isRideScheduled': false,
        'isWomenOnly': false,
      }
    },
  ];

  // Shared ride options
  static const List<Map<String, dynamic>> sharedRideOptions = [
    {
      'icon': 'assets/icons/vehicles/shared_car.png',
      'title': 'Shared',
      'rideType': 'Shared',
      'isPromo': false,
      'flags': {
        'isSolo': false,
        'isRideScheduled': false,
        'isWomenOnly': false
      }
    },
    {
      'icon': 'assets/icons/vehicles/scheduledRide.png',
      'title': 'Scheduled',
      'rideType': 'Shared',
      'schedule': 'Scheduled',
      'isPromo': false,
      'flags': {
        'isSolo': false,
        'isRideScheduled': true,
        'isWomenOnly': false
      }
    },
    {
      'icon': 'assets/icons/vehicles/squad.png',
      'title': 'Squad',
      'rideType': 'Squad',
      'isPromo': false,
      'flags': {
        'isSolo': false,
        'isRideScheduled': false,
        'isWomenOnly': false,
      }
    },
    {
      'icon': 'assets/icons/vehicles/ride.png',
      'title': 'Women Only',
      'rideType': 'Women Only',
      'isPromo': false,
      'flags': {
        'isSolo': false,
        'isRideScheduled': false,
        'isWomenOnly': true,
      }
    },
  ];

  // Get current ride options based on selected tab
  List<Map<String, dynamic>> get _currentRideOptions {
    return _selectedRideTypeIndex == 0 ? soloRideOptions : sharedRideOptions;
  }

  // Method to handle tab change
  void _onRideTypeChanged(int index) {
    setState(() {
      _selectedRideTypeIndex = index;
    });
  }

  // Solo Explore Options Data
  static const List<Map<String, dynamic>> soloExploreOptions = [
    {
      'image': 'assets/images/option_cards/solo_ride.png',
      'title': 'Standard Ride',
      'subtitle': 'Affordable everyday rides',
      'detailTitle': 'Standard Solo Ride',
      'description': 'Comfortable and reliable rides for your daily transportation needs. Available now or schedule for later. Perfect for short to medium distance trips.',
      'buttonText': 'Choose Standard',
      'flags': {
        'isSolo': true,
        'isRideScheduled': false,
        'isWomenOnly': false
      }
    },
    {
      'image': 'assets/images/option_cards/solo_prime.png',
      'title': 'Prime',
      'subtitle': 'Premium cars with top drivers',
      'detailTitle': 'Prime Solo Experience',
      'description': 'Premium vehicles with highly-rated professional drivers. Scheduled rides available. Perfect for business meetings, airport transfers, and special occasions.',
      'buttonText': 'Choose Prime',
      'flags': {
        'isSolo': true,
        'isRideScheduled': false,
        'isWomenOnly': false
      }
    },
  ];

  // Shared Explore Options Data
  static const List<Map<String, dynamic>> sharedExploreOptions = [
    {
      'image': 'assets/images/option_cards/shared_ride.png',
      'title': 'Shared Ride',
      'subtitle': 'Split fare with other riders',
      'detailTitle': 'Shared Ride Service',
      'description': 'Share your ride with others going in the same direction and split the cost. Scheduled rides available for regular commutes. Eco-friendly and budget-friendly option.',
      'buttonText': 'Join Shared',
      'flags': {
        'isSolo': false,
        'isRideScheduled': false,
        'isWomenOnly': false
      }
    },
    {
      'image': 'assets/images/option_cards/shared_women.png',
      'title': 'Women Only',
      'subtitle': 'Safe rides for women passengers',
      'detailTitle': 'Women Only Shared Ride',
      'description': 'Shared rides exclusively for women passengers with female or verified drivers. Scheduled options available for regular commutes. Safe and comfortable environment.',
      'buttonText': 'Choose Women Only',
      'flags': {
        'isSolo': false,
        'isRideScheduled': false,
        'isWomenOnly': true
      }
    },
  ];

  // Solo Beat the Traffic Data
  static const List<Map<String, dynamic>> soloBeatTrafficOptions = [
    {
      'image': 'assets/images/option_cards/solo_rush.png',
      'title': 'Rush',
      'subtitle': 'Fast routes during peak hours',
      'detailTitle': 'Rush Solo Service',
      'description': 'Priority rides with optimized routes during rush hours. Higher fare but guaranteed faster arrival times. Scheduled rides available for regular office commutes.',
      'buttonText': 'Choose Rush',
      'flags': {
        'isSolo': true,
        'isRideScheduled': false,
        'isWomenOnly': false
      }
    },
    {
      'image': 'assets/images/option_cards/solo_tuk.png',
      'title': 'Tuk',
      'subtitle': 'Quick and affordable three-wheeler',
      'detailTitle': 'Tuk Solo Ride',
      'description': 'Fast and economical three-wheeler rides perfect for navigating through traffic. Instant booking available. Great for short trips and quick errands.',
      'buttonText': 'Choose Tuk',
      'flags': {
        'isSolo': true,
        'isRideScheduled': false,
        'isWomenOnly': false
      }
    },
  ];

  // Shared Beat the Traffic Data
  static const List<Map<String, dynamic>> sharedBeatTrafficOptions = [
    {
      'image': 'assets/images/option_cards/shared_squad.png',
      'title': 'Squad',
      'subtitle': 'Large group sharing (4-6 people)',
      'detailTitle': 'Squad Shared Ride',
      'description': 'Larger vehicles for group travel with 4-6 passengers. Perfect for office teams, friends, or family groups. Scheduled rides available for regular group commutes.',
      'buttonText': 'Book Squad',
      'flags': {
        'isSolo': false,
        'isRideScheduled': false,
        'isWomenOnly': false
      }
    },
    {
      'image': 'assets/images/option_cards/shared_scheduled.png',
      'title': 'Scheduled',
      'subtitle': 'Pre-planned shared rides',
      'detailTitle': 'Scheduled Shared Ride',
      'description': 'Book shared rides in advance for your regular commutes. Perfect for daily office trips with cost-effective shared transportation. Plan your rides ahead of time.',
      'buttonText': 'Schedule Ride',
      'flags': {
        'isSolo': false,
        'isRideScheduled': true,
        'isWomenOnly': false
      }
    },
  ];

  // Get current explore options based on selected tab
  List<Map<String, dynamic>> get _currentExploreOptions {
    return _selectedRideTypeIndex == 0 ? soloExploreOptions : sharedExploreOptions;
  }

  // Get current beat traffic options based on selected tab
  List<Map<String, dynamic>> get _currentBeatTrafficOptions {
    return _selectedRideTypeIndex == 0 ? soloBeatTrafficOptions : sharedBeatTrafficOptions;
  }

  // Helper method to navigate to PlanYourRideScreen with parameters
  void _navigateToPlanYourRide(BuildContext context, String rideType, {String? schedule, Map<String, dynamic>? flags}) {
    // Set flags in provider before navigation
    if (flags != null) {
      final provider = Provider.of<RideBookingProvider>(context, listen: false);
      provider.setOptions(
        isSolo: flags['isSolo'] ?? true,
        isRideScheduled: flags['isRideScheduled'] ?? false,
        isWomenOnly: flags['isWomenOnly'] ?? false,
      );
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanYourRideScreen(
        ),
      ),
    );
  }

  // Helper method to navigate to RideOptionDetailScreen
  void _navigateToRideDetail(BuildContext context, Map<String, dynamic> option) {
    // Set flags in provider before navigation
    final flags = option['flags'] as Map<String, dynamic>?;
    if (flags != null) {
      final provider = Provider.of<RideBookingProvider>(context, listen: false);
      provider.setOptions(
        isSolo: flags['isSolo'] ?? true,
        isRideScheduled: flags['isRideScheduled'] ?? false,
        isWomenOnly: flags['isWomenOnly'] ?? false,
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RideOptionDetailScreen(
          image: option['image']!,
          title: option['detailTitle'] ?? option['title']!,
          subtitle: option['subtitle']!,
          description: option['description']!,
          buttonText: option['buttonText']!,
          onChooseOption: () {
            // Navigate back and then to plan your ride
            Navigator.pop(context);

            // Map option titles to ride types based on current tab
            String rideType;
            if (_selectedRideTypeIndex == 1) {
              // If on shared tab, always use 'Shared' as ride type
              rideType = 'Shared';
            } else {
              // If on solo tab, map specific ride types
              if (option['title']!.contains('Prime')) {
                rideType = 'Prime';
              } else if (option['title']!.contains('Rush')) {
                rideType = 'Rush';
              } else if (option['title']!.contains('Tuk')) {
                rideType = 'Tuk';
              } else {
                rideType = 'Solo'; // default for solo tab
              }
            }

            _navigateToPlanYourRide(context, rideType);
          },
        ),
      ),
    );
  }

  // Helper method to build explore option cards
  List<Widget> _buildExploreCards(BuildContext context, List<Map<String, dynamic>> options) {
    final cards = <Widget>[];
    
    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      
      cards.add(
        ExploreOptionCard(
          image: option['image']!,
          title: option['title']!,
          subtitle: option['subtitle']!,
          onTap: () {
            _navigateToRideDetail(context, option);
          },
        ),
      );
      
      // Add spacing between cards (except for the last card)
      if (i < options.length - 1) {
        cards.add(const SizedBox(width: 16));
      }
    }
    
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        bottomNavigationBar: BottomNavbar(currentIndex: 0),
        body: SafeArea(
          child: Column(
            children: [
              RideTypeTabs(
                initialSelectedIndex: _selectedRideTypeIndex,
                onTabChanged: _onRideTypeChanged,
              ),
      
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppDimensions.pageVerticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.pageHorizontalPadding,
                          ),
                          child: DestinationSearchBar(),
                        ),
      
                        const SizedBox(height: 24),
      
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.pageHorizontalPadding,
                          ),
                          child: SectionHeader(
                            title: "Quick Options",
                            actionText: "See all",
                            onActionTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ServicesScreen(),
                                ),
                              );
                              // Handle see all tap
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
      
                        // Quick ride options
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.pageHorizontalPadding,
                            ),
                            scrollDirection: Axis.horizontal,
                            itemCount: _currentRideOptions.length,
                            separatorBuilder: (context, index) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final option = _currentRideOptions[index];
                              return RideOptionCard(
                                icon: option['icon'],
                                title: option['title'],
                                isPromo: option['isPromo'] ?? false,
                              onTap: () => _navigateToPlanYourRide(
                                context,
                                option['rideType'],
                                schedule: option['schedule'],
                                flags: option['flags'] as Map<String, dynamic>?,
                              ),
                              );
                            },
                          ),
                        ),
      
                        const SizedBox(height: 24),
      
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.pageHorizontalPadding,
                          ),
                          child: SectionHeader(title: 'Explore Options'),
                        ),
      
                        const SizedBox(height: 16),
      
                        SizedBox(
                          height: 180,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.pageHorizontalPadding,
                            ),
                            scrollDirection: Axis.horizontal,
                            children: _buildExploreCards(context, _currentExploreOptions),
                          ),
                        ),
      
                        const SizedBox(height: 24),
      
                        const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.pageHorizontalPadding,
                          ),
                          child: SectionHeader(title: 'Beat the Traffic'),
                        ),
      
                        const SizedBox(height: 16),
      
                        SizedBox(
                          height: 180,
                          child: ListView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.pageHorizontalPadding,
                            ),
                            scrollDirection: Axis.horizontal,
                            children: _buildExploreCards(context, _currentBeatTrafficOptions),
                          ),
                        ),
                      ],
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
}
