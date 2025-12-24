import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import 'app_colors.dart';

/// Kkomi App Custom Theme for Forui
abstract final class AppTheme {
  // ==========================================================================
  // LIGHT THEME COLORS
  // ==========================================================================
  static const _lightColors = FColors(
    brightness: Brightness.light,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    barrier: Color(0x33000000),
    // Surface
    background: AppColors.surface,
    foreground: AppColors.textPrimary,
    // Primary - Warm Brown
    primary: AppColors.primary500,
    primaryForeground: AppColors.textInverse,
    // Secondary - Golden Yellow
    secondary: AppColors.secondary100,
    secondaryForeground: AppColors.primary700,
    // Muted - Neutral
    muted: AppColors.neutral200,
    mutedForeground: AppColors.textSecondary,
    // Destructive
    destructive: AppColors.error,
    destructiveForeground: AppColors.textInverse,
    // Error
    error: AppColors.error,
    errorForeground: AppColors.textInverse,
    // Border
    border: AppColors.neutral300,
  );

  // ==========================================================================
  // DARK THEME COLORS
  // ==========================================================================
  static const _darkColors = FColors(
    brightness: Brightness.dark,
    systemOverlayStyle: SystemUiOverlayStyle.light,
    barrier: Color(0x66000000),
    // Surface
    background: AppColors.surfaceDark,
    foreground: AppColors.textInverse,
    // Primary - Warm Brown (lighter for dark mode)
    primary: AppColors.primary400,
    primaryForeground: AppColors.textPrimary,
    // Secondary - Golden Yellow
    secondary: AppColors.primary800,
    secondaryForeground: AppColors.secondary300,
    // Muted - Neutral
    muted: AppColors.surfaceContainerDark,
    mutedForeground: AppColors.neutral400,
    // Destructive
    destructive: AppColors.error,
    destructiveForeground: AppColors.textInverse,
    // Error
    error: AppColors.error,
    errorForeground: AppColors.textInverse,
    // Border
    border: AppColors.surfaceDimDark,
  );

  // ==========================================================================
  // THEMES
  // ==========================================================================

  /// Light theme with custom Kkomi colors
  static final FThemeData light = FThemes.zinc.light.copyWith(
    colors: _lightColors,
    // ignore: implicit_call_tearoffs
    buttonStyles: FButtonStyles.inherit(
      colors: _lightColors,
      typography: FThemes.zinc.light.typography,
      style: FThemes.zinc.light.style,
    ),
  );

  /// Dark theme with custom Kkomi colors
  static final FThemeData dark = FThemes.zinc.dark.copyWith(
    colors: _darkColors,
    // ignore: implicit_call_tearoffs
    buttonStyles: FButtonStyles.inherit(
      colors: _darkColors,
      typography: FThemes.zinc.dark.typography,
      style: FThemes.zinc.dark.style,
    ),
  );
}
