import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/features/activity/widgets/ride_history_card.dart';
import 'package:thirikkale_rider/widgets/common/section_header.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbarName(title: 'Activity', showBackButton: true),
      bottomNavigationBar: BottomNavbar(currentIndex: 2),
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
                const SectionHeader(title: 'Past Activities'),

                const SizedBox(height: AppDimensions.widgetSpacing),

                RideHistoryCard(
                  mapImage: 'assets/images/map_placeholder.png',
                  destination:
                      'Wickramaarachchi Opticians & Hearing Care Galle',
                  date: 'Jun 6, 5:00 PM',
                  price: 'LKR 212.00',
                  vehicleIcon: 'assets/icons/vehicles/tuk.png',
                  onPressed: () {},
                ),
                const SizedBox(height: AppDimensions.widgetSpacing),

                RideHistoryCard(
                  destination: 'Unity Plaza',
                  date: 'Jun 5, 5:00 PM',
                  price: 'LKR 212.00',
                  vehicleIcon: 'assets/icons/vehicles/tuk.png',
                  onPressed: () {},
                ),
                const SizedBox(height: AppDimensions.widgetSpacing),

                RideHistoryCard(
                  destination: '35 Reid Ave',
                  date: 'May 23, 4:09 PM',
                  price: 'LKR 255.00',
                  vehicleIcon: 'assets/icons/vehicles/tuk.png',
                  onPressed: () {},
                ),
                const SizedBox(height: AppDimensions.widgetSpacing),

                RideHistoryCard(
                  destination: 'Sudewila Road',
                  date: 'May 20, 3:10 PM',
                  price: 'LKR 181.00',
                  vehicleIcon: 'assets/icons/vehicles/tuk.png',
                  onPressed: () {},
                ),
                const SizedBox(height: AppDimensions.widgetSpacing),

                RideHistoryCard(
                  destination: 'Univeristy of Colombo School of Computing (UCSC)',
                  date: 'May 12, 9:10 PM',
                  price: 'LKR 232.00',
                  vehicleIcon: 'assets/icons/vehicles/tuk.png',
                  onPressed: () {},
                ),
                const SizedBox(height: AppDimensions.widgetSpacing),

                RideHistoryCard(
                  destination: 'Athurugiriya Clock Tower',
                  date: 'April 21, 2:18 PM',
                  price: 'LKR 378.00',
                  vehicleIcon: 'assets/icons/vehicles/ride.png',
                  onPressed: () {},
                ),
                const SizedBox(height: AppDimensions.widgetSpacing),

                RideHistoryCard(
                  destination: 'Maharagama Clock Tower',
                  date: 'April 16, 2:40 PM',
                  price: 'LKR 439.10',
                  vehicleIcon: 'assets/icons/vehicles/tuk.png',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
