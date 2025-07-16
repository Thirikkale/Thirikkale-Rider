import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/features/home/widgets/destination_search_bar.dart';
import 'package:thirikkale_rider/features/home/widgets/explore_option_card.dart';
import 'package:thirikkale_rider/features/home/widgets/ride_option_card.dart';
import 'package:thirikkale_rider/features/home/widgets/ride_type_tabs.dart';
import 'package:thirikkale_rider/widgets/common/section_header.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';
import 'package:thirikkale_rider/features/services/screens/services_screen.dart';
import 'package:thirikkale_rider/features/booking/screens/plan_your_ride_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Explore Options Data
  static const List<Map<String, String>> exploreOptions = [
    {
      'image': 'assets/images/option_cards/shared_ride.png',
      'title': 'Shared Rides',
      'subtitle': 'Split fares, reduce traffic congestion',
      'detailTitle': 'Shared Rides',
      'description': 'Join other riders going your way and split the cost. Shared rides are an eco-friendly and budget-friendly way to travel while meeting new people.',
      'buttonText': 'Choose Shared',
    },
    {
      'image': 'assets/images/option_cards/women_only.png',
      'title': 'Women Only',
      'subtitle': 'Ride comfortably',
      'detailTitle': 'Women Only',
      'description': 'Travel with peace of mind in our women-only rides. Safe, comfortable, and secure transportation designed specifically for women.',
      'buttonText': 'Choose Women Only',
    },
  ];

  // Beat the Traffic Data
  static const List<Map<String, String>> beatTrafficOptions = [
    {
      'image': 'assets/images/option_cards/tuk_ride.png',
      'title': 'Zip Through Traffic',
      'subtitle': 'Your quickest way to get around the city',
      'detailTitle': 'Ride in an Tuk',
      'description': 'With Thirikkale Tuk, a driver will pick you up at your doorstep and take you, in a tuk, wherever you want to go in your city. Estimated prices are displayed up front.',
      'buttonText': 'Choose Tuk',
    },
    {
      'image': 'assets/images/option_cards/rush_ride.png',
      'title': 'Rush Hour Hero',
      'subtitle': 'Your fastest route through city traffic',
      'detailTitle': 'Rush Hour Hero',
      'description': 'Beat the rush hour traffic with our special rush hour service. Get priority routes and faster pickup times when you need it most.',
      'buttonText': 'Choose Rush',
    },
  ];

  // Helper method to navigate to PlanYourRideScreen with parameters
  void _navigateToPlanYourRide(BuildContext context, String rideType, {String? schedule}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlanYourRideScreen(
          initialRideType: rideType,
          initialSchedule: schedule ?? 'Now',
        ),
      ),
    );
  }

  // Helper method to build explore option cards
  List<Widget> _buildExploreCards(BuildContext context, List<Map<String, String>> options) {
    final cards = <Widget>[];
    
    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      
      cards.add(
        ExploreOptionCard(
          image: option['image']!,
          title: option['title']!,
          subtitle: option['subtitle']!,
          onTap: () {
            // Map option titles to ride types
            String rideType = 'Solo'; // default
            if (option['title']!.contains('Shared')) {
              rideType = 'Shared';
            } else if (option['title']!.contains('Women')) {
              rideType = 'Women Only';
            } else if (option['title']!.contains('Rush')) {
              rideType = 'Rush';
            } else if (option['title']!.contains('Tuk')) {
              rideType = 'Tuk';
            }
            
            _navigateToPlanYourRide(context, rideType);
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
    return Scaffold(
      bottomNavigationBar: BottomNavbar(currentIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            const RideTypeTabs(),

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
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.pageHorizontalPadding,
                          ),
                          scrollDirection: Axis.horizontal,
                          children: [
                            RideOptionCard(
                              icon: 'assets/icons/vehicles/tuk.png',
                              title: 'Tuk',
                              isPromo: true,
                              onTap: () => _navigateToPlanYourRide(context, 'Tuk'),
                            ),
                            const SizedBox(width: 16),
                            RideOptionCard(
                              icon: 'assets/icons/vehicles/scheduledRide.png',
                              title: 'Scheduled',
                              onTap: () => _navigateToPlanYourRide(context, 'Solo', schedule: 'Scheduled'),
                            ),
                            const SizedBox(width: 16),
                            RideOptionCard(
                              icon: 'assets/icons/vehicles/ride.png',
                              title: 'Ride',
                              onTap: () => _navigateToPlanYourRide(context, 'Solo'),
                            ),
                            const SizedBox(width: 16),
                            RideOptionCard(
                              icon: 'assets/icons/vehicles/rush.png',
                              title: 'Rush',
                              onTap: () => _navigateToPlanYourRide(context, 'Rush'),
                            ),
                          ],
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
                          children: _buildExploreCards(context, exploreOptions),
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
                          children: [
                            ExploreOptionCard(
                              image: 'assets/images/option_cards/tuk_ride.png',
                              title: 'Zip Through Traffic',
                              subtitle:
                                  'Your quickest way to get around the city',
                              onTap: () => _navigateToPlanYourRide(context, 'Tuk'),
                            ),
                            const SizedBox(width: 16.0),
                            ExploreOptionCard(
                              image: 'assets/images/option_cards/rush_ride.png',
                              title: 'Rush Hour Hero',
                              subtitle:
                                  'Your fastest route through city traffic',
                              onTap: () => _navigateToPlanYourRide(context, 'Rush'),
                            ),
                          ],
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
    );
  }
}
