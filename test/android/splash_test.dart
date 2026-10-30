import 'dart:io';

import 'package:curious_buddy/ui/core/themes/app_colors.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guards the Android splash: it must match the app, in every mode.
void main() {
  const res = 'android/app/src/main/res';
  String read(String path) => File('$res/$path').readAsStringSync();

  test('the splash colour is the app background colour', () {
    final hex = AppColors.paper
        .toARGB32()
        .toRadixString(16)
        .toUpperCase()
        .padLeft(8, '0');
    expect(
      read('values/colors.xml'),
      contains('<color name="splash_background">#$hex</color>'),
    );
  });

  test('Android 12+ shows Buddy and the name on the app colour', () {
    final styles = read('values-v31/styles.xml');
    expect(
      styles,
      contains('windowSplashScreenBackground">@color/splash_background'),
    );
    expect(
      styles,
      contains('windowSplashScreenAnimatedIcon">@drawable/splash_icon'),
    );
    expect(
      styles,
      contains('windowSplashScreenBrandingImage">@drawable/splash_name'),
    );
  });

  test('dark mode shows the same splash, since the app is always light', () {
    expect(read('values-night-v31/styles.xml'), read('values-v31/styles.xml'));
    expect(read('values-night/styles.xml'), read('values/styles.xml'));
  });

  test('no white or black flash before the first frame', () {
    for (final path in [
      'values/styles.xml',
      'values-night/styles.xml',
      'values-v31/styles.xml',
      'values-night-v31/styles.xml',
    ]) {
      expect(read(path), isNot(contains('colorBackground')), reason: path);
    }
  });

  test('older Android shows the same picture', () {
    for (final dir in ['drawable', 'drawable-v21']) {
      final layers = read('$dir/launch_background.xml');
      expect(layers, contains('@color/splash_background'));
      expect(layers, contains('@drawable/splash_legacy'));
    }
  });

  test('every screen density has all three images', () {
    for (final density in ['mdpi', 'hdpi', 'xhdpi', 'xxhdpi', 'xxxhdpi']) {
      for (final name in ['splash_icon', 'splash_name', 'splash_legacy']) {
        expect(
          File('$res/drawable-$density/$name.png').existsSync(),
          isTrue,
          reason: '$density/$name',
        );
      }
    }
  });
}
