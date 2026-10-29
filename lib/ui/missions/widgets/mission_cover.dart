import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/missions/mission.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';

/// A mission's cover, drawn in code in the app's flat sticker style
/// (solid fills, ink outlines), so it stays crisp and needs no image files.
class MissionCover extends StatelessWidget {
  const MissionCover({super.key, required this.art, this.height = 150});

  final MissionArt art;
  final double height;

  static String semanticLabel(MissionArt art) => switch (art) {
    MissionArt.moonstone =>
      'A glowing blue gem on a museum stand under a crescent moon',
    MissionArt.garden =>
      'A sunny garden with two healthy flowers and one drooping flower',
    MissionArt.signals => 'A radio tower sending signal waves under the stars',
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel(art),
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppShapes.radius - 4),
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: CustomPaint(painter: _CoverPainter(art)),
        ),
      ),
    );
  }
}

class _CoverPainter extends CustomPainter {
  const _CoverPainter(this.art);

  final MissionArt art;

  static Paint _fill(Color color) => Paint()..color = color;
  static final _ink = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..color = AppColors.ink;

  static void _shape(Canvas canvas, Path path, Color color) {
    canvas
      ..drawPath(path, _fill(color))
      ..drawPath(path, _ink);
  }

  @override
  void paint(Canvas canvas, Size size) {
    switch (art) {
      case MissionArt.moonstone:
        _moonstone(canvas, size);
      case MissionArt.garden:
        _garden(canvas, size);
      case MissionArt.signals:
        _signals(canvas, size);
    }
  }

