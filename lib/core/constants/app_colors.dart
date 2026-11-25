import 'package:flutter/material.dart';

class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF2563EB); // Royal Blue
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color primaryLight = Color(0xFF60A5FA);

  // Background colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E293B);

  // Weather card gradients
  static const List<Color> sunnyGradient = [
    Color(0xFFFF8A00),
    Color(0xFFE52E71),
  ];

  static const List<Color> cloudyGradient = [
    Color(0xFF3A7BD5),
    Color(0xFF3A6073),
  ];

  static const List<Color> rainyGradient = [
    Color(0xFF1F4068),
    Color(0xFF162447),
  ];

  static const List<Color> nightGradient = [
    Color(0xFF0F2027),
    Color(0xFF203A43),
    Color(0xFF2C5364),
  ];

  static const List<Color> thunderstormGradient = [
    Color(0xFF283048),
    Color(0xFF859398),
  ];

  // Accents
  static const Color accentBlue = Color(0xFF38BDF8);
  static const Color accentYellow = Color(0xFFFBBF24);
  static const Color accentRed = Color(0xFFF87171);
  static const Color accentGreen = Color(0xFF34D399);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
}
