import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(currentIndex: 0),
      body: Column(
        children: [
          Text("Home Screen", style: AppTextStyles.heading1,)
        ],
      ),
    );
  }
}