import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/stories/story.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';
import 'story_picture_more.dart';

/// A scene's picture, drawn in code in the app's flat sticker style (solid
/// fills, ink outlines), so it stays crisp and needs no image files. Each
/// story has its own look: the misty green wood, purple night-time Luma
/// and Pim's warm, sunny garden.
class StoryPicture extends StatelessWidget {
  const StoryPicture({super.key, required this.picture, this.height = 180});

  final ScenePicture picture;
  final double height;

  static String semanticLabel(ScenePicture picture) => switch (picture) {
    ScenePicture.forestGrey =>
      'A grey forest with a worried hedgehog and a faintly sparkling stream',
    ScenePicture.forestOak =>
      'A dusty crystal in a huge oak tree, with robins on a branch',
    ScenePicture.forestStream =>
      'A small waterfall with a faint rainbow in its spray and robins nearby',
    ScenePicture.forestRainbow =>
      'A bright, colourful forest under a rainbow, with a happy hedgehog',
    ScenePicture.lumaCamp =>
      'A science camp tent and radio antenna on a purple planet at night',
    ScenePicture.lumaRidge =>
      'A view from a ridge down into a crater with a tiny blinking light',
    ScenePicture.lumaCrater =>
      'A small dusty rover stuck in the sand of a crater',
    ScenePicture.lumaSignal =>
      'A happy little rover under two rising suns, flashing its light',
    ScenePicture.inventorShed =>
      'A mouse inventor with a pencil in a cosy shed full of plans',
    ScenePicture.inventorWorkshop =>
      'A workbench with a model windmill and a little pulley',
    ScenePicture.inventorHill =>
      'A windmill spinning on a windy hill, watched by a snail and ants',
    ScenePicture.inventorGarden =>
      'Tall sunflowers in a watered garden, with the mouse inventor cheering',
    _ => moreStoryPictureLabel(picture),
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel(picture),
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppShapes.radius - 4),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: StoryPicturePainter(picture)),
        ),
      ),
    );
  }
}

@visibleForTesting
class StoryPicturePainter extends CustomPainter {
  const StoryPicturePainter(this.picture);

  final ScenePicture picture;

  // Forest palette.
  static const _mist = Color(0xFFD9DEDB);
  static const _greyLeaf = Color(0xFFA7AFAB);
  static const _greyTrunk = Color(0xFF7D8380);
  static const _forestSky = Color(0xFFCDEFF4);
  static const _bark = Color(0xFF8A5A3B);
  static const _water = Color(0xFF6CC3E8);
  static const _hedgehog = Color(0xFFB0835A);
  static const _spines = Color(0xFF6B4A31);
  static const _robinBrown = Color(0xFF8E6B4E);

  // Luma palette.
  static const _lumaSky = Color(0xFF24184A);
  static const _lumaSkyHigh = Color(0xFF3A2670);
  static const _lumaGround = Color(0xFF8C6BD6);
  static const _lumaGroundDark = Color(0xFF6A4CB3);
  static const _lumaDust = Color(0xFFB9A3EE);
  static const _dawn = Color(0xFFFFB7A0);
  static const _rover = Color(0xFFE6E9F0);
  static const _panel = Color(0xFF3E6FD8);

  // Inventor palette.
  static const _wood = Color(0xFFE2B27A);
  static const _woodDark = Color(0xFFB9824D);
  static const _wall = Color(0xFFFCE3C4);
  static const _paperBlue = Color(0xFFCFE4FF);
  static const _mouse = Color(0xFFB8B3C2);
  static const _mouseEar = Color(0xFFFFB3C1);
  static const _grass = Color(0xFF7CCB6E);
  static const _gardenSky = Color(0xFFBFE7FF);
  static const _petal = Color(0xFFFFC93C);
  static const _seed = Color(0xFF7A4A21);

