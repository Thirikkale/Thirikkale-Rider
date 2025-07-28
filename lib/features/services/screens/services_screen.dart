import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/features/home/widgets/ride_option_card.dart';
import 'package:thirikkale_rider/widgets/common/section_header.dart';
import 'package:thirikkale_rider/features/services/widgets/ride_service_card.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/features/booking/screens/plan_your_ride_screen.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/ride_booking_provider.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  // Helper method to set provider variables and navigate to PlanYourRideScreen
  void _navigateToPlanYourRide(BuildContext context, String rideType, {String? schedule}) {
    final provider = Provider.of<RideBookingProvider>(context, listen: false);
    provider.setRideType(rideType);
    provider.isRideScheduled = (schedule == 'Scheduled');
    if (schedule == 'Scheduled') {
      provider.setScheduledDateTime(DateTime.now().add(const Duration(hours: 1)));
    } else {
      provider.setScheduledDateTime(null);
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PlanYourRideScreen(),
      ),
    );
  }

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
                  childAspectRatio: 0.9,
                  children: [
                    RideServiceCard(
                      image: 'assets/images/service_cards/service_solo.png',
                      title: 'Thirikkale Solo',
                      subtitle: 'Solo ride, Direct one route',
                      onTap: () => _navigateToPlanYourRide(context, 'Solo'),
                    ),
                    RideServiceCard(
                      image: 'assets/images/service_cards/service_shared.png',
                      title: 'Thirikkale Shared',
                      subtitle: 'Split fare, meet people',
                      onTap: () => _navigateToPlanYourRide(context, 'Shared'),
                    ),
                    RideServiceCard(
                      image:
                          'assets/images/service_cards/service_scheduled.png',
                      title: 'Scheduled',
                      subtitle: 'Plan ahead',
                      onTap: () => _navigateToPlanYourRide(context, 'Solo', schedule: 'Scheduled'),
                    ),
                    RideServiceCard(
                      image:
                          'assets/images/service_cards/service_womenOnly.png',
                      title: 'Women Only',
                      subtitle: 'Safe & Comfortable',
                      onTap: () => _navigateToPlanYourRide(context, 'Women Only'),
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
                  children: [
                    RideOptionCard(
                      icon: 'assets/icons/vehicles/tuk.png',
                      title: 'Tuk',
                      isPromo: true,
                      onTap: () => _navigateToPlanYourRide(context, 'Tuk'),
                    ),
                    RideOptionCard(
                      icon: 'assets/icons/vehicles/ride.png',
                      title: 'Ride',
                      onTap: () => _navigateToPlanYourRide(context, 'Solo'),
                    ),
                    RideOptionCard(
                      icon: 'assets/icons/vehicles/rush.png',
                      title: 'Rush',
                      onTap: () => _navigateToPlanYourRide(context, 'Rush'),
                    ),
                    RideOptionCard(
                      icon: 'assets/icons/vehicles/primeRide.png',
                      title: 'Prime',
                      onTap: () => _navigateToPlanYourRide(context, 'Prime'),
                    ),
                    RideOptionCard(
                      icon: 'assets/icons/vehicles/squad.png',
                      title: 'Squad',
                      onTap: () => _navigateToPlanYourRide(context, 'Squad'),
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
