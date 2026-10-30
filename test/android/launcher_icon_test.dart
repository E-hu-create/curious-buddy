import 'dart:io';

import 'package:curious_buddy/ui/core/themes/app_colors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the app icon background is the Game Zone night sky', () {
    final hex = AppColors.arcade
        .toARGB32()
        .toRadixString(16)
        .toUpperCase()
        .padLeft(8, '0');
    expect(
      File('android/app/src/main/res/values/colors.xml').readAsStringSync(),
      contains('<color name="ic_launcher_background">#$hex</color>'),
    );
  });
}
