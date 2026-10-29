import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

enum BuddyMood { cheerful, happy, curious }

/// Draws Buddy, a small blue robot, in a flat outlined cartoon style.
///
/// Coordinates are on a 100 x 120 grid and scaled to fit, so Buddy stays
/// crisp at any size without image assets.
class BuddyPainter extends CustomPainter {
  const BuddyPainter({required this.mood, this.armLift = 0, this.armSwing = 0});

  final BuddyMood mood;

  /// 0 = right arm resting, 1 = fully raised for a wave.
  final double armLift;

  /// -1..1 side-to-side wave motion, applied on top of [armLift].
  final double armSwing;

  static const _gridWidth = 100.0;
  static const _gridHeight = 120.0;
  static const aspectRatio = _gridWidth / _gridHeight;

  static final _outline = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.5
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..color = AppColors.ink;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / _gridWidth, size.height / _gridHeight);
    canvas
      ..save()
      ..translate(
        (size.width - _gridWidth * scale) / 2,
        (size.height - _gridHeight * scale) / 2,
      )
      ..scale(scale);

    // Back to front.
    _shape(canvas, _rrect(31, 108, 45, 119, 5), AppColors.buddyBlueShade);
    _shape(canvas, _rrect(55, 108, 69, 119, 5), AppColors.buddyBlueShade);
    _arm(canvas, const Offset(29, 88), 0.35);
    _arm(canvas, const Offset(71, 88), -0.35 - armLift * 2.2 + armSwing * 0.4);
    _shape(canvas, _rrect(26, 80, 74, 113, 14), AppColors.buddyBlue);
    _shape(canvas, _circle(50, 96, 7), AppColors.sun);
    canvas.drawCircle(
      const Offset(47.5, 93.5),
      2,
      Paint()..color = AppColors.white,
    );
    _shape(canvas, _rrect(43, 72, 57, 82, 3), AppColors.buddyBlueShade);

    canvas.drawLine(const Offset(50, 23), const Offset(50, 11), _outline);
    _shape(canvas, _circle(50, 8, 5), AppColors.coral);
    _shape(canvas, _rrect(8, 40, 18, 58, 4), AppColors.buddyBlueShade);
    _shape(canvas, _rrect(82, 40, 92, 58, 4), AppColors.buddyBlueShade);
    _shape(canvas, _rrect(14, 22, 86, 75, 18), AppColors.buddyBlue);

    canvas.drawRRect(
      RRect.fromLTRBR(22, 30, 78, 67, const Radius.circular(12)),
      Paint()..color = AppColors.buddyScreen,
    );
    _eyes(canvas);
    _mouth(canvas);
    final cheek = Paint()..color = AppColors.cheek;
    canvas
      ..drawCircle(const Offset(29, 59), 3.5, cheek)
      ..drawCircle(const Offset(71, 59), 3.5, cheek)
      ..restore();
  }

  void _arm(Canvas canvas, Offset shoulder, double angle) {
    canvas
      ..save()
      ..translate(shoulder.dx, shoulder.dy)
      ..rotate(angle);
    _shape(canvas, _rrect(-5, -3, 5, 20, 5), AppColors.buddyBlueShade);
    _shape(canvas, _circle(0, 22, 5.5), AppColors.buddyBlue);
    canvas.restore();
  }

  void _eyes(Canvas canvas) {
    switch (mood) {
      case BuddyMood.happy:
        final stroke = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = AppColors.eyeGlow;
        for (final x in const [38.0, 62.0]) {
          canvas.drawPath(
            Path()
              ..moveTo(x - 6, 50)
              ..quadraticBezierTo(x, 39, x + 6, 50),
            stroke,
          );
        }
      case BuddyMood.cheerful:
        _eye(canvas, const Offset(38, 47), 11, 14);
        _eye(canvas, const Offset(62, 47), 11, 14);
      case BuddyMood.curious:
        _eye(canvas, const Offset(38, 48), 9, 11);
        _eye(canvas, const Offset(62, 46), 13, 16);
    }
  }

  void _eye(Canvas canvas, Offset center, double width, double height) {
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: center, width: width, height: height),
          Radius.circular(width / 2),
        ),
        Paint()..color = AppColors.eyeGlow,
      )
      ..drawCircle(
        center + Offset(width * 0.18, -height * 0.2),
        width * 0.16,
        Paint()..color = AppColors.white,
      );
  }

  void _mouth(Canvas canvas) {
    final glow = Paint()
      ..color = AppColors.eyeGlow
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    switch (mood) {
      case BuddyMood.cheerful:
        canvas.drawPath(
          Path()
            ..moveTo(43, 57)
            ..quadraticBezierTo(50, 64, 57, 57),
          glow..style = PaintingStyle.stroke,
        );
      case BuddyMood.happy:
        canvas.drawPath(
          Path()
            ..moveTo(42, 56)
            ..quadraticBezierTo(50, 68, 58, 56)
            ..close(),
          glow..style = PaintingStyle.fill,
        );
      case BuddyMood.curious:
        canvas.drawCircle(
          const Offset(50, 59),
          3,
          glow..style = PaintingStyle.stroke,
        );
    }
  }

  static void _shape(Canvas canvas, Path path, Color fill) {
    canvas
      ..drawPath(path, Paint()..color = fill)
      ..drawPath(path, _outline);
  }

  static Path _rrect(double l, double t, double r, double b, double radius) =>
      Path()..addRRect(RRect.fromLTRBR(l, t, r, b, Radius.circular(radius)));

  static Path _circle(double x, double y, double r) =>
      Path()..addOval(Rect.fromCircle(center: Offset(x, y), radius: r));

  @override
  bool shouldRepaint(BuddyPainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.armLift != armLift ||
      oldDelegate.armSwing != armSwing;
}
