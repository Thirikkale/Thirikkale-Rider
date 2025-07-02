import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(currentIndex: 3),
      body: Text("Account Screen", style: AppTextStyles.heading1,),
    );
  }
}