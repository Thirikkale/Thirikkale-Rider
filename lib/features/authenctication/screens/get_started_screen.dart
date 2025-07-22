import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:thirikkale_rider/core/utils/app_styles.dart';
import 'package:thirikkale_rider/features/authenctication/screens/mobile_registration_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            const SizedBox(height: 60,),
            Image.asset(
              'assets/images/thirikkale_dark_logo.png',
              height: 100,
              fit: BoxFit.contain,
            ),

            Expanded(
              flex: 5,
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
            const SizedBox(height: 60),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MobileRegistrationScreen(),
                    ),
                  );
                },
                style: AppButtonStyles.primaryButton,
                child: const Text('Get Started'),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
