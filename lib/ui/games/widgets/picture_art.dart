import 'dart:math';

import 'package:flutter/material.dart';

import '../../../domain/games/games.dart';
import '../../core/themes/app_colors.dart';
import 'ink_pen.dart';

/// A drawn Memory Match picture.
class PictureArt extends StatelessWidget {
  const PictureArt({super.key, required this.picture, this.size = 40});

  final GamePicture picture;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: picture.label,
    child: CustomPaint(
      size: Size.square(size),
      painter: _PicturePainter(picture),
    ),
  );
}

Offset _o(double x, double y) => Offset(x, y);

/// Pictures are drawn on a 100 by 100 grid.
class _PicturePainter extends CustomPainter {
  const _PicturePainter(this.picture);

  final GamePicture picture;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    final pen = InkPen(canvas, outline: 2.4);
    switch (picture) {
      case GamePicture.rocket:
        _rocket(pen);
      case GamePicture.planet:
        _planet(pen);
      case GamePicture.fish:
        _fish(pen);
      case GamePicture.turtle:
        _turtle(pen);
      case GamePicture.butterfly:
        _butterfly(pen);
      case GamePicture.flower:
        _flower(pen);
      case GamePicture.tree:
        _tree(pen);
      case GamePicture.whale:
        _whale(pen);
      case GamePicture.volcano:
        _volcano(pen);
      case GamePicture.owl:
        _owl(pen);
      case GamePicture.mushroom:
        _mushroom(pen);
      case GamePicture.sailboat:
        _sailboat(pen);
    }
  }

  void _rocket(InkPen pen) {
    pen
      ..poly([_o(34, 62), _o(18, 84), _o(38, 78)], AppColors.coral)
      ..poly([_o(66, 62), _o(82, 84), _o(62, 78)], AppColors.coral)
      ..blob([_o(50, 90), _o(42, 98), _o(50, 96), _o(58, 98)], AppColors.sun)
      ..blob([
        _o(50, 4),
        _o(66, 30),
        _o(66, 60),
        _o(60, 86),
        _o(40, 86),
        _o(34, 60),
        _o(34, 30),
      ], AppColors.white)
      ..disc(_o(50, 42), 9, AppColors.brandBlue)
      ..poly([_o(50, 4), _o(61, 22), _o(39, 22)], AppColors.coral);
  }

  void _planet(InkPen pen) {
    void ring(double start, double sweep) {
      final canvas = pen.canvas
        ..save()
        ..translate(50, 50)
        ..rotate(-0.4);
      final oval = Rect.fromCenter(center: Offset.zero, width: 92, height: 26);
      for (final (color, width) in [
        (AppColors.ink, 8.5),
        (AppColors.sun, 4.0),
      ]) {
        canvas.drawArc(
          oval,
          start,
          sweep,
          false,
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = width,
        );
      }
      canvas.restore();
    }

    ring(pi, pi);
    pen
      ..disc(_o(50, 50), 31, AppColors.grape)
      ..blob([
        _o(30, 36),
        _o(50, 30),
        _o(72, 36),
        _o(70, 42),
        _o(48, 40),
        _o(30, 42),
      ], AppColors.grapeTint)
      ..blob([
        _o(28, 60),
        _o(50, 56),
        _o(74, 58),
        _o(66, 70),
        _o(44, 72),
      ], AppColors.coralTint);
    ring(0, pi);
  }

  void _fish(InkPen pen) {
    pen
      ..poly([_o(30, 50), _o(6, 28), _o(12, 50), _o(6, 72)], AppColors.sun)
      ..poly([_o(44, 30), _o(60, 12), _o(66, 32)], AppColors.sun)
      ..blob([
        _o(20, 50),
        _o(44, 28),
        _o(74, 30),
        _o(96, 50),
        _o(74, 70),
        _o(44, 72),
      ], AppColors.coral)
      ..line([_o(46, 32), _o(46, 68)], width: 3)
      ..line([_o(60, 30), _o(60, 70)], width: 3)
      ..eye(_o(78, 44), 4);
  }

  void _turtle(InkPen pen) {
    pen
      ..limb([_o(30, 68), _o(24, 80)], 10, AppColors.leaf)
      ..limb([_o(66, 68), _o(72, 80)], 10, AppColors.leaf)
      ..poly([_o(16, 62), _o(4, 66), _o(16, 70)], AppColors.leaf)
      ..blob([
        _o(74, 54),
        _o(88, 40),
        _o(98, 50),
        _o(92, 62),
        _o(76, 66),
      ], AppColors.leaf)
      ..blob([
        _o(12, 68),
        _o(26, 38),
        _o(48, 28),
        _o(68, 38),
        _o(82, 68),
      ], AppColors.buddyTealDeep)
      ..poly([
        _o(36, 48),
        _o(48, 40),
        _o(60, 48),
        _o(56, 60),
        _o(40, 60),
      ], AppColors.sun)
      ..eye(_o(90, 48), 3);
  }

  void _butterfly(InkPen pen) {
    pen
      ..blob([
        _o(48, 46),
        _o(30, 12),
        _o(8, 12),
        _o(6, 36),
        _o(26, 52),
      ], AppColors.grape)
      ..blob([
        _o(52, 46),
        _o(70, 12),
        _o(92, 12),
        _o(94, 36),
        _o(74, 52),
      ], AppColors.grape)
      ..blob([
        _o(48, 52),
        _o(26, 54),
        _o(14, 72),
        _o(28, 88),
        _o(46, 72),
      ], AppColors.sun)
      ..blob([
        _o(52, 52),
        _o(74, 54),
        _o(86, 72),
        _o(72, 88),
        _o(54, 72),
      ], AppColors.sun)
      ..disc(_o(24, 30), 7, AppColors.white)
      ..disc(_o(76, 30), 7, AppColors.white)
      ..line([_o(48, 26), _o(38, 8)])
      ..line([_o(52, 26), _o(62, 8)])
      ..blob([
        _o(50, 24),
        _o(55, 40),
        _o(54, 76),
        _o(50, 82),
        _o(46, 76),
        _o(45, 40),
      ], AppColors.ink);
  }

  void _flower(InkPen pen) {
    pen.limb([_o(50, 60), _o(50, 98)], 5, AppColors.leaf);
    pen.blob([_o(50, 86), _o(70, 68), _o(84, 70), _o(72, 86)], AppColors.leaf);
    for (final petal in [
      _o(50, 18),
      _o(72, 34),
      _o(64, 60),
      _o(36, 60),
      _o(28, 34),
    ]) {
      pen.disc(petal, 15, AppColors.coral);
    }
    pen.disc(_o(50, 40), 14, AppColors.sun);
  }

  void _tree(InkPen pen) {
    pen
      ..poly([
        _o(42, 62),
        _o(58, 62),
        _o(62, 96),
        _o(38, 96),
      ], const Color(0xFF9A6A3C))
      ..blob([
        _o(50, 4),
        _o(76, 14),
        _o(92, 38),
        _o(82, 64),
        _o(50, 72),
        _o(18, 64),
        _o(8, 38),
        _o(24, 14),
      ], AppColors.leaf)
      ..disc(_o(34, 34), 5, AppColors.coral)
      ..disc(_o(64, 26), 5, AppColors.coral)
      ..disc(_o(66, 52), 5, AppColors.coral)
      ..disc(_o(42, 56), 5, AppColors.coral);
  }

  void _whale(InkPen pen) {
    pen
      ..line([_o(66, 18), _o(66, 30)], width: 3)
      ..line([_o(66, 18), _o(56, 10)], width: 3)
      ..line([_o(66, 18), _o(76, 10)], width: 3)
      ..blob([
        _o(4, 24),
        _o(14, 34),
        _o(26, 24),
        _o(20, 44),
        _o(14, 46),
      ], AppColors.brandBlue)
      ..blob([
        _o(16, 42),
        _o(36, 34),
        _o(66, 30),
        _o(94, 50),
        _o(90, 72),
        _o(56, 82),
        _o(30, 70),
      ], AppColors.brandBlue)
      ..blob([
        _o(46, 72),
        _o(66, 66),
        _o(92, 62),
        _o(88, 74),
        _o(60, 82),
      ], AppColors.brandBlueTint)
      ..blob([
        _o(44, 70),
        _o(54, 72),
        _o(50, 90),
        _o(38, 88),
      ], AppColors.brandBlueDeep)
      ..eye(_o(76, 52), 3.5);
  }

  void _volcano(InkPen pen) {
    pen
      ..blob([
        _o(40, 28),
        _o(30, 10),
        _o(48, 14),
        _o(56, 4),
        _o(66, 16),
        _o(62, 28),
      ], AppColors.inkSoft)
      ..poly([
        _o(36, 32),
        _o(64, 32),
        _o(96, 92),
        _o(4, 92),
      ], const Color(0xFF9A6A3C))
      ..blob([
        _o(36, 32),
        _o(64, 32),
        _o(68, 52),
        _o(60, 46),
        _o(54, 66),
        _o(46, 48),
        _o(40, 56),
        _o(32, 44),
      ], AppColors.coral);
  }

  void _owl(InkPen pen) {
    pen
      ..poly([_o(24, 26), _o(22, 6), _o(42, 16)], AppColors.grape)
      ..poly([_o(76, 26), _o(78, 6), _o(58, 16)], AppColors.grape)
      ..blob([
        _o(50, 12),
        _o(80, 24),
        _o(84, 62),
        _o(66, 92),
        _o(34, 92),
        _o(16, 62),
        _o(20, 24),
      ], AppColors.grape)
      ..blob([
        _o(50, 54),
        _o(68, 62),
        _o(62, 86),
        _o(38, 86),
        _o(32, 62),
      ], AppColors.grapeTint)
      ..disc(_o(35, 36), 13, AppColors.white)
      ..disc(_o(65, 36), 13, AppColors.white)
      ..eye(_o(37, 36), 6)
      ..eye(_o(63, 36), 6)
      ..poly([_o(44, 46), _o(56, 46), _o(50, 56)], AppColors.sun);
  }

  void _mushroom(InkPen pen) {
    pen
      ..blob([
        _o(40, 50),
        _o(60, 50),
        _o(64, 88),
        _o(50, 94),
        _o(36, 88),
      ], AppColors.paper)
      ..blob([
        _o(6, 58),
        _o(14, 26),
        _o(50, 8),
        _o(86, 26),
        _o(94, 58),
        _o(50, 62),
      ], AppColors.coral)
      ..disc(_o(30, 36), 7, AppColors.white)
      ..disc(_o(56, 26), 8, AppColors.white)
      ..disc(_o(74, 44), 6, AppColors.white)
      ..disc(_o(48, 48), 5, AppColors.white);
  }

  void _sailboat(InkPen pen) {
    pen
      ..line([_o(50, 8), _o(50, 70)], width: 3.5)
      ..poly([_o(54, 10), _o(88, 62), _o(54, 62)], AppColors.white)
      ..poly([_o(46, 22), _o(46, 62), _o(16, 62)], AppColors.sun)
      ..poly([_o(8, 70), _o(92, 70), _o(76, 90), _o(24, 90)], AppColors.coral)
      ..blob([
        _o(0, 90),
        _o(16, 86),
        _o(34, 90),
        _o(50, 86),
        _o(66, 90),
        _o(84, 86),
        _o(100, 90),
        _o(100, 98),
        _o(0, 98),
      ], AppColors.brandBlue);
  }

  @override
  bool shouldRepaint(_PicturePainter old) => old.picture != picture;
}
