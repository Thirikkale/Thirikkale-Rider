import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/features/home/widgets/ride_option_card.dart';
import 'package:thirikkale_rider/widgets/common/section_header.dart';
import 'package:thirikkale_rider/features/services/widgets/ride_service_card.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(title: 'Services', showBackButton: true),
      bottomNavigationBar: BottomNavbar(currentIndex: 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pageHorizontalPadding,
              vertical: AppDimensions.pageVerticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Choose Your Ride'),

                const SizedBox(height: AppDimensions.widgetSpacing),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppDimensions.widgetSpacing,
                  mainAxisSpacing: AppDimensions.widgetSpacing,
                  childAspectRatio: 0.8,
                  children: const [
                    RideServiceCard(
                      image: 'assets/images/service_cards/service_solo.png',
                      title: 'Thirikkale Solo',
                      subtitle: 'Solo ride, Direct one route',
                    ),
                    RideServiceCard(
                      image: 'assets/images/service_cards/service_shared.png',
                      title: 'Thirikkale Shared',
                      subtitle: 'Split fare, meet people',
                    ),
                    RideServiceCard(
                      image:
                          'assets/images/service_cards/service_scheduled.png',
                      title: 'Scheduled',
                      subtitle: 'Plan ahead',
                    ),
                    RideServiceCard(
                      image:
                          'assets/images/service_cards/service_womenOnly.png',
                      title: 'Women Only',
                      subtitle: 'Safe & Comfortable',
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sectionSpacing),

                const SectionHeader(title: 'Vehicle Options'),

                const SizedBox(height: AppDimensions.widgetSpacing),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppDimensions.widgetSpacing,
                  mainAxisSpacing: AppDimensions.widgetSpacing,
                  childAspectRatio: 0.85,
                  children: const [
                    RideOptionCard(
                      icon: 'assets/icons/vehicles/tuk.png',
                      title: 'Tuk',
                      isPromo: true,
                    ),
                    RideOptionCard(
                      icon: 'assets/icons/vehicles/ride.png',
                      title: 'Ride',
                    ),
                    RideOptionCard(
                      icon: 'assets/icons/vehicles/rush.png',
                      title: 'Rush',
                    ),
                    RideOptionCard(
                      icon: 'assets/icons/vehicles/primeRide.png',
                      title: 'Prime',
                    ),
                    RideOptionCard(
                      icon: 'assets/icons/vehicles/squad.png',
                      title: 'Squad',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
