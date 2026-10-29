import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  /// Minimum height for anything a child taps. Above Android's 48dp guideline
  /// because younger hands are less precise.
  static const minTouchTarget = 56.0;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.buddyBlue,
      primary: AppColors.buddyBlueShade,
      onPrimary: AppColors.white,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
    );
    final base = ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.paper,
    );
    final text = base.textTheme
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink)
        .copyWith(
          headlineMedium: base.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: AppColors.ink,
          ),
          titleLarge: base.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          titleMedium: base.textTheme.titleMedium?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          bodyLarge: base.textTheme.bodyLarge?.copyWith(
            fontSize: 18,
            height: 1.35,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
          bodyMedium: base.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            height: 1.3,
            color: AppColors.inkSoft,
          ),
        );
    const outline = BorderSide(
      color: AppColors.ink,
      width: AppShapes.outlineWidth,
    );
    // Derived from the theme so buttons keep the theme's font family.
    final buttonText = text.labelLarge!.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w800,
    );

    return base.copyWith(
      textTheme: text,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(minTouchTarget, minTouchTarget),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          textStyle: buttonText,
          shape: const StadiumBorder(side: outline),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(minTouchTarget, 48),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          foregroundColor: AppColors.ink,
          backgroundColor: AppColors.white,
          textStyle: buttonText.copyWith(fontSize: 15),
          side: outline,
          shape: const StadiumBorder(),
        ),
      ),
    );
  }
}

/// The shared "sticker" look: flat fill, ink outline, hard offset shadow.
abstract final class AppShapes {
  static const outlineWidth = 2.5;
  static const radius = 24.0;
  static const shadowDepth = 5.0;

  static BoxDecoration sticker(
    Color fill, {
    double depth = shadowDepth,
    double radius = radius,
  }) => BoxDecoration(
    color: fill,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.ink, width: outlineWidth),
    boxShadow: [BoxShadow(color: AppColors.ink, offset: Offset(0, depth))],
  );
}
