import 'package:flutter/material.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/widgets/bottom_navbar.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      bottomNavigationBar: BottomNavbar(currentIndex: 2),
      body: Text("Activities Screen", style: AppTextStyles.heading1,),
    );
  }
}