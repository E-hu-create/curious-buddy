import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/missions/mission.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';
import '../../games/widgets/ink_pen.dart';

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
    MissionArt.puddle => 'A puddle in a chalk circle under a sun and a cloud',
    MissionArt.lighthouse => 'A dark lighthouse on the rocks beside the sea',
    MissionArt.postcards => 'A postcard floating in space beside a red planet',
    MissionArt.beach => 'Turtle tracks crossing a sandy beach at sunrise',
    MissionArt.bread => 'A tall loaf of bread beside a flat one',
    MissionArt.orchard => 'An apple tree with a bee flying towards a flower',
    MissionArt.shadow => 'A statue on a square casting a long shadow',
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
      case MissionArt.puddle:
        _puddle(canvas, size);
      case MissionArt.lighthouse:
        _lighthouse(canvas, size);
      case MissionArt.postcards:
        _postcards(canvas, size);
      case MissionArt.beach:
        _beach(canvas, size);
      case MissionArt.bread:
        _bread(canvas, size);
      case MissionArt.orchard:
        _orchard(canvas, size);
      case MissionArt.shadow:
        _shadow(canvas, size);
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

  /// Fills the cover, and returns a pen and a way to place points by
  /// fractions of its size.
  (InkPen, Offset Function(double, double)) _start(
    Canvas canvas,
    Size size,
    Color background,
  ) {
    canvas.drawRect(Offset.zero & size, _fill(background));
    return (
      InkPen(canvas, outline: 2.5),
      (x, y) => Offset(size.width * x, size.height * y),
    );
  }

  void _puddle(Canvas canvas, Size size) {
    final (pen, p) = _start(canvas, size, const Color(0xFFCFEFFF));
    pen
      ..disc(p(0.82, 0.22), 20, AppColors.sun)
      ..blob([
        p(0.2, 0.3),
        p(0.28, 0.14),
        p(0.42, 0.12),
        p(0.52, 0.24),
        p(0.56, 0.36),
        p(0.2, 0.36),
      ], AppColors.white)
      ..poly([
        p(-0.02, 0.6),
        p(1.02, 0.6),
        p(1.02, 1.02),
        p(-0.02, 1.02),
      ], const Color(0xFFC9CCD6))
      ..blob([
        p(0.2, 0.8),
        p(0.34, 0.66),
        p(0.62, 0.66),
        p(0.8, 0.8),
        p(0.6, 0.94),
        p(0.34, 0.94),
      ], AppColors.white)
      ..blob([
        p(0.3, 0.8),
        p(0.42, 0.72),
        p(0.6, 0.73),
        p(0.7, 0.8),
        p(0.56, 0.88),
        p(0.42, 0.88),
      ], AppColors.brandBlue);
    for (final x in [0.34, 0.5, 0.66]) {
      pen.line([p(x, 0.58), p(x + 0.02, 0.46), p(x, 0.38)]);
    }
  }

  void _lighthouse(Canvas canvas, Size size) {
    final (pen, p) = _start(canvas, size, const Color(0xFF263A6B));
    _stars(canvas, size, 5);
    pen
      ..poly([
        p(-0.02, 0.76),
        p(1.02, 0.76),
        p(1.02, 1.02),
        p(-0.02, 1.02),
      ], AppColors.brandBlue)
      ..blob([
        p(0.2, 0.86),
        p(0.34, 0.68),
        p(0.66, 0.68),
        p(0.8, 0.86),
      ], AppColors.inkSoft)
      ..poly([
        p(0.42, 0.72),
        p(0.58, 0.72),
        p(0.55, 0.3),
        p(0.45, 0.3),
      ], AppColors.white)
      ..poly([
        p(0.44, 0.56),
        p(0.56, 0.56),
        p(0.55, 0.42),
        p(0.45, 0.42),
      ], AppColors.coral)
      ..poly([
        p(0.44, 0.3),
        p(0.56, 0.3),
        p(0.56, 0.18),
        p(0.44, 0.18),
      ], AppColors.inkSoft)
      ..poly([p(0.42, 0.18), p(0.5, 0.06), p(0.58, 0.18)], AppColors.coral);
  }

  void _postcards(Canvas canvas, Size size) {
    final (pen, p) = _start(canvas, size, const Color(0xFF1B1A4B));
    _stars(canvas, size, 11);
    pen
      ..disc(p(0.2, 0.62), 42, const Color(0xFFD9774A))
      ..disc(p(0.14, 0.52), 8, const Color(0xFFAF5730))
      ..disc(p(0.25, 0.72), 6, const Color(0xFFAF5730))
      ..poly([
        p(0.46, 0.22),
        p(0.92, 0.3),
        p(0.86, 0.84),
        p(0.4, 0.76),
      ], AppColors.paper)
      ..poly([
        p(0.76, 0.32),
        p(0.87, 0.34),
        p(0.85, 0.5),
        p(0.74, 0.48),
      ], AppColors.coral)
      ..line([p(0.65, 0.3), p(0.6, 0.76)]);
    for (final y in [0.46, 0.56, 0.66]) {
      pen.line([p(0.47, y), p(0.58, y + 0.02)]);
    }
  }

  void _beach(Canvas canvas, Size size) {
    final (pen, p) = _start(canvas, size, const Color(0xFFFFD8A8));
    pen
      ..disc(p(0.78, 0.26), 22, AppColors.sun)
      ..poly([
        p(-0.02, 0.32),
        p(1.02, 0.32),
        p(1.02, 0.56),
        p(-0.02, 0.56),
      ], AppColors.brandBlue)
      ..blob([
        p(-0.1, 0.6),
        p(0.3, 0.5),
        p(0.7, 0.54),
        p(1.1, 0.48),
        p(1.1, 1.1),
        p(-0.1, 1.1),
      ], const Color(0xFFE5CE93));
    // A pair of flipper marks with a groove between them, heading up the sand.
    pen.line([p(0.5, 0.56), p(0.46, 0.76), p(0.42, 0.98)], width: 4);
    for (var i = 0; i < 6; i++) {
      final y = 0.6 + i * 0.07;
      final x = 0.5 - (y - 0.56) * 0.5;
      pen
        ..line([p(x - 0.06, y), p(x - 0.11, y - 0.02)], width: 3)
        ..line([p(x + 0.06, y), p(x + 0.11, y - 0.02)], width: 3);
    }
  }

  void _bread(Canvas canvas, Size size) {
    final (pen, p) = _start(canvas, size, AppColors.sunTint);
    const crust = Color(0xFFD9A05B);
    pen
      ..poly([
        p(-0.02, 0.8),
        p(1.02, 0.8),
        p(1.02, 1.02),
        p(-0.02, 1.02),
      ], const Color(0xFFB9743C))
      ..blob([
        p(0.1, 0.8),
        p(0.1, 0.46),
        p(0.2, 0.2),
        p(0.36, 0.2),
        p(0.46, 0.46),
        p(0.46, 0.8),
      ], crust)
      ..line([p(0.2, 0.34), p(0.24, 0.42)])
      ..line([p(0.3, 0.32), p(0.34, 0.4)])
      ..blob([
        p(0.56, 0.8),
        p(0.6, 0.7),
        p(0.76, 0.66),
        p(0.9, 0.7),
        p(0.94, 0.8),
      ], crust);
  }

  void _orchard(Canvas canvas, Size size) {
    final (pen, p) = _start(canvas, size, const Color(0xFFCFEFFF));
    pen
      ..poly([
        p(-0.02, 0.82),
        p(1.02, 0.82),
        p(1.02, 1.02),
        p(-0.02, 1.02),
      ], const Color(0xFF8FC96E))
      ..poly([
        p(0.28, 0.5),
        p(0.36, 0.5),
        p(0.38, 0.86),
        p(0.26, 0.86),
      ], const Color(0xFF8A5F3A))
      ..blob([
        p(0.32, 0.08),
        p(0.54, 0.2),
        p(0.56, 0.5),
        p(0.32, 0.62),
        p(0.08, 0.5),
        p(0.1, 0.2),
      ], AppColors.leaf);
    for (final (x, y) in [
      (0.22, 0.28),
      (0.4, 0.22),
      (0.46, 0.44),
      (0.24, 0.48),
    ]) {
      pen.disc(p(x, y), 7, AppColors.coral);
    }
    // A bee.
    pen
      ..disc(p(0.74, 0.3), 8, AppColors.white)
      ..disc(p(0.8, 0.3), 8, AppColors.white)
      ..blob([
        p(0.68, 0.42),
        p(0.76, 0.34),
        p(0.86, 0.42),
        p(0.76, 0.5),
      ], AppColors.sun)
      ..line([p(0.74, 0.36), p(0.74, 0.48)], width: 4)
      ..line([p(0.79, 0.36), p(0.79, 0.48)], width: 4);
  }

  void _shadow(Canvas canvas, Size size) {
    final (pen, p) = _start(canvas, size, const Color(0xFFFFE9B8));
    pen
      ..disc(p(0.84, 0.2), 20, AppColors.sun)
      ..poly([
        p(-0.02, 0.7),
        p(1.02, 0.7),
        p(1.02, 1.02),
        p(-0.02, 1.02),
      ], const Color(0xFFD9C8A8))
      ..poly([
        p(0.56, 0.86),
        p(0.08, 0.74),
        p(0.1, 0.8),
        p(0.54, 0.92),
      ], AppColors.inkSoft)
      ..poly([
        p(0.48, 0.86),
        p(0.64, 0.86),
        p(0.64, 0.74),
        p(0.48, 0.74),
      ], AppColors.paper)
      ..limb([p(0.56, 0.72), p(0.56, 0.46)], 10, AppColors.brandBlueDeep)
      ..disc(p(0.56, 0.3), 12, AppColors.brandBlueDeep);
  }

  @override
  bool shouldRepaint(_CoverPainter oldDelegate) => oldDelegate.art != art;
}
