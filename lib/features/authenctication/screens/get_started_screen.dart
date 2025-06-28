import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/authenctication/screens/mobile_registration_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Row(
                children: [
                  SizedBox(width: 60),
                  Image.asset(
                    'assets/images/thirikkale_dark_logo.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ],
              ),

              // Text("Thirikkale", style: AppTextStyles.heading1,),
              const SizedBox(height: 20),
              Expanded(
                flex: 3,
                child: Lottie.asset(
                  'assets/lotties/get_started_animation2.json',
                  fit: BoxFit.contain,
                  repeat: true,
                ),
              ),
              const SizedBox(height: 60),
              Text(
                'Solo or together\nalways your call',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const MobileRegistrationScreen(),
                        ),
                      );
                    } catch (e) {
                      print("Navigation error: $e");
                      // Show a snackbar or dialog to inform the user
                    }
                  },
                  style: AppButtonStyles.primaryButton,
                  child: const Text('Get Started'),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
