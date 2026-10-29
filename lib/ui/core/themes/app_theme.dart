import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() =>
      ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple));
}
