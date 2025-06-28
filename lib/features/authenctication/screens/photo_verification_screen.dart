import 'package:flutter/material.dart';
import 'package:thirikkale_rider/widgets/common/custom_appbar.dart';

class PhotoVerificationScreen extends StatelessWidget {
  const PhotoVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        centerWidget: Image.asset(
          'assets/images/thirikkale_primary_logo.png',
          height: 32.0,
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Text("Profile verification"),
      ),
    );
  }
}
