import 'package:flutter/material.dart';
import 'package:thirikkale_rider/config/routes.dart';
import 'package:thirikkale_rider/core/utils/app_theme.dart';

void main() {
  runApp(ThirikkaleApp());
}

class ThirikkaleApp extends StatelessWidget {
  const ThirikkaleApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Thirikkale',
      theme: AppTheme.lightTheme,
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system,
      initialRoute: AppRoutes.initial,
      routes: AppRoutes.getRoutes(),
    );
  }
}
