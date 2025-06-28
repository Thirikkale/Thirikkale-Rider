import 'package:flutter/material.dart';
import 'package:thirikkale_rider/features/authenctication/screens/get_started_screen.dart';
import 'package:thirikkale_rider/features/authenctication/screens/mobile_registration_screen.dart';
import 'package:thirikkale_rider/features/authenctication/screens/name_registration_screen.dart';
import 'package:thirikkale_rider/features/authenctication/screens/otp_verification_screen.dart';
import 'package:thirikkale_rider/features/authenctication/screens/splash_screen.dart';
import 'package:thirikkale_rider/features/authenctication/screens/terms_and_privacy_screen.dart';
import 'package:thirikkale_rider/features/home/screens/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String mobileRegistration = '/mobile-registration';
  static const String otpVerification = '/otp-verification';
  static const String nameRegistration = '/name-registration';
  static const String termsAndPrivacy = '/terms-and-privacy';
  static const String splashScreen = '/splash-screen';
  static const String home = '/home';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      initial: (context) => const GetStartedScreen(),
      mobileRegistration: (context) => const MobileRegistrationScreen(),
      otpVerification: (context) => const OtpVerificationScreen(),
      nameRegistration: (context) => const NameRegistrationScreen(),
      termsAndPrivacy: (context) => const TermsAndPrivacyScreen(),
      splashScreen: (context) => const SplashScreen(),
      home: (context) => const HomeScreen(),
    };
  }
}