  static Paint _fill(Color color) => Paint()..color = color;
  static Paint _line([double width = 2.5]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..color = AppColors.ink;

  static void _shape(Canvas canvas, Path path, Color color, [double w = 2.5]) {
    canvas
      ..drawPath(path, _fill(color))
      ..drawPath(path, _line(w));
  }

  static Path _oval(Offset c, double w, double h) =>
      Path()..addOval(Rect.fromCenter(center: c, width: w, height: h));

  static Path _circle(Offset c, double r) =>
      Path()..addOval(Rect.fromCircle(center: c, radius: r));

  @override
  void paint(Canvas canvas, Size size) {
    switch (picture) {
      case ScenePicture.forestGrey:
        _forestGrey(canvas, size);
      case ScenePicture.forestOak:
        _forestOak(canvas, size);
      case ScenePicture.forestStream:
        _forestStream(canvas, size);
      case ScenePicture.forestRainbow:
        _forestRainbow(canvas, size);
      case ScenePicture.lumaCamp:
        _lumaCamp(canvas, size);
      case ScenePicture.lumaRidge:
        _lumaRidge(canvas, size);
      case ScenePicture.lumaCrater:
        _lumaCrater(canvas, size);
      case ScenePicture.lumaSignal:
        _lumaSignal(canvas, size);
      case ScenePicture.inventorShed:
        _inventorShed(canvas, size);
      case ScenePicture.inventorWorkshop:
        _inventorWorkshop(canvas, size);
      case ScenePicture.inventorHill:
        _inventorHill(canvas, size);
      case ScenePicture.inventorGarden:
        _inventorGarden(canvas, size);
      default:
        paintMoreStoryPicture(canvas, size, picture);
    }
  }

  // ============================================================ characters

  /// Fennel the hedgehog, facing right. [u] is the size unit.
  void _fennel(Canvas canvas, Offset at, double u, {required bool happy}) {
    // Spiky back.
    final spikes = Path()..moveTo(at.dx - 18 * u, at.dy + 4 * u);
    for (var i = 0; i <= 6; i++) {
      final a = math.pi + i * math.pi / 6;
      final tip = at + Offset(math.cos(a) * 22 * u, math.sin(a) * 18 * u);
      final valley =
          at + Offset(math.cos(a + 0.26) * 14 * u, math.sin(a + 0.26) * 11 * u);
      spikes
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(valley.dx, valley.dy);
    }
    spikes.close();
    _shape(canvas, spikes, _spines);
    // Body and face.
    _shape(canvas, _oval(at + Offset(2 * u, 3 * u), 34 * u, 22 * u), _hedgehog);
    final snout = Path()
      ..moveTo(at.dx + 10 * u, at.dy - 4 * u)
      ..quadraticBezierTo(
        at.dx + 26 * u,
        at.dy + 1 * u,
        at.dx + 25 * u,
        at.dy + 5 * u,
      )
      ..quadraticBezierTo(
        at.dx + 18 * u,
        at.dy + 10 * u,
        at.dx + 8 * u,
        at.dy + 9 * u,
      )
      ..close();
    _shape(canvas, snout, const Color(0xFFE8C9A4));
    canvas
      ..drawCircle(at + Offset(25 * u, 4 * u), 2.6 * u, _fill(AppColors.ink))
      ..drawCircle(at + Offset(13 * u, -1 * u), 2.4 * u, _fill(AppColors.ink))
      ..drawCircle(
        at + Offset(13.8 * u, -1.8 * u),
        0.8 * u,
        _fill(AppColors.white),
      );
    final mouth = Path();
    if (happy) {
      mouth
        ..moveTo(at.dx + 15 * u, at.dy + 6 * u)
        ..quadraticBezierTo(
          at.dx + 18 * u,
          at.dy + 9 * u,
          at.dx + 21 * u,
          at.dy + 6.5 * u,
        );
      canvas.drawCircle(
        at + Offset(9 * u, 4 * u),
        2.6 * u,
        _fill(AppColors.cheek),
      );
    } else {
      // Worried: a little wobbly line and a raised brow.
      mouth
        ..moveTo(at.dx + 15 * u, at.dy + 7.5 * u)
        ..quadraticBezierTo(
          at.dx + 18 * u,
          at.dy + 5.5 * u,
          at.dx + 21 * u,
          at.dy + 7.5 * u,
        );
      canvas.drawLine(
        at + Offset(10.5 * u, -5.5 * u),
        at + Offset(15.5 * u, -4.2 * u),
        _line(1.6 * u.clamp(1, 2)),
      );
    }
    canvas.drawPath(mouth, _line(1.6));
    // Feet.
    for (final dx in [-6.0, 8.0]) {
      _shape(
        canvas,
        _oval(at + Offset(dx * u, 14 * u), 8 * u, 4 * u),
        _spines,
        1.5,
      );
    }
  }

  /// A small robin. [facing] is 1 for right, -1 for left.
  void _robin(
    Canvas canvas,
    Offset at,
    double u, {
    double facing = 1,
    Color? body,
  }) {
    final f = facing;
    _shape(canvas, _oval(at, 16 * u, 13 * u), body ?? _robinBrown, 1.8);
    _shape(
      canvas,
      _oval(at + Offset(3 * f * u, 2 * u), 9 * u, 8 * u),
      body == null ? AppColors.coral : _mist,
      1.4,
    );
    final beak = Path()
      ..moveTo(at.dx + 7 * f * u, at.dy - 2 * u)
      ..lineTo(at.dx + 11 * f * u, at.dy - 0.8 * u)
      ..lineTo(at.dx + 7 * f * u, at.dy + 0.6 * u)
      ..close();
    _shape(canvas, beak, AppColors.sun, 1.2);
    canvas.drawCircle(
      at + Offset(4 * f * u, -3 * u),
      1.3 * u,
      _fill(AppColors.ink),
    );
    final tail = Path()
      ..moveTo(at.dx - 7 * f * u, at.dy)
      ..lineTo(at.dx - 13 * f * u, at.dy - 4 * u)
      ..lineTo(at.dx - 12 * f * u, at.dy + 2 * u)
      ..close();
    _shape(canvas, tail, body ?? _robinBrown, 1.4);
  }

  /// Dot the rover. [happy] changes its screen face and light colour.
  void _dot(
    Canvas canvas,
    Offset at,
    double u, {
    required bool happy,
    bool dusty = false,
  }) {
    // Antenna with light.
    canvas.drawLine(
      at + Offset(8 * u, -14 * u),
      at + Offset(12 * u, -28 * u),
      _line(2),
    );
    if (happy) {
      canvas.drawCircle(
        at + Offset(12 * u, -29 * u),
        7 * u,
        _fill(AppColors.sunTint.withValues(alpha: 0.5)),
      );
    }
    _shape(
      canvas,
      _circle(at + Offset(12 * u, -29 * u), 3 * u),
      happy ? AppColors.leaf : AppColors.coral,
      1.6,
    );
    // Solar panel on top.
    final panel = Path()
      ..addRect(Rect.fromLTWH(at.dx - 22 * u, at.dy - 19 * u, 26 * u, 6 * u));
    _shape(canvas, panel, dusty ? _lumaDust : _panel, 1.8);
    if (!dusty) {
      for (var i = 1; i < 4; i++) {
        final x = at.dx - 22 * u + i * 6.5 * u;
        canvas.drawLine(
          Offset(x, at.dy - 19 * u),
          Offset(x, at.dy - 13 * u),
          _line(1),
        );
      }
    }
    // Body.
    _shape(
      canvas,
      Path()..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(at.dx - 24 * u, at.dy - 13 * u, 44 * u, 22 * u),
          Radius.circular(5 * u),
        ),
      ),
      _rover,
    );
    // Screen face.
    final screen = RRect.fromRectAndRadius(
      Rect.fromLTWH(at.dx - 2 * u, at.dy - 9 * u, 18 * u, 13 * u),
      Radius.circular(3 * u),
    );
    canvas
      ..drawRRect(screen, _fill(AppColors.ink))
      ..drawRRect(screen, _line(1.6));
    final glow = _fill(happy ? AppColors.eyeGlowSoft : _lumaDust);
    if (happy) {
      for (final dx in [3.0, 11.0]) {
        final eye = Path()
          ..moveTo(at.dx + (dx - 2) * u, at.dy - 3 * u)
          ..quadraticBezierTo(
            at.dx + dx * u,
            at.dy - 6 * u,
            at.dx + (dx + 2) * u,
            at.dy - 3 * u,
          );
        canvas.drawPath(
          eye,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8 * u
            ..strokeCap = StrokeCap.round
            ..color = AppColors.eyeGlowSoft,
        );
      }
      final smile = Path()
        ..moveTo(at.dx + 4 * u, at.dy)
        ..quadraticBezierTo(
          at.dx + 7 * u,
          at.dy + 2.5 * u,
          at.dx + 10 * u,
          at.dy,
        );
      canvas.drawPath(
        smile,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 * u
          ..strokeCap = StrokeCap.round
          ..color = AppColors.eyeGlowSoft,
      );
    } else {
      canvas
        ..drawCircle(at + Offset(3.5 * u, -3 * u), 1.6 * u, glow)
        ..drawCircle(at + Offset(10.5 * u, -3 * u), 1.6 * u, glow)
        ..drawLine(
          at + Offset(5 * u, 1 * u),
          at + Offset(9 * u, 1 * u),
          Paint()
            ..strokeWidth = 1.2 * u
            ..strokeCap = StrokeCap.round
            ..color = _lumaDust,
        );
    }
    // Wheels.
    for (final dx in [-16.0, 0.0, 14.0]) {
      _shape(
        canvas,
        _circle(at + Offset(dx * u, 11 * u), 5.5 * u),
        AppColors.inkSoft,
        1.8,
      );
      canvas.drawCircle(at + Offset(dx * u, 11 * u), 2 * u, _fill(_rover));
    }
  }

  /// Pim the mouse inventor, facing right, with goggles on her head.
  void _pim(
    Canvas canvas,
    Offset at,
    double u, {
    required bool happy,
    bool armsUp = false,
  }) {
    // Tail.
    final tail = Path()
      ..moveTo(at.dx - 10 * u, at.dy + 12 * u)
      ..cubicTo(
        at.dx - 26 * u,
        at.dy + 16 * u,
        at.dx - 28 * u,
        at.dy,
        at.dx - 20 * u,
        at.dy - 2 * u,
      );
    canvas.drawPath(tail, _line(2.2));
    // Body.
    _shape(canvas, _oval(at + Offset(0, 6 * u), 22 * u, 26 * u), _mouse);
    // Arms.
    final arm = _line(2.4);
    if (armsUp) {
      canvas
        ..drawLine(
          at + Offset(-8 * u, 2 * u),
          at + Offset(-14 * u, -10 * u),
          arm,
        )
        ..drawLine(
          at + Offset(8 * u, 2 * u),
          at + Offset(14 * u, -10 * u),
          arm,
        );
    } else {
      // Holding a pencil.
      canvas.drawLine(at + Offset(8 * u, 4 * u), at + Offset(15 * u, 0), arm);
      final pencil = Path()
        ..moveTo(at.dx + 13 * u, at.dy + 4 * u)
        ..lineTo(at.dx + 19 * u, at.dy - 9 * u)
        ..lineTo(at.dx + 21.5 * u, at.dy - 8 * u)
        ..lineTo(at.dx + 15.5 * u, at.dy + 5 * u)
        ..close();
      _shape(canvas, pencil, AppColors.sun, 1.4);
    }
    // Ears.
    for (final dx in [-9.0, 9.0]) {
      _shape(canvas, _circle(at + Offset(dx * u, -15 * u), 7 * u), _mouse, 2);
      canvas.drawCircle(at + Offset(dx * u, -15 * u), 4 * u, _fill(_mouseEar));
    }
    // Head.
    _shape(canvas, _oval(at + Offset(0, -6 * u), 20 * u, 17 * u), _mouse);
    // Goggles pushed up.
    canvas.drawLine(
      at + Offset(-9 * u, -11 * u),
      at + Offset(9 * u, -11 * u),
      _line(2),
    );
    for (final dx in [-4.0, 4.0]) {
      _shape(
        canvas,
        _circle(at + Offset(dx * u, -11.5 * u), 3.4 * u),
        _paperBlue,
        1.6,
      );
    }
    // Eyes, nose, whiskers, mouth.
    for (final dx in [-3.5, 3.5]) {
      canvas
        ..drawCircle(at + Offset(dx * u, -5 * u), 1.8 * u, _fill(AppColors.ink))
        ..drawCircle(
          at + Offset((dx + 0.6) * u, -5.6 * u),
          0.6 * u,
          _fill(AppColors.white),
        );
    }
    canvas.drawCircle(at + Offset(0, -1.5 * u), 1.6 * u, _fill(_mouseEar));
    for (final s in [-1.0, 1.0]) {
      canvas
        ..drawLine(
          at + Offset(3 * s * u, -1 * u),
          at + Offset(11 * s * u, -3 * u),
          _line(1),
        )
        ..drawLine(
          at + Offset(3 * s * u, 0),
          at + Offset(11 * s * u, 1 * u),
          _line(1),
        );
    }
    final mouth = Path()..moveTo(at.dx - 2 * u, at.dy + 0.5 * u);
    if (happy) {
      mouth.quadraticBezierTo(
        at.dx,
        at.dy + 3.5 * u,
        at.dx + 2 * u,
        at.dy + 0.5 * u,
      );
    } else {
      mouth.lineTo(at.dx + 2 * u, at.dy + 1 * u);
    }
    canvas.drawPath(mouth, _line(1.3));
    // Feet.
    for (final dx in [-5.0, 5.0]) {
      _shape(
        canvas,
        _oval(at + Offset(dx * u, 19 * u), 8 * u, 4 * u),
        _mouseEar,
        1.4,
      );
    }
  }

  // ============================================================== scenery

  void _sky(Canvas canvas, Size size, Color color) =>
      canvas.drawRect(Offset.zero & size, _fill(color));

  void _ground(Canvas canvas, Size size, double top, Color color) {
    final path = Path()
      ..moveTo(-4, top)
      ..quadraticBezierTo(
        size.width * 0.5,
        top - size.height * 0.06,
        size.width + 4,
        top + 4,
      )
      ..lineTo(size.width + 4, size.height + 4)
      ..lineTo(-4, size.height + 4)
      ..close();
    _shape(canvas, path, color);
  }

  void _tree(
    Canvas canvas,
    Offset base,
    double u, {
    required Color leaf,
    required Color trunk,
  }) {
    _shape(
      canvas,
      Path()..addRect(
        Rect.fromLTWH(base.dx - 4 * u, base.dy - 30 * u, 8 * u, 30 * u),
      ),
      trunk,
    );
    _shape(canvas, _circle(base + Offset(-8 * u, -36 * u), 13 * u), leaf);
    _shape(canvas, _circle(base + Offset(9 * u, -38 * u), 14 * u), leaf);
    _shape(canvas, _circle(base + Offset(0, -50 * u), 15 * u), leaf);
  }

  void _flower(Canvas canvas, Offset base, double u, Color petal) {
    canvas.drawLine(base, base + Offset(0, -12 * u), _line(2));
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5;
      _shape(
        canvas,
        _circle(
          base + Offset(math.cos(a) * 4 * u, -14 * u + math.sin(a) * 4 * u),
          3 * u,
        ),
        petal,
        1.2,
      );
    }
    _shape(
      canvas,
      _circle(base + Offset(0, -14 * u), 2.4 * u),
      AppColors.sun,
      1.2,
    );
  }

  void _stars(Canvas canvas, Size size, int seed, {double maxY = 0.6}) {
    final random = math.Random(seed);
    final star = _fill(AppColors.sunTint);
    for (var i = 0; i < 22; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height * maxY,
        ),
        0.9 + random.nextDouble() * 1.5,
        star,
      );
    }
  }

  void _rainbow(
    Canvas canvas,
    Offset center,
    double radius,
    double band, {
    double alpha = 1,
  }) {
    const colours = [
      Color(0xFFFF6B6B),
      Color(0xFFFFA94D),
      Color(0xFFFFD43B),
      Color(0xFF69DB7C),
      Color(0xFF4DABF7),
      Color(0xFF9775FA),
    ];
    for (final (i, colour) in colours.indexed) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - i * band),
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = band
          ..color = colour.withValues(alpha: alpha),
      );
    }
  }

  void _crystal(Canvas canvas, Offset c, double u, {required bool dusty}) {
    if (!dusty) {
      canvas.drawCircle(
        c,
        16 * u,
        _fill(AppColors.sunTint.withValues(alpha: 0.6)),
      );
    }
    final gem = Path()
      ..moveTo(c.dx, c.dy - 11 * u)
      ..lineTo(c.dx + 8 * u, c.dy - 3 * u)
      ..lineTo(c.dx + 5 * u, c.dy + 10 * u)
      ..lineTo(c.dx - 5 * u, c.dy + 10 * u)
      ..lineTo(c.dx - 8 * u, c.dy - 3 * u)
      ..close();
    _shape(canvas, gem, dusty ? const Color(0xFFC9CBC4) : AppColors.buddyBelly);
    canvas.drawLine(
      c + Offset(-8 * u, -3 * u),
      c + Offset(8 * u, -3 * u),
      _line(1.4),
    );
    canvas.drawLine(c + Offset(0, -11 * u), c + Offset(0, 10 * u), _line(1.2));
    if (dusty) {
      final speck = _fill(const Color(0xFF8E918A));
      for (final o in [
        const Offset(-3, 2),
        const Offset(3, 5),
        const Offset(-1, -5),
        const Offset(4, -1),
      ]) {
        canvas.drawCircle(c + o * u, 1.1 * u, speck);
      }
    }
  }

  // ============================================================== forest

  void _forestGrey(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _sky(canvas, size, _mist);
    _shape(
      canvas,
      _circle(Offset(w * 0.82, h * 0.2), 9 * u),
      const Color(0xFFEDEFEA),
    );
    _tree(
      canvas,
      Offset(w * 0.12, h * 0.74),
      u,
      leaf: _greyLeaf,
      trunk: _greyTrunk,
    );
    _tree(
      canvas,
      Offset(w * 0.88, h * 0.76),
      u * 0.9,
      leaf: _greyLeaf,
      trunk: _greyTrunk,
    );
    // Hill with the old oak far away.
    _shape(
      canvas,
      _oval(Offset(w * 0.62, h * 0.72), w * 0.5, h * 0.5),
      const Color(0xFFBCC2BE),
    );
    _tree(
      canvas,
      Offset(w * 0.62, h * 0.5),
      u * 0.5,
      leaf: _greyLeaf,
      trunk: _greyTrunk,
    );
    _ground(canvas, size, h * 0.76, const Color(0xFF9DA49F));
    // The stream, with a faint sparkle.
    final stream = Path()
      ..moveTo(w * 0.55, h * 0.78)
      ..quadraticBezierTo(w * 0.7, h * 0.88, w * 1.02, h * 0.86)
      ..lineTo(w * 1.02, h * 0.95)
      ..quadraticBezierTo(w * 0.66, h * 0.98, w * 0.48, h * 0.82)
      ..close();
    _shape(canvas, stream, const Color(0xFFB9CBD2));
    _sparkle(canvas, Offset(w * 0.78, h * 0.89), 3 * u);
    // Grey flowers and a grey butterfly.
    for (final x in [0.3, 0.38]) {
      _flower(canvas, Offset(w * x, h * 0.92), u, _greyLeaf);
    }
    _butterfly(canvas, Offset(w * 0.46, h * 0.3), u, const Color(0xFFBFC4C0));
    _fennel(canvas, Offset(w * 0.24, h * 0.76), u * 0.9, happy: false);
  }

  void _sparkle(Canvas canvas, Offset c, double r) {
    final star = Path()
      ..moveTo(c.dx, c.dy - r * 2)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r * 2, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r * 2)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r * 2, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r * 2)
      ..close();
    _shape(canvas, star, AppColors.white, 1.4);
  }

  void _butterfly(Canvas canvas, Offset c, double u, Color wing) {
    _shape(canvas, _oval(c + Offset(-5 * u, -3 * u), 9 * u, 11 * u), wing, 1.4);
    _shape(canvas, _oval(c + Offset(5 * u, -3 * u), 9 * u, 11 * u), wing, 1.4);
    _shape(canvas, _oval(c + Offset(-4 * u, 4 * u), 6 * u, 7 * u), wing, 1.4);
    _shape(canvas, _oval(c + Offset(4 * u, 4 * u), 6 * u, 7 * u), wing, 1.4);
    canvas.drawLine(c + Offset(0, -6 * u), c + Offset(0, 7 * u), _line(2));
  }

  void _forestOak(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _sky(canvas, size, const Color(0xFFDDE7E2));
    // Wind swirls.
    final wind = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.white;
    for (final (x, y) in [(0.08, 0.2), (0.14, 0.42), (0.78, 0.14)]) {
      final swirl = Path()
        ..moveTo(w * x, h * y)
        ..cubicTo(
          w * x + 30 * u,
          h * y - 6 * u,
          w * x + 34 * u,
          h * y + 8 * u,
          w * x + 22 * u,
          h * y + 6 * u,
        );
      canvas.drawPath(swirl, wind);
    }
    // The big trunk and canopy.
    final trunk = Path()
      ..moveTo(w * 0.46, h + 4)
      ..lineTo(w * 0.5, h * 0.42)
      ..lineTo(w * 0.6, h * 0.42)
      ..lineTo(w * 0.64, h + 4)
      ..close();
    _shape(canvas, trunk, _bark);
    for (final (x, y, r) in [
      (0.36, 0.3, 20.0),
      (0.56, 0.18, 24.0),
      (0.76, 0.3, 20.0),
      (0.47, 0.06, 16.0),
      (0.66, 0.06, 16.0),
    ]) {
      _shape(
        canvas,
        _circle(Offset(w * x, h * y), r * u),
        const Color(0xFF8FB596),
      );
    }
    // A branch holding the crystal and robins.
    final branch = Path()
      ..moveTo(w * 0.6, h * 0.55)
      ..lineTo(w * 0.9, h * 0.5)
      ..lineTo(w * 0.9, h * 0.55)
      ..lineTo(w * 0.6, h * 0.62)
      ..close();
    _shape(canvas, branch, _bark);
    _crystal(canvas, Offset(w * 0.54, h * 0.46), u * 1.3, dusty: true);
    _robin(canvas, Offset(w * 0.76, h * 0.47), u * 0.9, facing: -1);
    _robin(canvas, Offset(w * 0.86, h * 0.45), u * 0.8, facing: -1);
    // Fennel peeking from the lower branch.
    final low = Path()
      ..moveTo(w * 0.5, h * 0.8)
      ..lineTo(w * 0.14, h * 0.86)
      ..lineTo(w * 0.14, h * 0.92)
      ..lineTo(w * 0.5, h * 0.88)
      ..close();
    _shape(canvas, low, _bark);
    _fennel(canvas, Offset(w * 0.28, h * 0.74), u * 0.75, happy: false);
  }

  void _forestStream(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _sky(canvas, size, const Color(0xFFE2EAE4));
    _tree(
      canvas,
      Offset(w * 0.1, h * 0.62),
      u * 0.9,
      leaf: _greyLeaf,
      trunk: _greyTrunk,
    );
    // Rocks and the little waterfall.
    _shape(
      canvas,
      Path()..addRRect(
        RRect.fromLTRBR(
          w * 0.52,
          h * 0.28,
          w * 0.98,
          h * 0.62,
          Radius.circular(10 * u),
        ),
      ),
      const Color(0xFFA9AFA8),
    );
    final fall = Path()
      ..addRect(Rect.fromLTWH(w * 0.62, h * 0.32, w * 0.12, h * 0.4));
    _shape(canvas, fall, _water);
    _rainbow(canvas, Offset(w * 0.68, h * 0.78), 22 * u, 2.4 * u, alpha: 0.75);
    // Spray.
    for (var i = 0; i < 9; i++) {
      canvas.drawCircle(
        Offset(w * (0.58 + i * 0.025), h * (0.72 + (i % 3) * 0.03)),
        2.4 * u,
        _fill(AppColors.white.withValues(alpha: 0.85)),
      );
    }
    _ground(canvas, size, h * 0.7, const Color(0xFFA3B29F));
    final pool = _oval(Offset(w * 0.64, h * 0.86), w * 0.6, h * 0.22);
    _shape(canvas, pool, _water);
    for (final x in [0.52, 0.78]) {
      _sparkle(canvas, Offset(w * x, h * 0.86), 2.4 * u);
    }
    _robin(canvas, Offset(w * 0.44, h * 0.84), u, facing: 1);
    _robin(canvas, Offset(w * 0.86, h * 0.84), u * 0.9, facing: -1);
    // Fennel on a stepping stone.
    _shape(
      canvas,
      _oval(Offset(w * 0.22, h * 0.9), 40 * u, 12 * u),
      const Color(0xFF9CA29B),
    );
    _fennel(canvas, Offset(w * 0.22, h * 0.76), u * 0.85, happy: true);
  }

  void _forestRainbow(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _sky(canvas, size, _forestSky);
    _shape(canvas, _circle(Offset(w * 0.88, h * 0.18), 10 * u), AppColors.sun);
    _rainbow(
      canvas,
      Offset(w * 0.5, h * 0.82),
      math.min(w * 0.42, 70 * u),
      4.5 * u,
    );
    _tree(
      canvas,
      Offset(w * 0.1, h * 0.78),
      u,
      leaf: AppColors.leaf,
      trunk: _bark,
    );
    _tree(
      canvas,
      Offset(w * 0.9, h * 0.8),
      u * 0.9,
      leaf: const Color(0xFF52C48A),
      trunk: _bark,
    );
    _ground(canvas, size, h * 0.78, const Color(0xFF8FD694));
    for (final (x, c) in [
      (0.3, AppColors.coral),
      (0.38, AppColors.grape),
      (0.62, AppColors.brandBlue),
      (0.7, const Color(0xFFFF6B9A)),
      (0.78, AppColors.sun),
    ]) {
      _flower(canvas, Offset(w * x, h * 0.95), u, c);
    }
    _butterfly(canvas, Offset(w * 0.3, h * 0.3), u, AppColors.coral);
    _butterfly(
      canvas,
      Offset(w * 0.72, h * 0.34),
      u * 0.8,
      AppColors.brandBlue,
    );
    _robin(canvas, Offset(w * 0.86, h * 0.44), u * 0.9, facing: -1);
    _fennel(canvas, Offset(w * 0.5, h * 0.8), u, happy: true);
  }

  // ================================================================ luma

  void _lumaNight(Canvas canvas, Size size, int seed) {
    _sky(canvas, size, _lumaSky);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.3),
      _fill(_lumaSkyHigh.withValues(alpha: 0.6)),
    );
    _stars(canvas, size, seed);
  }

  void _waves(
    Canvas canvas,
    Offset from,
    double u, {
    int count = 3,
    Color? color,
  }) {
    for (var i = 1; i <= count; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: from, radius: i * 7 * u),
        -math.pi * 0.8,
        math.pi * 0.6,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..color = color ?? AppColors.eyeGlowSoft,
      );
    }
  }

  void _lumaCamp(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _lumaNight(canvas, size, 11);
    // A ringed moon.
    _shape(
      canvas,
      _circle(Offset(w * 0.18, h * 0.22), 9 * u),
      const Color(0xFFF7C6E0),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.18, h * 0.22),
        width: 32 * u,
        height: 7 * u,
      ),
      _line(2)..color = AppColors.sunTint,
    );
    // Glow Ridge behind.
    final ridge = Path()
      ..moveTo(-4, h * 0.7)
      ..lineTo(w * 0.3, h * 0.36)
      ..lineTo(w * 0.5, h * 0.52)
      ..lineTo(w * 0.7, h * 0.3)
      ..lineTo(w + 4, h * 0.62)
      ..lineTo(w + 4, h)
      ..lineTo(-4, h)
      ..close();
    _shape(canvas, ridge, _lumaGroundDark);
    _ground(canvas, size, h * 0.74, _lumaGround);
    // Dome tent with a lit window.
    final tent = Path()
      ..moveTo(w * 0.22, h * 0.82)
      ..quadraticBezierTo(w * 0.36, h * 0.38, w * 0.5, h * 0.82)
      ..close();
    _shape(canvas, tent, AppColors.coralTint);
    _shape(
      canvas,
      _oval(Offset(w * 0.36, h * 0.68), 14 * u, 16 * u),
      AppColors.sun,
    );
    // Radio antenna with signal waves.
    final mast = Offset(w * 0.68, h * 0.8);
    canvas.drawLine(mast, mast + Offset(0, -36 * u), _line(3));
    final dish = Path()
      ..moveTo(mast.dx - 12 * u, mast.dy - 40 * u)
      ..quadraticBezierTo(
        mast.dx,
        mast.dy - 28 * u,
        mast.dx + 12 * u,
        mast.dy - 40 * u,
      )
      ..close();
    _shape(canvas, dish, _rover);
    _waves(canvas, mast + Offset(0, -42 * u), u);
    // The radio box on a crate.
    _shape(
      canvas,
      Path()..addRRect(
        RRect.fromLTRBR(
          w * 0.76,
          h * 0.7,
          w * 0.9,
          h * 0.84,
          Radius.circular(3 * u),
        ),
      ),
      _rover,
    );
    canvas.drawCircle(Offset(w * 0.8, h * 0.77), 3 * u, _fill(AppColors.coral));
    for (var i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(w * 0.83, h * (0.74 + i * 0.03)),
        Offset(w * 0.88, h * (0.74 + i * 0.03)),
        _line(1.4),
      );
    }
  }

  void _lumaRidge(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _lumaNight(canvas, size, 23);
    // The crater far below.
    _shape(
      canvas,
      _oval(Offset(w * 0.6, h * 0.66), w * 0.7, h * 0.34),
      _lumaGroundDark,
    );
    _shape(
      canvas,
      _oval(Offset(w * 0.6, h * 0.68), w * 0.46, h * 0.18),
      const Color(0xFF543A99),
    );
    final light = Offset(w * 0.6, h * 0.67);
    canvas.drawCircle(
      light,
      8 * u,
      _fill(AppColors.coral.withValues(alpha: 0.35)),
    );
    _shape(canvas, _circle(light, 2.6 * u), AppColors.coral, 1.4);
    _waves(canvas, light, u * 0.9, color: AppColors.coralTint);
    // The ridge you stand on, with a torch beam.
    final ledge = Path()
      ..moveTo(-4, h * 0.78)
      ..lineTo(w * 0.34, h * 0.86)
      ..lineTo(w * 0.42, h + 4)
      ..lineTo(-4, h + 4)
      ..close();
    _shape(canvas, ledge, _lumaGround);
    final beam = Path()
      ..moveTo(w * 0.2, h * 0.76)
      ..lineTo(w * 0.56, h * 0.62)
      ..lineTo(w * 0.6, h * 0.72)
      ..close();
    canvas.drawPath(beam, _fill(AppColors.sunTint.withValues(alpha: 0.45)));
    // The torch.
    final torch = Path()
      ..addRRect(
        RRect.fromLTRBR(
          w * 0.12,
          h * 0.74,
          w * 0.21,
          h * 0.8,
          Radius.circular(2 * u),
        ),
      );
    _shape(canvas, torch, AppColors.sun, 2);
  }

  void _lumaCrater(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _lumaNight(canvas, size, 37);
    // Crater walls.
    final wall = Path()
      ..moveTo(-4, h * 0.4)
      ..quadraticBezierTo(w * 0.5, h * 0.56, w + 4, h * 0.4)
      ..lineTo(w + 4, h + 4)
      ..lineTo(-4, h + 4)
      ..close();
    _shape(canvas, wall, _lumaGroundDark);
    _shape(
      canvas,
      _oval(Offset(w * 0.5, h * 0.86), w * 0.9, h * 0.4),
      _lumaGround,
    );
    // Sand heaped round a wheel.
    final dot = Offset(w * 0.5, h * 0.72);
    _dot(canvas, dot, u * 1.2, happy: false, dusty: true);
    _shape(
      canvas,
      _oval(dot + Offset(-18 * u, 15 * u), 24 * u, 9 * u),
      _lumaDust,
    );
    // Old rocks.
    for (final (x, r) in [(0.15, 7.0), (0.84, 9.0), (0.74, 5.0)]) {
      _shape(
        canvas,
        _oval(Offset(w * x, h * 0.84), r * 2.4 * u, r * 1.4 * u),
        _lumaDust,
      );
    }
  }

  void _lumaSignal(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _sky(canvas, size, _lumaSkyHigh);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.4, w, h * 0.6), _fill(_dawn));
    _stars(canvas, size, 41, maxY: 0.3);
    // Two suns rising.
    _shape(canvas, _circle(Offset(w * 0.2, h * 0.62), 12 * u), AppColors.sun);
    _shape(
      canvas,
      _circle(Offset(w * 0.82, h * 0.58), 8 * u),
      const Color(0xFFFF9F68),
    );
    _ground(canvas, size, h * 0.7, _lumaGround);
    // Dot, flashing happily.
    final dot = Offset(w * 0.52, h * 0.76);
    final light = dot + Offset(12 * u * 1.2, -29 * u * 1.2);
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      canvas.drawLine(
        light + Offset(math.cos(a), math.sin(a)) * 9 * u,
        light + Offset(math.cos(a), math.sin(a)) * 14 * u,
        Paint()
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = AppColors.sunTint,
      );
    }
    _dot(canvas, dot, u * 1.2, happy: true);
    // Little musical beeps.
    for (final (x, y) in [(0.74, 0.42), (0.8, 0.3)]) {
      _shape(
        canvas,
        _circle(Offset(w * x, h * y), 2.6 * u),
        AppColors.eyeGlowSoft,
        1.4,
      );
      canvas.drawLine(
        Offset(w * x + 2.6 * u, h * y),
        Offset(w * x + 2.6 * u, h * y - 9 * u),
        _line(1.6),
      );
    }
  }

  // ============================================================ inventor

  void _sunflower(
    Canvas canvas,
    Offset base,
    double u, {
    required bool droopy,
    double tall = 1,
  }) {
    final top = droopy
        ? base + Offset(10 * u, -30 * u * tall)
        : base + Offset(0, -40 * u * tall);
    final stem = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx,
        top.dy + (droopy ? -6 * u : 10 * u),
        top.dx,
        top.dy,
      );
    canvas.drawPath(
      stem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * u.clamp(0.6, 1.4)
        ..strokeCap = StrokeCap.round
        ..color = droopy ? const Color(0xFFB7A43A) : AppColors.leaf,
    );
    final leaf = _oval(base + Offset(6 * u, -14 * u * tall), 12 * u, 5 * u);
    _shape(
      canvas,
      leaf,
      droopy ? const Color(0xFFC7B85A) : AppColors.leaf,
      1.4,
    );
    final petals = Path();
    for (var i = 0; i < 10; i++) {
      final a = i * math.pi / 5;
      petals.addOval(
        Rect.fromCircle(
          center: top + Offset(math.cos(a), math.sin(a)) * 7 * u,
          radius: 3.6 * u,
        ),
      );
    }
    _shape(canvas, petals, droopy ? const Color(0xFFE5C46A) : _petal, 1.4);
    _shape(canvas, _circle(top, 5 * u), _seed, 1.6);
  }

  void _windmill(
    Canvas canvas,
    Offset hub,
    double u, {
    double turn = 0.3,
    bool spinning = false,
  }) {
    canvas.drawLine(hub, hub + Offset(-6 * u, 30 * u), _line(2.6));
    canvas.drawLine(hub, hub + Offset(6 * u, 30 * u), _line(2.6));
    for (var i = 0; i < 4; i++) {
      final a = turn + i * math.pi / 2;
      final tip = hub + Offset(math.cos(a), math.sin(a)) * 18 * u;
      final side =
          hub + Offset(math.cos(a + 0.35), math.sin(a + 0.35)) * 15 * u;
      final blade = Path()
        ..moveTo(hub.dx, hub.dy)
        ..lineTo(tip.dx, tip.dy)
        ..lineTo(side.dx, side.dy)
        ..close();
      _shape(canvas, blade, i.isEven ? AppColors.coral : AppColors.white, 1.6);
    }
    _shape(canvas, _circle(hub, 2.6 * u), AppColors.sun, 1.4);
    if (spinning) {
      canvas.drawArc(
        Rect.fromCircle(center: hub, radius: 23 * u),
        -0.6,
        1.4,
        false,
        _line(1.6),
      );
      canvas.drawArc(
        Rect.fromCircle(center: hub, radius: 23 * u),
        math.pi - 0.6,
        1.4,
        false,
        _line(1.6),
      );
    }
  }

  void _pulley(Canvas canvas, Offset top, double u, {bool bucketUp = false}) {
    canvas.drawLine(
      top + Offset(-14 * u, 0),
      top + Offset(14 * u, 0),
      _line(3),
    );
    _shape(canvas, _circle(top + Offset(0, 6 * u), 6 * u), _woodDark, 1.8);
    canvas.drawCircle(top + Offset(0, 6 * u), 1.6 * u, _fill(AppColors.ink));
    final bucketY = bucketUp ? 18.0 : 30.0;
    canvas
      ..drawLine(
        top + Offset(-6 * u, 6 * u),
        top + Offset(-6 * u, bucketY * u),
        _line(1.4),
      )
      ..drawLine(
        top + Offset(6 * u, 6 * u),
        top + Offset(6 * u, 30 * u),
        _line(1.4),
      );
    final bucket = Path()
      ..moveTo(top.dx - 12 * u, top.dy + bucketY * u)
      ..lineTo(top.dx - 1 * u, top.dy + bucketY * u)
      ..lineTo(top.dx - 3 * u, top.dy + (bucketY + 9) * u)
      ..lineTo(top.dx - 10 * u, top.dy + (bucketY + 9) * u)
      ..close();
    _shape(canvas, bucket, const Color(0xFFC9CED8), 1.6);
  }

  void _inventorShed(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _sky(canvas, size, _wall);
    // Wall planks.
    for (var i = 1; i < 6; i++) {
      canvas.drawLine(
        Offset(w * i / 6, 0),
        Offset(w * i / 6, h * 0.7),
        _line(1)..color = _wood,
      );
    }
    // Window with a drooping sunflower outside.
    final window = Rect.fromLTWH(w * 0.62, h * 0.1, w * 0.3, h * 0.42);
    canvas
      ..drawRect(window, _fill(_gardenSky))
      ..save()
      ..clipRect(window);
    _sunflower(canvas, Offset(w * 0.76, h * 0.56), u * 0.8, droopy: true);
    _shape(canvas, _circle(Offset(w * 0.88, h * 0.16), 6 * u), AppColors.sun);
    canvas.restore();
    canvas
      ..drawRect(window, _line(3))
      ..drawLine(
        Offset(window.center.dx, window.top),
        Offset(window.center.dx, window.bottom),
        _line(2),
      )
      ..drawLine(
        Offset(window.left, window.center.dy),
        Offset(window.right, window.center.dy),
        _line(2),
      );
    // Two plans pinned to the wall.
    final plan1 = Path()
      ..addRect(Rect.fromLTWH(w * 0.08, h * 0.1, w * 0.2, h * 0.3));
    final plan2 = Path()
      ..addRect(Rect.fromLTWH(w * 0.32, h * 0.14, w * 0.2, h * 0.3));
    _shape(canvas, plan1, _paperBlue, 2);
    _shape(canvas, plan2, _paperBlue, 2);
    _windmill(canvas, Offset(w * 0.18, h * 0.21), u * 0.38);
    _pulley(canvas, Offset(w * 0.42, h * 0.18), u * 0.5);
    for (final x in [0.18, 0.42]) {
      canvas.drawCircle(
        Offset(w * x, h * (x < 0.3 ? 0.12 : 0.16)),
        1.8 * u,
        _fill(AppColors.coral),
      );
    }
    // Floor and Pim.
    _shape(
      canvas,
      Path()..addRect(Rect.fromLTWH(-4, h * 0.7, w + 8, h * 0.34)),
      _wood,
    );
    _pim(canvas, Offset(w * 0.34, h * 0.68), u * 1.2, happy: true);
    // A watering can, empty.
    final can = Path()
      ..addRRect(
        RRect.fromLTRBR(
          w * 0.62,
          h * 0.72,
          w * 0.74,
          h * 0.88,
          Radius.circular(3 * u),
        ),
      );
    _shape(canvas, can, AppColors.brandBlue);
    canvas.drawLine(
      Offset(w * 0.74, h * 0.76),
      Offset(w * 0.82, h * 0.68),
      _line(3),
    );
  }

  void _inventorWorkshop(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _sky(canvas, size, const Color(0xFFFFE9CF));
    // Pegboard of tools.
    for (final (x, y) in [(0.1, 0.16), (0.2, 0.12), (0.84, 0.14)]) {
      _shape(
        canvas,
        Path()..addRRect(
          RRect.fromLTRBR(
            w * x,
            h * y,
            w * x + 7 * u,
            h * y + 22 * u,
            Radius.circular(2 * u),
          ),
        ),
        _woodDark,
        1.8,
      );
    }
    final gear = Path();
    for (var i = 0; i < 8; i++) {
      final a = i * math.pi / 4;
      gear.addRect(
        Rect.fromCenter(
          center:
              Offset(w * 0.7, h * 0.22) +
              Offset(math.cos(a), math.sin(a)) * 9 * u,
          width: 4 * u,
          height: 4 * u,
        ),
      );
    }
    gear.addOval(
      Rect.fromCircle(center: Offset(w * 0.7, h * 0.22), radius: 9 * u),
    );
    _shape(canvas, gear, const Color(0xFFC9CED8), 1.6);
    canvas.drawCircle(
      Offset(w * 0.7, h * 0.22),
      3 * u,
      _fill(const Color(0xFFFFE9CF)),
    );
    // Workbench.
    _shape(
      canvas,
      Path()..addRect(Rect.fromLTWH(-4, h * 0.62, w + 8, h * 0.1)),
      _woodDark,
    );
    _shape(
      canvas,
      Path()..addRect(Rect.fromLTWH(-4, h * 0.72, w + 8, h * 0.32)),
      _wood,
    );
    // Model windmill and pulley on the bench.
    _windmill(canvas, Offset(w * 0.22, h * 0.3), u);
    _shape(
      canvas,
      Path()..addRect(Rect.fromLTWH(w * 0.5, h * 0.24, 4 * u, h * 0.38)),
      _woodDark,
      1.8,
    );
    _pulley(canvas, Offset(w * 0.5 + 2 * u, h * 0.26), u * 0.9);
    // A cork, string and card scraps.
    _shape(
      canvas,
      _oval(Offset(w * 0.38, h * 0.6), 10 * u, 6 * u),
      const Color(0xFFD9A066),
      1.6,
    );
    final card = Path()
      ..moveTo(w * 0.62, h * 0.62)
      ..lineTo(w * 0.66, h * 0.55)
      ..lineTo(w * 0.7, h * 0.62)
      ..close();
    _shape(canvas, card, AppColors.coralTint, 1.6);
    _pim(canvas, Offset(w * 0.84, h * 0.6), u * 1.05, happy: true);
  }

  void _inventorHill(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _sky(canvas, size, _gardenSky);
    for (final (x, y) in [(0.2, 0.18), (0.62, 0.12)]) {
      final cloud = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(w * x, h * y),
            width: 30 * u,
            height: 12 * u,
          ),
        )
        ..addOval(
          Rect.fromCenter(
            center: Offset(w * x + 9 * u, h * y - 4 * u),
            width: 18 * u,
            height: 12 * u,
          ),
        );
      _shape(canvas, cloud, AppColors.white, 1.8);
    }
    // Gust lines.
    for (final y in [0.32, 0.42, 0.52]) {
      canvas.drawLine(
        Offset(w * 0.04, h * y),
        Offset(w * 0.26, h * y),
        _line(1.8)..color = AppColors.white,
      );
    }
    final hill = Path()
      ..moveTo(-4, h * 0.9)
      ..quadraticBezierTo(w * 0.5, h * 0.3, w + 4, h * 0.9)
      ..lineTo(w + 4, h + 4)
      ..lineTo(-4, h + 4)
      ..close();
    _shape(canvas, hill, _grass);
    _windmill(
      canvas,
      Offset(w * 0.5, h * 0.3),
      u * 1.1,
      turn: 0.9,
      spinning: true,
    );
    // Water gushing into a trough.
    _shape(
      canvas,
      Path()..addRect(Rect.fromLTWH(w * 0.56, h * 0.62, 16 * u, 6 * u)),
      _woodDark,
      1.8,
    );
    canvas.drawLine(
      Offset(w * 0.54, h * 0.6),
      Offset(w * 0.6, h * 0.63),
      _line(4)..color = AppColors.brandBlue,
    );
    // The snail and ants watching.
    final snail = Offset(w * 0.76, h * 0.74);
    _shape(
      canvas,
      _oval(snail + Offset(4 * u, 4 * u), 20 * u, 6 * u),
      const Color(0xFFE8C9A4),
      1.8,
    );
    _shape(canvas, _circle(snail, 7 * u), AppColors.coral, 1.8);
    canvas.drawArc(
      Rect.fromCircle(center: snail, radius: 3.5 * u),
      0,
      math.pi * 1.5,
      false,
      _line(1.4),
    );
    canvas
      ..drawLine(
        snail + Offset(12 * u, 2 * u),
        snail + Offset(14 * u, -4 * u),
        _line(1.4),
      )
      ..drawCircle(
        snail + Offset(14 * u, -4.5 * u),
        1.4 * u,
        _fill(AppColors.ink),
      );
    for (final x in [0.26, 0.31, 0.36]) {
      final ant = Offset(w * x, h * 0.78);
      for (final dx in [-3.0, 0.0, 3.0]) {
        canvas.drawCircle(
          ant + Offset(dx * u, 0),
          1.8 * u,
          _fill(AppColors.ink),
        );
      }
    }
  }

  void _inventorGarden(Canvas canvas, Size size) {
    final w = size.width, h = size.height, u = h / 100;
    _sky(canvas, size, _gardenSky);
    _shape(canvas, _circle(Offset(w * 0.86, h * 0.16), 10 * u), AppColors.sun);
    _ground(canvas, size, h * 0.74, _grass);
    _shape(
      canvas,
      Path()..addRect(Rect.fromLTWH(-4, h * 0.86, w + 8, h * 0.2)),
      const Color(0xFF9C6B45),
    );
    for (final (x, t) in [
      (0.1, 1.1),
      (0.22, 1.3),
      (0.62, 1.2),
      (0.76, 1.4),
      (0.9, 1.1),
    ]) {
      _sunflower(canvas, Offset(w * x, h * 0.88), u, droopy: false, tall: t);
    }
    _windmill(canvas, Offset(w * 0.4, h * 0.42), u * 0.7, turn: 0.1);
    // Water drops.
    for (final (x, y) in [(0.5, 0.3), (0.55, 0.4), (0.47, 0.46)]) {
      final drop = Path()
        ..moveTo(w * x, h * y - 4 * u)
        ..quadraticBezierTo(w * x + 3 * u, h * y + 1 * u, w * x, h * y + 2 * u)
        ..quadraticBezierTo(w * x - 3 * u, h * y + 1 * u, w * x, h * y - 4 * u)
        ..close();
      _shape(canvas, drop, AppColors.brandBlue, 1.4);
    }
    _pim(
      canvas,
      Offset(w * 0.46, h * 0.72),
      u * 1.1,
      happy: true,
      armsUp: true,
    );
  }

  @override
  bool shouldRepaint(StoryPicturePainter oldDelegate) =>
      oldDelegate.picture != picture;
}
