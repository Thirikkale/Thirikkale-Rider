import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_dimension.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
import 'package:thirikkale_rider/features/account/screens/payment_methods/payment_methods_screen.dart';
import 'package:thirikkale_rider/features/account/screens/settings_screen.dart';
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
                name: 'Olivia Bennett',
                subtitle: '4.96 • Rider',
              ),

              const SizedBox(height: AppDimensions.subSectionSpacing),
              const SectionSubheader(title: "Details"),
              AccountInfoTile(
                icon: Icons.email_outlined,
                title: "Email",
                subtitle: "olivia.bennett@gmail.com",
                onTap: () {},
              ),
              AccountInfoTile(
                icon: Icons.phone_outlined,
                title: "Phone",
                subtitle: "+94 78 366 9100",
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
                onTap: () {},
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
                    NoAnimationPageRoute(builder: (context) => const SettingsScreen())
                  );
                },
              ),

              const SizedBox(height: AppDimensions.widgetSpacing),
              AccountFeatureCard(
                title: 'Promotions',
                subtitle: 'View current offers and discounts.',
                icon: const Icon(Icons.price_change_outlined, size: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
