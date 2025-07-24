import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
import 'package:thirikkale_rider/features/account/screens/payment_methods/payment_methods_screen.dart';
import 'package:thirikkale_rider/features/account/screens/promotions_screen.dart';
import 'package:thirikkale_rider/features/account/screens/settings_screen.dart';
import 'package:thirikkale_rider/features/activity/screens/activity_screen.dart';
import 'package:thirikkale_rider/features/account/widgets/account_feature_card.dart';
import 'package:thirikkale_rider/features/account/widgets/account_info_tile.dart';
import 'package:thirikkale_rider/features/account/widgets/payment_info_tile.dart';
import 'package:thirikkale_rider/features/account/widgets/profile_header.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar_name.dart';
import 'package:thirikkale_rider/widgets/common/section_subheader.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {

        return Scaffold(
          appBar: CustomAppbarName(title: 'Account', showBackButton: true),
          bottomNavigationBar: BottomNavbar(currentIndex: 3),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.pageVerticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProfileHeader(
                    imageUrl: 'assets/images/default_profile.png',
                    name: (authProvider.fullName.isNotEmpty) ? authProvider.fullName : 'Rider',
                    subtitle: '0.00 • Rider',
                  ),

                  const SizedBox(height: AppDimensions.subSectionSpacing),
                  const SectionSubheader(title: "Details"),
                  AccountInfoTile(
                    icon: Icons.email_outlined,
                    title: "Email",
                    subtitle: (authProvider.verifiedEmail != null && authProvider.verifiedEmail!.isNotEmpty) ? authProvider.verifiedEmail! : 'Not provided',
                    onTap: () {},
                  ),
                  AccountInfoTile(
                    icon: Icons.phone_outlined,
                    title: "Phone",
                    subtitle: authProvider.verifiedPhoneNumber,
                    onTap: () {},
                  ),

                  const SizedBox(height: AppDimensions.subSectionSpacing),
                  const SectionSubheader(title: "Payment"),
                  PaymentInfoTile(
                    icon: "assets/images/visa_card.jpg",
                    cardInfo: "Visa •••• •••• •••• 4242",
                    expiryDate: "Expires 07/2030",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentMethodsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.subSectionSpacing),
                  const SectionSubheader(title: "Rides"),
                  AccountInfoTile(
                    icon: Icons.history_rounded,
                    title: "Ride history",
                    onTap: () {
                      Navigator.of(context).push(
                        NoAnimationPageRoute(
                          builder:
                              (context) =>
                                  const ActivityScreen(initialTabIndex: 1),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppDimensions.subSectionSpacing),

                  AccountFeatureCard(
                    title: 'CO2 saved',
                    subtitle:
                        '12.5 kg\nYou\'ve saved 12.5 kg of CO2 by using shared rides.',
                    icon: const Icon(Icons.eco, size: 32),
                  ),

                  const SizedBox(height: AppDimensions.widgetSpacing),
                  AccountFeatureCard(
                    title: 'Settings',
                    subtitle: 'Manage your account and app preferences.',
                    icon: const Icon(Icons.settings_outlined, size: 32),
                    onTap: () {
                      Navigator.of(context).push(
                        NoAnimationPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppDimensions.widgetSpacing),
                  AccountFeatureCard(
                    title: 'Promotions',
                    subtitle: 'View current offers and discounts.',
                    icon: const Icon(Icons.price_change_outlined, size: 32),
                    onTap: () {
                      Navigator.of(context).push(
                        NoAnimationPageRoute(
                          builder: (context) => const PromotionsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