  void _stars(Canvas canvas, Size size, int seed) {
    final random = math.Random(seed);
    final star = _fill(AppColors.sunTint);
    for (var i = 0; i < 14; i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height * 0.55,
        ),
        1.2 + random.nextDouble() * 1.6,
        star,
      );
    }
  }

  void _moonstone(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, _fill(const Color(0xFF263A6B)));
    _stars(canvas, size, 3);

    // Crescent moon.
    final moon = Path()
      ..addOval(Rect.fromCircle(center: Offset(w * 0.18, h * 0.3), radius: 22));
    final bite = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(w * 0.18 + 11, h * 0.3 - 6), radius: 20),
      );
    _shape(
      canvas,
      Path.combine(PathOperation.difference, moon, bite),
      AppColors.sun,
    );

    // Museum columns.
    for (final x in [w * 0.62, w * 0.9]) {
      _shape(
        canvas,
        Path()..addRect(Rect.fromLTWH(x - 9, h * 0.22, 18, h * 0.66)),
        AppColors.grapeTint,
      );
    }
    // Floor.
    _shape(
      canvas,
      Path()..addRect(Rect.fromLTWH(-4, h * 0.86, w + 8, h * 0.2)),
      AppColors.grape,
    );

    // Pedestal and glass case.
    final cx = w * 0.42;
    _shape(
      canvas,
      Path()..addRect(Rect.fromLTWH(cx - 28, h * 0.62, 56, h * 0.24)),
      AppColors.paper,
    );
    final glass = RRect.fromLTRBR(
      cx - 34,
      h * 0.24,
      cx + 34,
      h * 0.62,
      const Radius.circular(6),
    );
    canvas
      ..drawRRect(glass, _fill(AppColors.white.withValues(alpha: 0.25)))
      ..drawRRect(glass, _ink);

    // The gem, with a soft glow.
    canvas.drawCircle(
      Offset(cx, h * 0.45),
      26,
      _fill(AppColors.eyeGlowSoft.withValues(alpha: 0.35)),
    );
    final gem = Path()
      ..moveTo(cx, h * 0.32)
      ..lineTo(cx + 16, h * 0.44)
      ..lineTo(cx, h * 0.58)
      ..lineTo(cx - 16, h * 0.44)
      ..close();
    _shape(canvas, gem, AppColors.buddyBelly);
    canvas.drawLine(Offset(cx - 16, h * 0.44), Offset(cx + 16, h * 0.44), _ink);
  }

  void _garden(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, _fill(const Color(0xFFCFEFFF)));
    _shape(
      canvas,
      Path()..addOval(
        Rect.fromCircle(center: Offset(w * 0.86, h * 0.2), radius: 20),
      ),
      AppColors.sun,
    );
    // Soil.
    _shape(
      canvas,
      Path()..addRect(Rect.fromLTWH(-4, h * 0.74, w + 8, h * 0.3)),
      const Color(0xFF9C6B45),
    );
    // Puddle under the drooping flower.
    final puddle = Rect.fromCenter(
      center: Offset(w * 0.72, h * 0.8),
      width: 70,
      height: 12,
    );
    canvas
      ..drawOval(puddle, _fill(AppColors.brandBlue))
      ..drawOval(puddle, _ink);

    void flower(double x, {required bool droopy}) {
      final stem = Path()..moveTo(x, h * 0.76);
      final top = droopy ? Offset(x + 22, h * 0.48) : Offset(x, h * 0.3);
      stem.quadraticBezierTo(x + (droopy ? 4 : 0), h * 0.4, top.dx, top.dy);
      canvas.drawPath(
        stem,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round
          ..color = droopy ? const Color(0xFFB7A43A) : AppColors.leaf,
      );
      canvas.drawPath(stem, _ink..strokeWidth = 1.5);
      _ink.strokeWidth = 2.5;
      final leaf = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(x + 10, h * 0.62),
            width: 22,
            height: 10,
          ),
        );
      _shape(canvas, leaf, droopy ? AppColors.sunTint : AppColors.leaf);
      for (var i = 0; i < 5; i++) {
        final angle = i * 2 * math.pi / 5 + (droopy ? 0.6 : 0);
        _shape(
          canvas,
          Path()..addOval(
            Rect.fromCircle(
              center: top + Offset(math.cos(angle) * 10, math.sin(angle) * 10),
              radius: 8,
            ),
          ),
          droopy ? AppColors.coralTint : AppColors.coral,
        );
      }
      _shape(
        canvas,
        Path()..addOval(Rect.fromCircle(center: top, radius: 6)),
        AppColors.sun,
      );
    }

    flower(w * 0.2, droopy: false);
    flower(w * 0.42, droopy: false);
    flower(w * 0.64, droopy: true);
  }

  void _signals(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawRect(Offset.zero & size, _fill(const Color(0xFF17414D)));
    _stars(canvas, size, 9);
    // Snowy ground.
    _shape(
      canvas,
      Path()..addRect(Rect.fromLTWH(-4, h * 0.8, w + 8, h * 0.3)),
      const Color(0xFFDCEFF6),
    );

    // Tower.
    final base = h * 0.8;
    final tx = w * 0.32;
    final tower = Path()
      ..moveTo(tx - 22, base)
      ..lineTo(tx, h * 0.22)
      ..lineTo(tx + 22, base);
    canvas.drawPath(tower, _ink..strokeWidth = 4);
    _ink.strokeWidth = 2.5;
    for (final f in [0.45, 0.62]) {
      final y = h * 0.22 + (base - h * 0.22) * f;
      final half = 22 * f;
      canvas.drawLine(Offset(tx - half, y), Offset(tx + half, y), _ink);
    }
    _shape(
      canvas,
      Path()..addOval(Rect.fromCircle(center: Offset(tx, h * 0.2), radius: 7)),
      AppColors.coral,
    );

    // Signal waves.
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.eyeGlowSoft;
    for (var i = 1; i <= 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(tx, h * 0.2), radius: 16.0 * i),
        -0.8,
        1.6,
        false,
        wave,
      );
    }

    // Research hut.
    final hut = Path()
      ..addRect(Rect.fromLTWH(w * 0.6, h * 0.56, w * 0.26, h * 0.24));
    _shape(canvas, hut, AppColors.coral);
    final roof = Path()
      ..moveTo(w * 0.57, h * 0.57)
      ..lineTo(w * 0.73, h * 0.42)
      ..lineTo(w * 0.89, h * 0.57)
      ..close();
    _shape(canvas, roof, AppColors.paper);
    _shape(
      canvas,
      Path()..addRect(Rect.fromLTWH(w * 0.69, h * 0.62, w * 0.08, h * 0.08)),
      AppColors.sunTint,
    );
  }

  @override
  bool shouldRepaint(_CoverPainter oldDelegate) => oldDelegate.art != art;
}
