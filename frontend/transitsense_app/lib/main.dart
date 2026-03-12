import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

void main() {
  runApp(const TransitSenseApp());
}

class TransitSenseApp extends StatelessWidget {
  const TransitSenseApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TransitSense',
      theme: AppTheme.theme,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}