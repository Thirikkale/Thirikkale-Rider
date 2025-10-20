import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thirikkale_rider/config/routes.dart';
import 'package:thirikkale_rider/core/providers/auth_provider.dart';
import 'package:thirikkale_rider/core/providers/location_provider.dart';
import 'package:thirikkale_rider/core/providers/ride_booking_provider.dart';
import 'package:thirikkale_rider/core/providers/ride_tracking_provider.dart';
import 'package:thirikkale_rider/core/services/env_service.dart';
import 'package:thirikkale_rider/core/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EnvService.load();
  imageCache.maximumSizeBytes = 100 << 20; // 100MB
  runApp(ThirikkaleApp());
}

class ThirikkaleApp extends StatelessWidget {
  const ThirikkaleApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => RideTrackingProvider()),
        ChangeNotifierProxyProvider<AuthProvider, RideBookingProvider>(
          create: (_) => RideBookingProvider(),
          update:
              (_, auth, previousRideBooking) =>
                  previousRideBooking!..update(auth),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Thirikkale',
        theme: AppTheme.lightTheme,
        // darkTheme: AppTheme.darkTheme,
        // themeMode: ThemeMode.system,
        initialRoute: AppRoutes.initial,
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
