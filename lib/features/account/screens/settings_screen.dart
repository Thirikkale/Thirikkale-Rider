import 'package:flutter/material.dart';
import 'package:thirikkale_rider/features/account/screens/settings/settings_screens.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thirikkale_rider/features/account/screens/settings/saved_location_screen.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/config/routes.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/features/account/widgets/account_info_tile.dart';
import 'package:thirikkale_rider/features/account/widgets/sign_out_btn.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/widgets/common/section_subheader.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _homeLocation;
  String? _workLocation;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _homeLocation = prefs.getString('home_location');
      _workLocation = prefs.getString('work_location');
    });
  }

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
                subtitle: _homeLocation ?? "Set your home location",
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavedLocationScreen(type: 'home'),
                    ),
                  );
                  _loadLocations();
                },
              ),
              AccountInfoTile(
                icon: Icons.work_outline,
                title: "Work",
                subtitle: _workLocation ?? "Set your work location",
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavedLocationScreen(type: 'work'),
                    ),
                  );
                  _loadLocations();
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
                title: "Notifications",
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PreferencesScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: AppDimensions.sectionSpacing),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SignOutBtn(
                  onPressed: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text("Confirm Logout"),
                            content: const Text(
                              "Are you sure you want to sign out?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Sign Out"),
                              ),
                            ],
                          ),
                    );

                    if (shouldLogout == true) {
                      if (!context.mounted) return;
                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      await authProvider.logout();
                      if (!context.mounted) return;

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.getStarted,
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
