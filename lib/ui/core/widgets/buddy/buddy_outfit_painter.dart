import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../domain/wardrobe/wardrobe.dart';
import '../../themes/app_colors.dart';

/// Draws Buddy's outfit on his 100 x 120 grid. Flat fills with ink outlines,
/// so the pieces read clearly even at small sizes.
abstract final class BuddyOutfitPainter {
  static Paint _fill(Color c) => Paint()..color = c;
  static Paint _line([double w = 1.6]) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = AppColors.ink;

  static void _shape(Canvas canvas, Path path, Color color) {
    canvas
      ..drawPath(path, _fill(color))
      ..drawPath(path, _line());
  }

  /// Over the body, under the arms' front layer.
  static void paintNeck(Canvas canvas, Rect body, WardrobeItem? item) {
    switch (item) {
      case WardrobeItem.bowTie:
        _bowTie(canvas);
      case WardrobeItem.scarf:
        _scarf(canvas, body);
      case WardrobeItem.medal:
        _medal(canvas);
      default:
        break;
    }
  }

  /// Over the eyes.
  static void paintGlasses(
    Canvas canvas,
    Offset left,
    Offset right,
    WardrobeItem? item,
  ) {
    switch (item) {
      case WardrobeItem.roundGlasses:
        _round(canvas, left, right);
      case WardrobeItem.sunglasses:
        _sunglasses(canvas, left, right);
      case WardrobeItem.starGlasses:
        _stars(canvas, left, right);
      default:
        break;
    }
  }

  /// On top of everything.
  static void paintHat(Canvas canvas, WardrobeItem? item) {
    switch (item) {
      case WardrobeItem.partyHat:
        _partyHat(canvas);
      case WardrobeItem.detectiveHat:
        _detectiveHat(canvas);
      case WardrobeItem.wizardHat:
        _wizardHat(canvas);
      case WardrobeItem.crown:
        _crown(canvas);
      case WardrobeItem.championCap:
        _cap(canvas);
      default:
        break;
    }
  }

  // --------------------------------------------------------------- neck

  static void _bowTie(Canvas canvas) {
    const c = Offset(50, 89);
    for (final side in [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + side * 13, c.dy - 7)
        ..lineTo(c.dx + side * 13, c.dy + 7)
        ..close();
      _shape(canvas, wing, AppColors.coral);
    }
    _shape(
      canvas,
      Path()..addOval(Rect.fromCircle(center: c, radius: 3.4)),
      AppColors.sun,
    );
  }

  static void _scarf(Canvas canvas, Rect body) {
    canvas
      ..save()
      ..clipPath(Path()..addOval(body));
    final band = Path()
      ..moveTo(body.left, 80)
      ..quadraticBezierTo(50, 92, body.right, 80)
      ..lineTo(body.right, 88)
      ..quadraticBezierTo(50, 100, body.left, 88)
      ..close();
    _shape(canvas, band, AppColors.coral);
    canvas.restore();
    final tail = Path()
      ..addRRect(RRect.fromLTRBR(58, 90, 67, 107, const Radius.circular(2)));
    _shape(canvas, tail, AppColors.coral);
    for (final y in [96.0, 101.0]) {
      canvas.drawLine(Offset(58, y), Offset(67, y), _line(1.1));
    }
  }

  static void _medal(Canvas canvas) {
    for (final side in [-1.0, 1.0]) {
      canvas.drawLine(
        Offset(50 + side * 15, 80),
        const Offset(50, 92),
        Paint()
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..color = AppColors.brandBlue,
      );
    }
    const c = Offset(50, 96);
    _shape(
      canvas,
      Path()..addOval(Rect.fromCircle(center: c, radius: 7.5)),
      AppColors.sun,
    );
    _shape(canvas, _star(c, 4.2, 1.9), AppColors.white);
  }

  // ------------------------------------------------------------ glasses

  static void _round(Canvas canvas, Offset left, Offset right) {
    const r = 11.5;
    for (final c in [left, right]) {
      canvas.drawCircle(c, r, _line(2));
    }
    canvas.drawLine(
      left + const Offset(r, 0),
      right - const Offset(r, 0),
      _line(2),
    );
  }

