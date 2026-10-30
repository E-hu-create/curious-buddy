import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../domain/wardrobe/wardrobe.dart';
import '../../themes/app_colors.dart';
import 'buddy_outfit_painter.dart';

/// Buddy's expressions. Every mood uses the same character model; only the
/// face and arm pose change. See docs/MASCOT.md.
enum BuddyMood { neutral, happy, curious, surprised, thoughtful, excited }

/// Draws Buddy: a small, rounded teal creature with round ears and a golden
/// explorer backpack.
///
/// Coordinates are on a 100 x 120 grid and scaled to fit, so Buddy stays
/// crisp at any size without image assets. Soft shading comes from radial
/// gradients and a blurred highlight; there are no textures.
class BuddyPainter extends CustomPainter {
  const BuddyPainter({
    required this.mood,
    this.armLift = 0,
    this.armSwing = 0,
    this.look = BuddyLook.none,
  });

  final BuddyMood mood;

  /// 0 = right arm resting, 1 = fully raised for a wave. Only used by
  /// [BuddyMood.happy] and [BuddyMood.neutral].
  final double armLift;

  /// -1..1 side-to-side wave motion, applied on top of [armLift].
  final double armSwing;

  /// What he is wearing. His default look has no accessories.
  final BuddyLook look;

  static const gridWidth = 100.0;
  static const gridHeight = 120.0;
  static const aspectRatio = gridWidth / gridHeight;

