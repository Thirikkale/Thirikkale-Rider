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
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EnvService.load();

  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 'PK_KEY_FALLBACK';
  // Initialize the native Stripe SDK with the current settings.
  // applySettings() is async and will configure platform-specific options.
  try {
  await Stripe.instance.applySettings();
  // Optional: print to confirm initialization
  // ignore: avoid_print
  print('✅ Stripe initialized with publishableKey: ${Stripe.publishableKey.substring(0, 10)}...');
  } catch (e) {
    // ignore: avoid_print
    print('⚠️ Failed to initialize Stripe: $e');
  }

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
