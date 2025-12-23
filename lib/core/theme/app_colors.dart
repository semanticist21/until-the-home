import 'package:flutter/material.dart';

/// Kkomi App Design System - Color Palette
///
/// Extracted from app icon:
/// - Warm brown tones (cat fur)
/// - Golden yellow (background)
/// - Neutral beige tones
abstract final class AppColors {
  // ==========================================================================
  // PRIMARY - Warm Brown (고양이 털)
  // ==========================================================================
  static const Color primary50 = Color(0xFFFBF5F2);
  static const Color primary100 = Color(0xFFF5E6DE);
  static const Color primary200 = Color(0xFFEAC9B8);
  static const Color primary300 = Color(0xFFDEA88E);
  static const Color primary400 = Color(0xFFD18A68);
  static const Color primary500 = Color(0xFFB75634); // Base
  static const Color primary600 = Color(0xFF9A472B);
  static const Color primary700 = Color(0xFF7D3922);
  static const Color primary800 = Color(0xFF602B1A);
  static const Color primary900 = Color(0xFF3E2C28); // Dark brown

  // ==========================================================================
  // SECONDARY - Golden Yellow (배경)
  // ==========================================================================
  static const Color secondary50 = Color(0xFFFFFDF5);
  static const Color secondary100 = Color(0xFFFEF9E6);
  static const Color secondary200 = Color(0xFFFDF2C8);
  static const Color secondary300 = Color(0xFFFCEAA5);
  static const Color secondary400 = Color(0xFFFBE382);
  static const Color secondary500 = Color(0xFFFDDC64); // Base
  static const Color secondary600 = Color(0xFFE5C44A);
  static const Color secondary700 = Color(0xFFCCA545); // Gold
  static const Color secondary800 = Color(0xFFB08A32);
  static const Color secondary900 = Color(0xFF8A6B20);

  // ==========================================================================
  // NEUTRAL - Warm Beige
  // ==========================================================================
  static const Color neutral50 = Color(0xFFFAF9F7);
  static const Color neutral100 = Color(0xFFF5F3F0);
  static const Color neutral200 = Color(0xFFEBE8E3);
  static const Color neutral300 = Color(0xFFDDD9D2);
  static const Color neutral400 = Color(0xFFC2BFA9); // From icon
  static const Color neutral500 = Color(0xFFA09C8E);
  static const Color neutral600 = Color(0xFF7D7970);
  static const Color neutral700 = Color(0xFF5C5850);
  static const Color neutral800 = Color(0xFF3D3A34);
  static const Color neutral900 = Color(0xFF1F1D1A);

  // ==========================================================================
  // SEMANTIC - Functional colors
  // ==========================================================================
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFDBEAFE);

  // ==========================================================================
  // SURFACE
  // ==========================================================================
  // Light
  static const Color surface = Color(0xFFFFFDF8);
  static const Color surfaceContainer = Color(0xFFF5F3F0);
  static const Color surfaceDim = Color(0xFFEBE8E3);

  // Dark
  static const Color surfaceDark = Color(0xFF1A1816);
  static const Color surfaceContainerDark = Color(0xFF292623);
  static const Color surfaceDimDark = Color(0xFF34302C);

  // ==========================================================================
  // TEXT
  // ==========================================================================
  static const Color textPrimary = Color(0xFF1F1D1A);
  static const Color textSecondary = Color(0xFF5C5850);
  static const Color textDisabled = Color(0xFFA09C8E);
  static const Color textInverse = Color(0xFFFAF9F7);

  // ==========================================================================
  // APP SPECIFIC - From icon
  // ==========================================================================
  static const Color catFurLight = Color(0xFFE0A062);
  static const Color catFurDark = Color(0xFF3E2C28);
  static const Color iconBackground = Color(0xFFFDDC64);
}
