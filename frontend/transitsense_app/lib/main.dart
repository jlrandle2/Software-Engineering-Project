import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const TransitSenseApp());
}

class TransitSenseApp extends StatefulWidget {
  const TransitSenseApp({super.key});

  @override
  State<TransitSenseApp> createState() => _TransitSenseAppState();
}

class _TransitSenseAppState extends State<TransitSenseApp> {

  bool isDarkMode = false;

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "TransitSense",
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,

      // 🔥 CHANGED THIS LINE ONLY
      home: AuthGate(
        toggleTheme: toggleTheme,
        isDarkMode: isDarkMode,
      ),
    );
  }
}






// =====================================================
// 🔥 NEW: AUTH GATE (DO NOT REMOVE)
// =====================================================

class AuthGate extends StatelessWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const AuthGate({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int?>(
      future: getUserId(),
      builder: (context, snapshot) {

        // 🔄 loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // ❌ no user → go to signup
        if (snapshot.data == null) {
        return LoginScreen(
          toggleTheme: toggleTheme,
          isDarkMode: isDarkMode,
        );
      }

        // ✅ user exists → go to home
        return HomeScreen(
          toggleTheme: toggleTheme,
          isDarkMode: isDarkMode,
        );
      },
    );
  }
}