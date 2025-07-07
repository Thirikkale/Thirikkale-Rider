import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/features/account/screens/settings/settings_screens.dart';
import 'package:thirikkale_rider/features/account/widgets/account_info_tile.dart';
import 'package:thirikkale_rider/features/account/widgets/sign_out_btn.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/widgets/common/section_subheader.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbarName(title: "Settings", showBackButton: true),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.pageVerticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionSubheader(title: "App Setting"),
              AccountInfoTile(
                icon: Icons.home_outlined,
                title: "Home",
                subtitle: "123 Elm st, Springfield",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeLocationScreen(),
                    ),
                  );
                },
              ),
              AccountInfoTile(
                icon: Icons.work_outline,
                title: "Work",
                subtitle: "456 Oak Ave, Spirngfield",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WorkLocationScreen(),
                    ),
                  );
                },
              ),
              AccountInfoTile(
                icon: Icons.wb_sunny_outlined,
                title: "App appearance",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppearanceScreen(),
                    ),
                  );
                },
              ),
              AccountInfoTile(
                icon: Icons.notifications_none,
                title: "Notificaitons",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              AccountInfoTile(
                icon: Icons.language_outlined,
                title: "Language",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.subSectionSpacing),
              SectionSubheader(title: "Safety Setting"),
              AccountInfoTile(
                icon: Icons.shield_outlined,
                title: "Emergency contacts",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EmergencyContactsScreen(),
                    ),
                  );
                },
              ),
              AccountInfoTile(
                icon: Icons.directions_car_outlined,
                title: "Safety features",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SafetyFeaturesScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.subSectionSpacing),
              SectionSubheader(title: "Ride Setting"),
              AccountInfoTile(
                icon: Icons.tune_outlined,
                title: "Ride preferences",
                onTap: () {},
              ),

              const SizedBox(height: AppDimensions.sectionSpacing),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                ),
                child: SignOutBtn(onPressed: () {}),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
