import 'dart:math';

import 'package:flutter/material.dart';

import '../../../domain/games/sound_game.dart';
import '../../core/themes/app_colors.dart';
import 'ink_pen.dart';

/// A drawing of what made a sound.
class SoundArt extends StatelessWidget {
  const SoundArt({super.key, required this.sound, this.size = 80});

  final GameSound sound;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: sound.title,
    child: CustomPaint(size: Size.square(size), painter: _SoundPainter(sound)),
  );
}

Offset _o(double x, double y) => Offset(x, y);

/// Drawn on a 100 by 100 grid.
class _SoundPainter extends CustomPainter {
  const _SoundPainter(this.sound);

  final GameSound sound;

  static const _brown = Color(0xFFB9743C);
  static const _brownDeep = Color(0xFF8A5F3A);
  static const _cloud = Color(0xFF8E96AB);
  static const _pink = Color(0xFFFFB3C1);
  static const _steel = Color(0xFF5B7EA3);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    final pen = InkPen(canvas, outline: 2.4);
    switch (sound) {
      case GameSound.rooster:
        _rooster(pen);
      case GameSound.cow:
        _cow(pen);
      case GameSound.sheep:
        _sheep(pen);
      case GameSound.dog:
        _dog(pen);
      case GameSound.cat:
        _cat(pen);
      case GameSound.frog:
        _frog(pen);
      case GameSound.bee:
        _bee(pen);
      case GameSound.thunder:
        _thunder(pen);
      case GameSound.rain:
        _rain(pen);
      case GameSound.sea:
        _sea(pen);
      case GameSound.train:
        _train(pen);
      case GameSound.helicopter:
        _helicopter(pen);
      case GameSound.clock:
        _clock(pen);
    }
  }

  void _rooster(InkPen pen) {
    pen
      ..line([_o(46, 76), _o(46, 94)], width: 3.5)
      ..line([_o(58, 76), _o(58, 94)], width: 3.5)
      ..blob([
        _o(30, 44),
        _o(8, 18),
        _o(4, 44),
        _o(14, 66),
        _o(32, 60),
      ], AppColors.leaf)
      ..blob([
        _o(24, 54),
        _o(44, 46),
        _o(60, 44),
        _o(62, 22),
        _o(78, 22),
        _o(82, 44),
        _o(74, 68),
        _o(50, 80),
        _o(32, 72),
      ], AppColors.coral)
      ..blob([
        _o(62, 22),
        _o(62, 10),
        _o(68, 14),
        _o(72, 6),
        _o(78, 14),
        _o(82, 22),
      ], AppColors.sun)
      ..poly([_o(82, 28), _o(96, 33), _o(82, 38)], AppColors.sun)
      ..blob([_o(78, 40), _o(84, 42), _o(82, 52), _o(76, 50)], AppColors.white)
      ..eye(_o(73, 29), 3);
  }

  void _cow(InkPen pen) {
    pen
      ..poly([_o(26, 26), _o(14, 8), _o(36, 18)], AppColors.sun)
      ..poly([_o(74, 26), _o(86, 8), _o(64, 18)], AppColors.sun)
      ..blob([_o(22, 32), _o(4, 26), _o(4, 40), _o(22, 44)], AppColors.white)
      ..blob([_o(78, 32), _o(96, 26), _o(96, 40), _o(78, 44)], AppColors.white)
      ..blob([
        _o(50, 14),
        _o(78, 24),
        _o(76, 62),
        _o(50, 70),
        _o(24, 62),
        _o(22, 24),
      ], AppColors.white)
      ..blob([_o(58, 15), _o(77, 24), _o(76, 44), _o(62, 42)], AppColors.ink)
      ..blob([
        _o(22, 66),
        _o(50, 56),
        _o(78, 66),
        _o(72, 90),
        _o(28, 90),
      ], _pink)
      ..disc(_o(40, 74), 3.5, AppColors.ink)
      ..disc(_o(60, 74), 3.5, AppColors.ink)
      ..eye(_o(38, 40), 4)
      ..disc(_o(64, 38), 4.5, AppColors.white)
      ..eye(_o(64, 38), 3);
  }

  void _sheep(InkPen pen) {
    pen
      ..limb([_o(36, 72), _o(36, 92)], 7, AppColors.ink)
      ..limb([_o(64, 72), _o(64, 92)], 7, AppColors.ink);
    for (final (x, y, r) in [
      (30.0, 40.0, 16.0),
      (52.0, 32.0, 18.0),
      (74.0, 42.0, 16.0),
      (22.0, 60.0, 15.0),
      (78.0, 62.0, 15.0),
      (40.0, 70.0, 16.0),
      (62.0, 72.0, 16.0),
      (50.0, 52.0, 22.0),
    ]) {
      pen.disc(_o(x, y), r, AppColors.paper);
    }
    pen
      ..blob([_o(30, 48), _o(14, 42), _o(14, 54), _o(28, 58)], AppColors.ink)
      ..blob([_o(70, 48), _o(86, 42), _o(86, 54), _o(72, 58)], AppColors.ink)
      ..blob([
        _o(50, 36),
        _o(68, 46),
        _o(62, 72),
        _o(50, 78),
        _o(38, 72),
        _o(32, 46),
      ], AppColors.inkSoft)
      ..disc(_o(42, 52), 5, AppColors.white)
      ..disc(_o(58, 52), 5, AppColors.white)
      ..eye(_o(42, 52), 3)
      ..eye(_o(58, 52), 3);
  }

  void _dog(InkPen pen) {
    pen
      ..blob([
        _o(50, 16),
        _o(78, 26),
        _o(80, 60),
        _o(50, 84),
        _o(20, 60),
        _o(22, 26),
      ], _brown)
      ..blob([
        _o(24, 20),
        _o(6, 22),
        _o(4, 56),
        _o(16, 66),
        _o(26, 46),
      ], _brownDeep)
      ..blob([
        _o(76, 20),
        _o(94, 22),
        _o(96, 56),
        _o(84, 66),
        _o(74, 46),
      ], _brownDeep)
      ..blob([
        _o(50, 48),
        _o(68, 60),
        _o(62, 78),
        _o(50, 82),
        _o(38, 78),
        _o(32, 60),
      ], AppColors.paper)
      ..blob([
        _o(50, 74),
        _o(58, 76),
        _o(56, 92),
        _o(44, 92),
        _o(42, 76),
      ], _pink)
      ..blob([_o(40, 52), _o(60, 52), _o(50, 64)], AppColors.ink)
      ..eye(_o(36, 40), 4.5)
      ..eye(_o(64, 40), 4.5);
  }

  void _cat(InkPen pen) {
    pen
      ..poly([_o(16, 44), _o(14, 6), _o(46, 24)], AppColors.backpack)
      ..poly([_o(84, 44), _o(86, 6), _o(54, 24)], AppColors.backpack)
      ..poly([_o(21, 32), _o(20, 15), _o(34, 25)], _pink)
      ..poly([_o(79, 32), _o(80, 15), _o(66, 25)], _pink)
      ..blob([
        _o(50, 20),
        _o(82, 34),
        _o(88, 62),
        _o(50, 90),
        _o(12, 62),
        _o(18, 34),
      ], AppColors.backpack)
      ..poly([_o(44, 60), _o(56, 60), _o(50, 67)], _pink)
      ..line([_o(50, 67), _o(44, 74)])
      ..line([_o(50, 67), _o(56, 74)])
      ..line([_o(32, 62), _o(6, 56)], width: 1.8)
      ..line([_o(32, 68), _o(6, 72)], width: 1.8)
      ..line([_o(68, 62), _o(94, 56)], width: 1.8)
      ..line([_o(68, 68), _o(94, 72)], width: 1.8)
      ..eye(_o(36, 46), 5.5)
      ..eye(_o(64, 46), 5.5);
  }

  void _frog(InkPen pen) {
    pen
      ..blob([_o(8, 86), _o(26, 66), _o(38, 90)], AppColors.leaf)
      ..blob([_o(92, 86), _o(74, 66), _o(62, 90)], AppColors.leaf)
      ..blob([
        _o(50, 28),
        _o(88, 44),
        _o(90, 72),
        _o(50, 92),
        _o(10, 72),
        _o(12, 44),
      ], AppColors.leaf)
      ..disc(_o(30, 30), 15, AppColors.leaf)
      ..disc(_o(70, 30), 15, AppColors.leaf)
      ..disc(_o(30, 30), 9, AppColors.white)
      ..disc(_o(70, 30), 9, AppColors.white)
      ..eye(_o(31, 30), 5.5)
      ..eye(_o(69, 30), 5.5)
      ..blob([_o(28, 62), _o(50, 72), _o(72, 62), _o(50, 80)], AppColors.ink);
  }

  void _bee(InkPen pen) {
    pen
      ..blob([
        _o(46, 40),
        _o(28, 8),
        _o(52, 8),
        _o(58, 38),
      ], AppColors.brandBlueTint)
      ..blob([
        _o(54, 40),
        _o(66, 12),
        _o(86, 20),
        _o(68, 42),
      ], AppColors.brandBlueTint)
      ..blob([
        _o(8, 62),
        _o(30, 38),
        _o(68, 38),
        _o(90, 60),
        _o(68, 84),
        _o(30, 84),
      ], AppColors.sun)
      ..blob([_o(34, 40), _o(46, 38), _o(48, 84), _o(34, 83)], AppColors.ink)
      ..blob([_o(58, 39), _o(68, 40), _o(70, 83), _o(58, 84)], AppColors.ink)
      ..line([_o(84, 50), _o(92, 34)])
      ..line([_o(88, 54), _o(98, 42)])
      ..eye(_o(79, 56), 3.5);
  }

  void _cloudShape(InkPen pen, Color color) {
    pen.blob([
      _o(14, 56),
      _o(8, 40),
      _o(24, 30),
      _o(36, 14),
      _o(60, 16),
      _o(76, 30),
      _o(92, 40),
      _o(86, 56),
    ], color);
  }

  void _thunder(InkPen pen) {
    _cloudShape(pen, _cloud);
    pen.poly([
      _o(56, 44),
      _o(34, 72),
      _o(48, 72),
      _o(38, 98),
      _o(70, 62),
      _o(54, 62),
      _o(66, 44),
    ], AppColors.sun);
  }

  void _rain(InkPen pen) {
    _cloudShape(pen, AppColors.brandBlueTint);
    for (final (x, y) in [
      (24.0, 66.0),
      (46.0, 72.0),
      (68.0, 66.0),
      (34.0, 84.0),
      (58.0, 88.0),
      (80.0, 80.0),
    ]) {
      pen.blob([
        _o(x, y - 8),
        _o(x + 5, y + 2),
        _o(x, y + 7),
        _o(x - 5, y + 2),
      ], AppColors.brandBlue);
    }
  }

  void _sea(InkPen pen) {
    pen
      ..disc(_o(74, 20), 13, AppColors.sun)
      ..poly([
        _o(2, 40),
        _o(98, 40),
        _o(98, 96),
        _o(2, 96),
      ], AppColors.brandBlue);
    for (final y in [54.0, 70.0, 86.0]) {
      pen.limb(
        [for (var x = 8.0; x <= 92; x += 4) _o(x, y + 4 * sin(x / 6 + y))],
        3,
        AppColors.white,
      );
    }
  }

  void _train(InkPen pen) {
    pen
      ..blob([
        _o(24, 18),
        _o(30, 6),
        _o(44, 8),
        _o(50, 18),
        _o(38, 24),
      ], AppColors.white)
      ..poly([_o(28, 28), _o(40, 28), _o(38, 44), _o(30, 44)], AppColors.ink)
      ..blob([_o(14, 44), _o(58, 44), _o(60, 72), _o(14, 72)], AppColors.coral)
      ..poly([_o(58, 24), _o(92, 24), _o(92, 72), _o(58, 72)], AppColors.leaf)
      ..poly([_o(54, 20), _o(96, 20), _o(96, 26), _o(54, 26)], AppColors.ink)
      ..poly([
        _o(66, 32),
        _o(84, 32),
        _o(84, 50),
        _o(66, 50),
      ], AppColors.sunTint)
      ..poly([_o(6, 62), _o(14, 58), _o(14, 74), _o(6, 74)], AppColors.sun)
      ..disc(_o(30, 80), 12, AppColors.ink)
      ..disc(_o(30, 80), 5, AppColors.sun)
      ..disc(_o(72, 80), 12, AppColors.ink)
      ..disc(_o(72, 80), 5, AppColors.sun);
  }

  void _helicopter(InkPen pen) {
    pen
      ..line([_o(8, 14), _o(92, 14)], width: 5)
      ..line([_o(50, 14), _o(50, 30)], width: 5)
      ..poly([_o(50, 44), _o(4, 36), _o(4, 50), _o(50, 60)], _steel)
      ..line([_o(4, 28), _o(4, 56)], width: 4)
      ..blob([
        _o(30, 44),
        _o(50, 28),
        _o(80, 30),
        _o(96, 54),
        _o(84, 74),
        _o(44, 74),
      ], AppColors.sun)
      ..blob([
        _o(66, 34),
        _o(82, 36),
        _o(92, 54),
        _o(66, 54),
      ], AppColors.brandBlueTint)
      ..line([_o(44, 76), _o(40, 90)], width: 3.5)
      ..line([_o(78, 76), _o(82, 90)], width: 3.5)
      ..line([_o(26, 90), _o(96, 90)], width: 4.5);
  }

  void _clock(InkPen pen) {
    pen
      ..disc(_o(50, 50), 44, AppColors.brandBlue)
      ..disc(_o(50, 50), 35, AppColors.white);
    for (final (a, b) in [
      (_o(50, 19), _o(50, 25)),
      (_o(50, 75), _o(50, 81)),
      (_o(19, 50), _o(25, 50)),
      (_o(75, 50), _o(81, 50)),
    ]) {
      pen.line([a, b], width: 3);
    }
    pen
      ..line([_o(50, 50), _o(50, 28)], width: 4)
      ..line([_o(50, 50), _o(66, 58)], width: 4)
      ..disc(_o(50, 50), 4, AppColors.coral);
  }

  @override
  bool shouldRepaint(_SoundPainter old) => old.sound != sound;
}
