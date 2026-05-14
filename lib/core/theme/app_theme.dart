import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF005C66);
  static const secondary = Color(0xFF22B8A8);
  static const softGreen = Color(0xFFE0F2F1);
  static const softBlue = Color(0xFFEAF4F7);
  static const softPurple = Color(0xFFF0ECFF);
  static const softOrange = Color(0xFFFFF3E3);

  static const background = Color(0xFFF9FAFB);
  static const card = Color(0xFFFFFFFF);

  static const text = Color(0xFF102A43);
  static const muted = Color(0xFF6B7C93);
  static const border = Color(0xFFE6EDF2);

  static const success = Color(0xFF35C989);
  static const warning = Color(0xFFF5A623);
  static const danger = Color(0xFFFF6B6B);
}

class AppTheme {
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.4,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor: AppColors.softGreen,
        labelTextStyle: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.selected)) {
              return const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              );
            }

            return const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.muted,
            );
          },
        ),
        iconTheme: MaterialStateProperty.resolveWith(
          (states) {
            if (states.contains(MaterialState.selected)) {
              return const IconThemeData(
                color: AppColors.primary,
                size: 22,
              );
            }

            return const IconThemeData(
              color: AppColors.muted,
              size: 21,
            );
          },
        ),
      ),
    );
  }
}