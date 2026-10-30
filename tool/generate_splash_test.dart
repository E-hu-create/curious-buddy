// Regenerates the Android splash images from BuddyPainter and the bundled
// font, so the splash always matches the app. Not part of the normal test
// run. Run from the project root after changing Buddy or the font:
//   flutter test tool/generate_splash_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:curious_buddy/ui/core/themes/app_colors.dart';
import 'package:curious_buddy/ui/core/widgets/buddy/buddy_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _res = 'android/app/src/main/res';
const _densities = {
  'mdpi': 1.0,
  'hdpi': 1.5,
  'xhdpi': 2.0,
  'xxhdpi': 3.0,
  'xxxhdpi': 4.0,
};

void main() {
  test('generate Android splash images', () async {
    final loader = FontLoader('SplashFont')
      ..addFont(
        Future.value(
          ByteData.view(
            File('assets/fonts/Nunito-ExtraBold.ttf').readAsBytesSync().buffer,
          ),
        ),
      );
    await loader.load();

    for (final MapEntry(key: density, value: scale) in _densities.entries) {
      final dir = '$_res/drawable-$density';
      Directory(dir).createSync(recursive: true);

      // Android 12+: 288dp canvas; only the central 192dp circle is shown.
      await _writePng('$dir/splash_icon.png', 288 * scale, 288 * scale, (
        c,
        w,
        h,
      ) {
        _sun(c, Offset(w / 2, h / 2), radius: 92 * scale);
        _buddy(c, Offset(w / 2, h / 2), height: 150 * scale);
      });

      // Android 12+: the name, at the bottom of the screen. 200 x 80dp.
      await _writePng('$dir/splash_name.png', 200 * scale, 80 * scale, (
        c,
        w,
        h,
      ) {
        _nameText(c, Offset(w / 2, h / 2), fontSize: 28 * scale);
      });

      // Android 11 and older: Buddy with the name below, centred.
      await _writePng('$dir/splash_legacy.png', 240 * scale, 240 * scale, (
        c,
        w,
        h,
      ) {
        _sun(c, Offset(w / 2, h * 0.42), radius: 96 * scale);
        _buddy(c, Offset(w / 2, h * 0.42), height: 160 * scale);
        _nameText(c, Offset(w / 2, h * 0.92), fontSize: 28 * scale);
      });
    }
  });
}

void _sun(Canvas canvas, Offset center, {required double radius}) {
  canvas.drawCircle(center, radius, Paint()..color = AppColors.sun);
}

void _buddy(Canvas canvas, Offset center, {required double height}) {
  final scale = height / BuddyPainter.gridHeight;
  canvas
    ..save()
    ..translate(center.dx, center.dy)
    ..scale(scale)
    ..translate(-BuddyPainter.gridWidth / 2, -BuddyPainter.gridHeight / 2);
  const BuddyPainter(
    mood: BuddyMood.happy,
  ).paint(canvas, const Size(BuddyPainter.gridWidth, BuddyPainter.gridHeight));
  canvas.restore();
}

void _nameText(Canvas canvas, Offset center, {required double fontSize}) {
  final builder =
      ui.ParagraphBuilder(
          ui.ParagraphStyle(fontFamily: 'SplashFont', fontSize: fontSize),
        )
        ..pushStyle(ui.TextStyle(color: AppColors.arcade))
        ..addText('Curious ')
        ..pop()
        ..pushStyle(ui.TextStyle(color: AppColors.buddyTealDeep))
        ..addText('Buddy');
  final paragraph = builder.build()
    ..layout(const ui.ParagraphConstraints(width: double.infinity));
  canvas.drawParagraph(
    paragraph,
    center - Offset(paragraph.maxIntrinsicWidth / 2, paragraph.height / 2),
  );
}

Future<void> _writePng(
  String path,
  double width,
  double height,
  void Function(Canvas canvas, double width, double height) draw,
) async {
  final recorder = ui.PictureRecorder();
  draw(Canvas(recorder), width, height);
  final image = await recorder.endRecording().toImage(
    width.round(),
    height.round(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}
