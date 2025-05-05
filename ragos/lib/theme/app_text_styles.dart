// lib/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralised text‐style definitions.
/// Use these instead of ad-hoc TextStyle literals.
class AppTextStyles {
  // section titles, big numbers, etc.
  static TextStyle get title => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );

  // normal body text
  static TextStyle get body => GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.text,
      );

  // small helper / placeholder
  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.text.withOpacity(.7),
      );

  // input fields
  static TextStyle get input => GoogleFonts.inter(
        fontSize: 16,
        color: AppColors.text,
      );

  // primary button label
  static TextStyle get button => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.black,
      );

  // tappable “link”
  static TextStyle get link => GoogleFonts.inter(
        fontSize: 14,
        decoration: TextDecoration.underline,
        color: AppColors.primary,
      );
}
