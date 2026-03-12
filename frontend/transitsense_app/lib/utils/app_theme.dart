import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {

  static ThemeData theme = ThemeData(

    scaffoldBackgroundColor: AppColors.lightBackground,

    primaryColor: AppColors.primaryBlue,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
    ),

  );
}