import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/features/home/widgets/destination_search_bar.dart';
import 'package:thirikkale_rider/features/home/widgets/explore_option_card.dart';
import 'package:thirikkale_rider/features/home/widgets/ride_option_card.dart';
import 'package:thirikkale_rider/features/home/widgets/ride_type_tabs.dart';
import 'package:thirikkale_rider/features/home/widgets/section_header.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                          children: const [
                            RideOptionCard(
                              icon: 'assets/icons/vehicles/tuk.png',
                              title: 'Tuk',
                              isPromo: true,
                            ),
                            SizedBox(width: 16),
                            RideOptionCard(
                              icon: 'assets/icons/vehicles/scheduledRide.png',
                              title: 'Scheduled',
                            ),
                            SizedBox(width: 16),
                            RideOptionCard(
                              icon: 'assets/icons/vehicles/ride.png',
                              title: 'Ride',
                            ),
                            SizedBox(width: 16),
                            RideOptionCard(
                              icon: 'assets/icons/vehicles/rush.png',
                              title: 'Rush',
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
                          children: const [
                            ExploreOptionCard(
                              image:
                                  'assets/images/option_cards/shared_ride.png',
                              title: 'Shared Rides',
                              subtitle:
                                  'Split fares, reduce traffic congestion',
                            ),
                            SizedBox(width: 16),
                            ExploreOptionCard(
                              image:
                                  'assets/images/option_cards/women_only.png',
                              title: 'Women Only',
                              subtitle: 'Ride comfortably',
                            ),
                          ],
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
                          children: const [
                            ExploreOptionCard(
                              image:
                                  'assets/images/option_cards/tuk_ride.png',
                              title: 'Zip Through Traffic',
                              subtitle:
                                  'Your quickest way to get around the city',
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