  static const _body = Rect.fromLTRB(14, 32, 86, 110);
  static const _leftShoulder = Offset(18, 76);
  static const _rightShoulder = Offset(82, 76);
  static const _leftEye = Offset(37, 61);
  static const _rightEye = Offset(63, 61);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / gridWidth, size.height / gridHeight);
    canvas
      ..save()
      ..translate(
        (size.width - gridWidth * scale) / 2,
        (size.height - gridHeight * scale) / 2,
      )
      ..scale(scale);

    _groundShadow(canvas);

    canvas.save();
    if (mood == BuddyMood.curious) {
      // Head tilt: pivot near the feet so Buddy leans rather than slides.
      canvas
        ..translate(50, 110)
        ..rotate(-0.12)
        ..translate(-50, -110);
    }

    _feet(canvas);
    _backpack(canvas);
    _ears(canvas);
    final (left, right) = _armAngles();
    final rightInFront = mood == BuddyMood.thoughtful;
    _arm(canvas, _leftShoulder, left);
    if (!rightInFront) _arm(canvas, _rightShoulder, right);
    _bodyShape(canvas);
    _straps(canvas);
    BuddyOutfitPainter.paintNeck(canvas, _body, look.neck);
    _brows(canvas);
    _eyes(canvas);
    _cheeks(canvas);
    _mouth(canvas);
    BuddyOutfitPainter.paintGlasses(canvas, _leftEye, _rightEye, look.glasses);
    BuddyOutfitPainter.paintHat(canvas, look.hat);
    if (rightInFront) _arm(canvas, _rightShoulder, right);

    canvas
      ..restore()
      ..restore();
  }

  // ---------------------------------------------------------------- body

  void _groundShadow(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 116), width: 56, height: 7),
      Paint()
        ..color = const Color(0x26000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  void _feet(Canvas canvas) {
    for (final rect in const [
      Rect.fromLTRB(29, 101, 48, 118),
      Rect.fromLTRB(52, 101, 71, 118),
    ]) {
      _softShape(canvas, Path()..addOval(rect), rect);
    }
  }

  void _ears(Canvas canvas) {
    for (final center in const [Offset(28, 40), Offset(72, 40)]) {
      final rect = Rect.fromCircle(center: center, radius: 9);
      _softShape(canvas, Path()..addOval(rect), rect);
      canvas.drawCircle(
        center,
        4.5,
        Paint()..color = AppColors.buddyBelly.withValues(alpha: 0.8),
      );
    }
  }

  void _bodyShape(Canvas canvas) {
    final body = Path()..addOval(_body);
    _softShape(canvas, body, _body, outlineWidth: 2.2);

    // Lighter belly patch, fading out at the edges.
    const belly = Rect.fromLTRB(30, 80, 70, 107);
    canvas.drawOval(
      belly,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.buddyBelly.withValues(alpha: 0.5),
            AppColors.buddyBelly.withValues(alpha: 0),
          ],
        ).createShader(belly),
    );

    // Soft studio highlight, top left.
    canvas.drawOval(
      const Rect.fromLTRB(24, 39, 44, 52),
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
  }

  /// Teal fill lit from the top left, with a darker outline.
  static void _softShape(
    Canvas canvas,
    Path path,
    Rect bounds, {
    double outlineWidth = 2,
  }) {
    canvas
      ..drawPath(
        path,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(-0.35, -0.5),
            radius: 0.95,
            colors: [
              AppColors.buddyTealLight,
              AppColors.buddyTeal,
              AppColors.buddyTealDeep,
            ],
            stops: [0, 0.55, 1],
          ).createShader(bounds),
      )
      ..drawPath(path, _stroke(AppColors.buddyOutline, outlineWidth));
  }

  // ------------------------------------------------------------ backpack

  void _backpack(Canvas canvas) {
    const pack = Rect.fromLTRB(72, 50, 97, 96);
    final packPath = Path()
      ..addRRect(RRect.fromRectAndRadius(pack, const Radius.circular(9)));
    canvas
      ..drawPath(
        packPath,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.backpack, AppColors.backpackShade],
          ).createShader(pack),
      )
      ..drawPath(packPath, _stroke(AppColors.backpackOutline, 2));

    final flap = RRect.fromLTRBAndCorners(
      72,
      50,
      97,
      65,
      topLeft: const Radius.circular(9),
      topRight: const Radius.circular(9),
      bottomLeft: const Radius.circular(4),
      bottomRight: const Radius.circular(4),
    );
    canvas
      ..drawRRect(flap, Paint()..color = AppColors.backpackShade)
      ..drawRRect(flap, _stroke(AppColors.backpackOutline, 1.6))
      ..drawRRect(
        RRect.fromLTRBR(88, 61, 94, 67, const Radius.circular(1.5)),
        Paint()..color = AppColors.backpackOutline,
      );

    final pocket = RRect.fromLTRBR(84, 74, 95, 88, const Radius.circular(4));
    canvas
      ..drawRRect(pocket, Paint()..color = AppColors.backpack)
      ..drawRRect(pocket, _stroke(AppColors.backpackOutline, 1.6));
  }

  /// One strap over the right shoulder, running down to the armpit; the pack
  /// itself sits behind Buddy.
  void _straps(Canvas canvas) {
    final strap = Path()
      ..moveTo(66, 33)
      ..quadraticBezierTo(76, 52, 83, 82);
    canvas
      ..save()
      ..clipPath(Path()..addOval(_body))
      ..drawPath(strap, _stroke(AppColors.backpackOutline, 6.5))
      ..drawPath(strap, _stroke(AppColors.backpack, 4.2))
      ..restore();
    final buckle = RRect.fromLTRBR(
      76,
      64,
      82.5,
      69.5,
      const Radius.circular(1.5),
    );
    canvas
      ..drawRRect(buckle, Paint()..color = AppColors.backpackShade)
      ..drawRRect(buckle, _stroke(AppColors.backpackOutline, 1.4));
  }

  // ---------------------------------------------------------------- arms

  (double, double) _armAngles() {
    const rest = 0.45;
    return switch (mood) {
      BuddyMood.neutral => (rest, -rest - armLift * 2.1 + armSwing * 0.4),
      // Welcoming: arm already half raised, so the pose reads when still.
      BuddyMood.happy => (
        rest,
        -rest - (0.3 + armLift * 0.7) * 2.1 + armSwing * 0.4,
      ),
      BuddyMood.curious => (rest, -rest),
      BuddyMood.surprised => (1.3, -1.3),
      BuddyMood.excited => (2.6, -2.6),
      // Right hand raised to the cheek.
      BuddyMood.thoughtful => (rest, 1.6),
    };
  }

  void _arm(Canvas canvas, Offset shoulder, double angle) {
    canvas
      ..save()
      ..translate(shoulder.dx, shoulder.dy)
      ..rotate(angle);
    const rect = Rect.fromLTRB(-6, -3, 6, 19);
    _softShape(
      canvas,
      Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(6))),
      rect,
    );
    canvas.restore();
  }

  // ---------------------------------------------------------------- face

  void _brows(Canvas canvas) {
    // (height, arch, tilt) per eye. Lower y is higher on the face.
    final (left, right) = switch (mood) {
      BuddyMood.neutral => ((46.0, 2.0, 0.0), (46.0, 2.0, 0.0)),
      BuddyMood.happy => ((45.0, 2.5, 0.0), (45.0, 2.5, 0.0)),
      BuddyMood.curious => ((47.0, 0.5, 0.0), (42.0, 3.0, 0.0)),
      BuddyMood.surprised => ((41.0, 3.5, 0.0), (41.0, 3.5, 0.0)),
      BuddyMood.thoughtful => ((43.0, 2.5, 0.8), (47.0, 0.5, -1.0)),
      BuddyMood.excited => ((44.0, 3.0, 0.0), (44.0, 3.0, 0.0)),
    };
    final paint = _stroke(AppColors.buddyOutline, 2.2);
    for (final (eye, (y, arch, tilt)) in [
      (_leftEye, left),
      (_rightEye, right),
    ]) {
      canvas.drawPath(
        Path()
          ..moveTo(eye.dx - 5, y + tilt)
          ..quadraticBezierTo(eye.dx, y - arch, eye.dx + 5, y - tilt),
        paint,
      );
    }
  }

  void _eyes(Canvas canvas) {
    if (mood == BuddyMood.excited) {
      // Squeezed-shut happy eyes.
      for (final eye in const [_leftEye, _rightEye]) {
        canvas.drawPath(
          Path()
            ..moveTo(eye.dx - 6, eye.dy + 3)
            ..quadraticBezierTo(eye.dx, eye.dy - 7, eye.dx + 6, eye.dy + 3),
          _stroke(AppColors.buddyOutline, 3),
        );
      }
      return;
    }
    final (leftSize, rightSize, look) = switch (mood) {
      BuddyMood.curious => (
        const Size(15, 18),
        const Size(19, 22),
        const Offset(2, -1.5),
      ),
      BuddyMood.surprised => (
        const Size(19, 23),
        const Size(19, 23),
        Offset.zero,
      ),
      BuddyMood.thoughtful => (
        const Size(17, 19),
        const Size(17, 19),
        const Offset(-2.5, -3),
      ),
      BuddyMood.neutral => (
        const Size(17, 20),
        const Size(17, 20),
        const Offset(0, 1),
      ),
      _ => (const Size(17, 20), const Size(17, 20), Offset.zero),
    };
    _eye(canvas, _leftEye, leftSize, look);
    _eye(canvas, _rightEye, rightSize, look);
  }

  void _eye(Canvas canvas, Offset center, Size size, Offset look) {
    final sclera = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
    final iris = center + look;
    final irisRadius = size.width * 0.36;
    canvas
      ..drawOval(sclera, Paint()..color = AppColors.white)
      ..drawOval(sclera, _stroke(AppColors.buddyOutline, 1.6))
      ..save()
      ..clipPath(Path()..addOval(sclera))
      ..drawCircle(
        iris,
        irisRadius,
        Paint()
          ..shader = const RadialGradient(
            center: Alignment(0, 0.4),
            colors: [AppColors.buddyIrisLight, AppColors.buddyIris],
          ).createShader(Rect.fromCircle(center: iris, radius: irisRadius)),
      )
      ..drawCircle(
        iris,
        size.width * 0.2,
        Paint()..color = AppColors.buddyPupil,
      )
      ..restore()
      // Glossy reflections: one large, one small.
      ..drawCircle(
        iris + Offset(size.width * 0.13, -size.height * 0.15),
        size.width * 0.13,
        Paint()..color = AppColors.white,
      )
      ..drawCircle(
        iris + Offset(-size.width * 0.1, size.height * 0.12),
        size.width * 0.06,
        Paint()..color = AppColors.white.withValues(alpha: 0.9),
      );
  }

  void _cheeks(Canvas canvas) {
    for (final center in const [Offset(26, 73), Offset(74, 73)]) {
      final rect = Rect.fromCenter(center: center, width: 13, height: 9);
      canvas.drawOval(
        rect,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.cheek.withValues(alpha: 0.9),
              AppColors.cheek.withValues(alpha: 0),
            ],
          ).createShader(rect),
      );
    }
  }

  void _mouth(Canvas canvas) {
    final line = _stroke(AppColors.buddyMouth, 2.2);
    switch (mood) {
      case BuddyMood.neutral:
        canvas.drawPath(
          Path()
            ..moveTo(45, 76)
            ..quadraticBezierTo(50, 80, 55, 76),
          line,
        );
      case BuddyMood.curious:
        // Slightly lopsided, a little mischievous.
        canvas.drawPath(
          Path()
            ..moveTo(45, 77)
            ..quadraticBezierTo(51, 80, 56, 75),
          line,
        );
      case BuddyMood.thoughtful:
        canvas.drawPath(
          Path()
            ..moveTo(45, 78)
            ..cubicTo(48, 76, 51, 79, 55, 77),
          line,
        );
      case BuddyMood.surprised:
        canvas.drawOval(
          const Rect.fromLTRB(46.5, 74, 53.5, 82),
          Paint()..color = AppColors.buddyMouth,
        );
      case BuddyMood.happy:
        _openSmile(canvas, width: 16, depth: 12);
      case BuddyMood.excited:
        _openSmile(canvas, width: 18, depth: 15);
    }
  }

  void _openSmile(
    Canvas canvas, {
    required double width,
    required double depth,
  }) {
    const top = 74.0;
    final left = 50 - width / 2;
    final right = 50 + width / 2;
    final mouth = Path()
      ..moveTo(left, top)
      ..quadraticBezierTo(50, top + depth, right, top)
      ..quadraticBezierTo(50, top + 2.5, left, top)
      ..close();
    canvas
      ..drawPath(mouth, Paint()..color = AppColors.buddyMouth)
      ..save()
      ..clipPath(mouth)
      ..drawOval(
        Rect.fromCenter(
          center: Offset(50, top + depth * 0.62),
          width: width * 0.55,
          height: depth * 0.5,
        ),
        Paint()..color = AppColors.buddyTongue,
      )
      ..restore();
  }

  static Paint _stroke(Color color, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = color;

  @override
  bool shouldRepaint(BuddyPainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.armLift != armLift ||
      oldDelegate.armSwing != armSwing ||
      oldDelegate.look != look;
}
