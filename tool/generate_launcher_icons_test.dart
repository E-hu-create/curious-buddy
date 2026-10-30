// Regenerates the Android launcher icons from BuddyPainter, so the icon
// always matches the in-app character. Not part of the normal test run.
//
// Run from the project root after changing Buddy:
//   flutter test tool/generate_launcher_icons_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:curious_buddy/ui/core/themes/app_colors.dart';
import 'package:curious_buddy/ui/core/widgets/buddy/buddy_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _res = 'android/app/src/main/res';
const _densities = {
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

/// Head and shoulders in Buddy's 100 x 120 grid: the face must read at 48px.
const _crop = Rect.fromLTRB(10, 28, 92, 104);

void main() {
  test('generate Android launcher icons', () async {
    for (final MapEntry(key: density, value: scale) in _densities.entries) {
      final dir = '$_res/mipmap-$density';
      // Legacy icon (Android 7 and older launchers): 48dp, own background.
      await _writePng('$dir/ic_launcher.png', (48 * scale).round(), _legacy);
      // Adaptive foreground: 108dp, content inside the central 66dp.
      await _writePng(
        '$dir/ic_launcher_foreground.png',
        (108 * scale).round(),
        (canvas, size) {
          // The sun fills the part of the icon every phone shows.
          _sun(canvas, size, radius: size * 36 / 108);
          _buddy(canvas, size, fit: size * 66 / 108);
        },
      );
    }
  });
}

void _legacy(Canvas canvas, double size) {
  final shape = RRect.fromRectAndRadius(
    Offset.zero & Size.square(size),
    Radius.circular(size * 0.22),
  );
  canvas
    ..clipRRect(shape)
    ..drawRRect(shape, Paint()..color = AppColors.arcade);
  _sun(canvas, size, radius: size * 0.46);
  _buddy(canvas, size, fit: size * 0.84);
}

void _sun(Canvas canvas, double size, {required double radius}) {
  canvas.drawCircle(
    Offset(size / 2, size / 2),
    radius,
    Paint()..color = AppColors.sun,
  );
}

void _buddy(Canvas canvas, double size, {required double fit}) {
  final scale = fit / _crop.longestSide;
  canvas
    ..save()
    ..translate(size / 2, size / 2)
    ..scale(scale)
    ..translate(-_crop.center.dx, -_crop.center.dy);
  const BuddyPainter(
    mood: BuddyMood.happy,
  ).paint(canvas, const Size(BuddyPainter.gridWidth, BuddyPainter.gridHeight));
  canvas.restore();
}

Future<void> _writePng(
  String path,
  int size,
  void Function(Canvas canvas, double size) draw,
) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder), size.toDouble());
  final image = await recorder.endRecording().toImage(size, size);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}
