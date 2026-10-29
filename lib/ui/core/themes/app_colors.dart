import 'package:flutter/material.dart';

/// App palette. UI uses the flat "sticker" look (solid fills, dark ink
/// outlines); only Buddy uses soft shading.
abstract final class AppColors {
  static const ink = Color(0xFF1F2A44);
  static const inkSoft = Color(0xFF465170);
  static const paper = Color(0xFFFFF8EE);
  static const white = Color(0xFFFFFFFF);

  /// Buttons and interactive accents.
  static const brandBlue = Color(0xFF4A93FA);
  static const brandBlueDeep = Color(0xFF2A68C9);

  // Buddy's character model. See docs/MASCOT.md before changing these.
  static const buddyTealLight = Color(0xFF6FDDD2);
  static const buddyTeal = Color(0xFF2BB3A8);
  static const buddyTealDeep = Color(0xFF15807A);
  static const buddyOutline = Color(0xFF0D5550);
  static const buddyBelly = Color(0xFFA6F0E7);
  static const buddyIris = Color(0xFF1D4F6E);
  static const buddyIrisLight = Color(0xFF3F8DB8);
  static const buddyPupil = Color(0xFF0D1A26);
  static const buddyMouth = Color(0xFF15303A);
  static const buddyTongue = Color(0xFFFF8FA3);
  static const backpack = Color(0xFFFFC43D);
  static const backpackShade = Color(0xFFE0960F);
  static const backpackOutline = Color(0xFF8F5E05);
  static const cheek = Color(0xFFFF9BB3);

  /// Soft cyan glow for gems and signals in illustrations.
  static const eyeGlowSoft = Color(0xFF7FE7FF);

  static const sun = Color(0xFFFFC93C);
  static const sunTint = Color(0xFFFFEDB8);
  static const coral = Color(0xFFFF7A59);
  static const coralTint = Color(0xFFFFDCD0);
  static const leaf = Color(0xFF3BB273);
  static const leafTint = Color(0xFFD3F2DF);
  static const grape = Color(0xFF9B7BF2);
  static const grapeTint = Color(0xFFE7DEFF);
}
