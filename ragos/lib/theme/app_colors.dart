// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Global colour palette for the whole RAGOS app
class AppColors {
  // core brand
  static const Color background = Colors.black;          // #000000
  static const Color primary    = Color(0xFFFCC120);     // yellow   – CTA / primary buttons
  static const Color inputBG    = Color(0xFF2E2E2E);     // dark gray – text fields
  static const Color lightBtn   = Color(0xFFB2B2B2);     // light gray – secondary buttons
  static const Color text       = Colors.white;          // normal text

  // semantic notifications
  static const Color notifPositive = Color(0xFF92C751);  // green
  static const Color notifNeutral  = Color(0xFFFCC120);  // yellow
  static const Color notifNegative = Color(0xFFE1011B);  // red

  // convenience aliases
  static const Color white  = Colors.white;
  static const Color black  = Colors.black;

  static const Color greyLine = Color(0xFFBDBDBD); // light grey for timeline lines

}