  static void _sunglasses(Canvas canvas, Offset left, Offset right) {
    final lens = Paint()..color = AppColors.ink.withValues(alpha: 0.88);
    for (final c in [left, right]) {
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: c, width: 21, height: 15),
        const Radius.circular(6),
      );
      canvas
        ..drawRRect(rect, lens)
        ..drawRRect(rect, _line(2))
        ..drawLine(
          c + const Offset(-6, -3.5),
          c + const Offset(-1, -3.5),
          _line(1.4)..color = AppColors.white,
        );
    }
    canvas.drawLine(
      left + const Offset(10.5, -2),
      right - const Offset(10.5, 2),
      _line(2),
    );
  }

  static void _stars(Canvas canvas, Offset left, Offset right) {
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeJoin = StrokeJoin.round
      ..color = AppColors.coral;
    for (final c in [left, right]) {
      canvas
        ..drawPath(_star(c, 15, 8.5), frame)
        ..drawPath(_star(c, 15, 8.5), _line(0.9));
    }
  }

  // --------------------------------------------------------------- hats

  static void _partyHat(Canvas canvas) {
    final hat = Path()
      ..moveTo(34, 37)
      ..lineTo(50, 6)
      ..lineTo(66, 37)
      ..quadraticBezierTo(50, 44, 34, 37)
      ..close();
    _shape(canvas, hat, AppColors.grape);
    canvas
      ..save()
      ..clipPath(hat);
    final stripe = Paint()..color = AppColors.sun;
    for (final y in [12.0, 24.0, 35.0]) {
      canvas.drawRect(Rect.fromLTWH(30, y, 40, 4), stripe);
    }
    canvas.restore();
    _shape(
      canvas,
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(50, 6), radius: 3.5)),
      AppColors.coral,
    );
  }

  static void _detectiveHat(Canvas canvas) {
    const tweed = Color(0xFFB98A5A);
    final brim = Path()
      ..addOval(
        Rect.fromCenter(center: const Offset(50, 35), width: 58, height: 12),
      );
    _shape(canvas, brim, const Color(0xFF8E6B4E));
    final crown = Path()
      ..moveTo(31, 35)
      ..quadraticBezierTo(33, 14, 50, 13)
      ..quadraticBezierTo(67, 14, 69, 35)
      ..quadraticBezierTo(50, 41, 31, 35)
      ..close();
    _shape(canvas, crown, tweed);
    canvas.drawLine(const Offset(50, 13), const Offset(50, 37), _line(1.1));
    _shape(
      canvas,
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(50, 12), radius: 2.6)),
      AppColors.sunTint,
    );
  }

  static void _wizardHat(Canvas canvas) {
    final brim = Path()
      ..addOval(
        Rect.fromCenter(center: const Offset(50, 36), width: 66, height: 12),
      );
    _shape(canvas, brim, const Color(0xFF4A3A8C));
    final cone = Path()
      ..moveTo(32, 36)
      ..quadraticBezierTo(40, 16, 58, 0)
      ..quadraticBezierTo(58, 18, 68, 36)
      ..quadraticBezierTo(50, 42, 32, 36)
      ..close();
    _shape(canvas, cone, AppColors.grape);
    _shape(canvas, _star(const Offset(47, 26), 5, 2.2), AppColors.sun);
    _shape(canvas, _star(const Offset(57, 15), 3.4, 1.5), AppColors.sun);
  }

  static void _cap(Canvas canvas) {
    final peak = Path()
      ..moveTo(52, 34)
      ..quadraticBezierTo(76, 31, 82, 38)
      ..quadraticBezierTo(70, 42, 52, 40)
      ..close();
    _shape(canvas, peak, AppColors.brandBlueDeep);
    final dome = Path()
      ..moveTo(30, 38)
      ..quadraticBezierTo(30, 14, 50, 13)
      ..quadraticBezierTo(70, 14, 70, 38)
      ..quadraticBezierTo(50, 44, 30, 38)
      ..close();
    _shape(canvas, dome, AppColors.brandBlue);
    _shape(canvas, _star(const Offset(50, 26), 6.5, 2.9), AppColors.sun);
  }

  static void _crown(Canvas canvas) {
    final crown = Path()
      ..moveTo(32, 36)
      ..lineTo(29, 13)
      ..lineTo(40, 23)
      ..lineTo(50, 8)
      ..lineTo(60, 23)
      ..lineTo(71, 13)
      ..lineTo(68, 36)
      ..quadraticBezierTo(50, 42, 32, 36)
      ..close();
    _shape(canvas, crown, AppColors.sun);
    for (final (x, r, color) in const [
      (50.0, 3.0, AppColors.coral),
      (38.0, 2.2, AppColors.brandBlue),
      (62.0, 2.2, AppColors.leaf),
    ]) {
      _shape(
        canvas,
        Path()..addOval(Rect.fromCircle(center: Offset(x, 30), radius: r)),
        color,
      );
    }
  }

  static Path _star(Offset c, double outer, double inner) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final p = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }
}
