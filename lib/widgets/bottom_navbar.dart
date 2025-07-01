import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/core/utils/navigation_utils.dart';
import 'package:thirikkale_rider/features/account/screens/account_screen.dart';
import 'package:thirikkale_rider/features/activity/screens/activity_screen.dart';
import 'package:thirikkale_rider/features/home/screens/home_screen.dart';
import 'package:thirikkale_rider/features/services/screens/services_screen.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;

  const BottomNavbar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (index == currentIndex) return;

          _navigateWithNoAnimation(context, index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  // Helper method to navigate with NoAnimationRoute
  void _navigateWithNoAnimation(BuildContext context, int index) {
    Widget destinationScreen;

    switch (index) {
      case 0:
        // Import these screen classes at the top of the file
        destinationScreen = const HomeScreen();
        break;
      case 1:
        destinationScreen = const ServicesScreen();
        break;
      case 2:
        destinationScreen = const ActivityScreen();
        break;
      case 3:
        destinationScreen = const AccountScreen();
        break;
      default:
        destinationScreen = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      NoAnimationPageRoute(builder: (context) => destinationScreen),
    );
  }
}
