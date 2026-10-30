import 'package:flutter/material.dart';

import '../../../domain/games/dino.dart';
import '../../core/themes/app_colors.dart';
import 'ink_pen.dart';

/// Earthy dinosaur skin colours, used only in these drawings.
abstract final class _Skin {
  static const olive = Color(0xFF8DB255);
  static const oliveDeep = Color(0xFF668A3A);
  static const slate = Color(0xFF7FA3C7);
  static const slateDeep = Color(0xFF5B7EA3);
  static const rust = Color(0xFFD9774A);
  static const rustDeep = Color(0xFFAF5730);
  static const moss = Color(0xFF5F9E78);
  static const mossDeep = Color(0xFF437A59);
  static const sand = Color(0xFFE5B36A);
  static const sandDeep = Color(0xFFBE8A45);
  static const clay = Color(0xFFB98A68);
  static const clayDeep = Color(0xFF8F6848);
  static const plum = Color(0xFFA487D9);
  static const plumDeep = Color(0xFF7D62B0);
  static const sea = Color(0xFF3E9BB0);
  static const seaDeep = Color(0xFF2B7387);
  static const lagoon = Color(0xFF5BC0A8);
  static const lagoonDeep = Color(0xFF3B9580);
  static const bone = Color(0xFFFFF3DC);
}

/// A drawn creature. With [hidden] it is a plain silhouette, for the Field
/// Guide entries not found yet.
class DinoArt extends StatelessWidget {
  const DinoArt({
    super.key,
    required this.creature,
    this.width = 120,
    this.hidden = false,
  });

  final DinoCreature creature;
  final double width;
  final bool hidden;

  static const aspect = 10 / 7;

  @override
  Widget build(BuildContext context) {
    final art = CustomPaint(
      size: Size(width, width / aspect),
      painter: _DinoPainter(creature),
    );
    return Semantics(
      image: true,
      label: hidden ? 'A creature not found yet' : creature.name,
      child: hidden
          ? ColorFiltered(
              colorFilter: const ColorFilter.mode(
                AppColors.inkSoft,
                BlendMode.srcIn,
              ),
              child: art,
            )
          : art,
    );
  }
}

Offset _o(double x, double y) => Offset(x, y);

/// Creatures are drawn side-on, facing right, on a 100 by 70 grid.
class _DinoPainter extends CustomPainter {
  const _DinoPainter(this.creature);

  final DinoCreature creature;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    final pen = InkPen(canvas);
    switch (creature) {
      case DinoCreature.stegosaurus:
        _stegosaurus(pen);
      case DinoCreature.diplodocus:
        _diplodocus(pen);
      case DinoCreature.allosaurus:
        _allosaurus(pen);
      case DinoCreature.tyrannosaurus:
        _tyrannosaurus(pen);
      case DinoCreature.triceratops:
        _triceratops(pen);
      case DinoCreature.ankylosaurus:
        _ankylosaurus(pen);
      case DinoCreature.pteranodon:
        _pteranodon(pen);
      case DinoCreature.mosasaurus:
        _mosasaurus(pen);
      case DinoCreature.elasmosaurus:
        _elasmosaurus(pen);
    }
  }

  void _stegosaurus(InkPen pen) {
    pen
      ..limb([_o(38, 48), _o(40, 65)], 8, _Skin.oliveDeep)
      ..limb([_o(70, 46), _o(72, 65)], 6, _Skin.oliveDeep);
    for (final (x, y, h) in [
      (24.0, 31.0, 9.0),
      (32.0, 25.0, 13.0),
      (42.0, 21.0, 16.0),
      (52.0, 20.0, 16.0),
      (62.0, 23.0, 13.0),
      (71.0, 29.0, 10.0),
    ]) {
      pen.poly([
        _o(x - 5, y + 3),
        _o(x - 3, y - h * 0.6),
        _o(x + 1, y - h),
        _o(x + 5, y - h * 0.5),
        _o(x + 5, y + 3),
      ], AppColors.coral);
    }
    pen
      ..poly([_o(8, 41), _o(1, 28), _o(12, 37)], _Skin.bone)
      ..poly([_o(13, 38), _o(9, 25), _o(18, 34)], _Skin.bone)
      ..poly([_o(4, 44), _o(0, 56), _o(10, 46)], _Skin.bone)
      ..poly([_o(10, 44), _o(9, 56), _o(16, 43)], _Skin.bone)
      ..blob([
        _o(3, 43),
        _o(20, 35),
        _o(35, 25),
        _o(50, 21),
        _o(65, 25),
        _o(78, 35),
        _o(90, 37),
        _o(98, 43),
        _o(90, 48),
        _o(78, 47),
        _o(66, 52),
        _o(48, 55),
        _o(30, 52),
        _o(16, 46),
      ], _Skin.olive)
      ..limb([_o(30, 48), _o(30, 65)], 9, _Skin.olive)
      ..limb([_o(62, 48), _o(62, 65)], 7, _Skin.olive)
      ..eye(_o(90, 41), 1.6);
  }

  void _diplodocus(InkPen pen) {
    pen
      ..limb([_o(42, 48), _o(43, 65)], 7, _Skin.slateDeep)
      ..limb([_o(64, 46), _o(65, 65)], 7, _Skin.slateDeep)
      ..blob([
        _o(1, 56),
        _o(16, 46),
        _o(30, 37),
        _o(44, 31),
        _o(58, 32),
        _o(68, 30),
        _o(76, 19),
        _o(84, 9),
        _o(92, 4),
        _o(99, 7),
        _o(98, 11),
        _o(91, 13),
        _o(85, 22),
        _o(78, 37),
        _o(68, 49),
        _o(52, 53),
        _o(38, 52),
        _o(24, 50),
        _o(12, 53),
      ], _Skin.slate)
      ..limb([_o(35, 48), _o(35, 65)], 8, _Skin.slate)
      ..limb([_o(57, 47), _o(57, 65)], 8, _Skin.slate)
      ..eye(_o(93, 7.5), 1.3);
  }

  void _allosaurus(InkPen pen) {
    pen
      ..limb(
        [_o(46, 42), _o(54, 54), _o(50, 66), _o(56, 66)],
        6,
        _Skin.rustDeep,
      )
      // The bony horn above the eye.
      ..poly([_o(72, 10), _o(75, 2), _o(79, 10)], AppColors.sun)
      ..blob([
        _o(1, 32),
        _o(20, 26),
        _o(36, 22),
        _o(50, 18),
        _o(62, 13),
        _o(74, 9),
        _o(90, 12),
        _o(98, 18),
        _o(97, 23),
        _o(82, 26),
        _o(72, 29),
        _o(68, 38),
        _o(56, 46),
        _o(42, 45),
        _o(26, 39),
        _o(12, 35),
      ], _Skin.rust)
      ..poly([
        _o(80, 25),
        _o(82, 22),
        _o(84, 25),
        _o(86, 22),
        _o(88, 24),
        _o(90, 21),
        _o(92, 24),
      ], _Skin.bone)
      // A long arm with big claws.
      ..limb([_o(66, 34), _o(72, 42), _o(79, 42)], 3, _Skin.rust)
      ..poly([_o(80, 40), _o(86, 41), _o(81, 42)], _Skin.bone)
      ..poly([_o(80, 42), _o(86, 45), _o(80, 44)], _Skin.bone)
      ..limb([_o(38, 42), _o(44, 54), _o(38, 66), _o(45, 66)], 7, _Skin.rust)
      ..eye(_o(79, 14), 1.8);
  }

  void _tyrannosaurus(InkPen pen) {
    pen
      ..limb(
        [_o(44, 44), _o(52, 56), _o(48, 66), _o(55, 66)],
        7,
        _Skin.mossDeep,
      )
      ..blob([
        _o(1, 34),
        _o(18, 28),
        _o(34, 23),
        _o(46, 19),
        _o(56, 12),
        _o(68, 5),
        _o(88, 6),
        _o(99, 13),
        _o(99, 27),
        _o(86, 33),
        _o(72, 33),
        _o(66, 40),
        _o(56, 49),
        _o(42, 48),
        _o(26, 41),
        _o(12, 37),
      ], _Skin.moss)
      ..line([_o(72, 23), _o(98, 21)])
      ..poly([
        _o(76, 22.5),
        _o(78, 26),
        _o(81, 22.5),
        _o(83, 26),
        _o(86, 22),
        _o(88, 25.5),
        _o(91, 22),
        _o(93, 25),
        _o(96, 21.5),
      ], _Skin.bone)
      // A tiny two-fingered arm.
      ..limb([_o(64, 39), _o(69, 42)], 2.5, _Skin.moss)
      ..line([_o(71, 41.5), _o(74, 41)], width: 1.2)
      ..line([_o(71, 43), _o(74, 44)], width: 1.2)
      ..limb([_o(36, 45), _o(42, 56), _o(36, 66), _o(44, 66)], 9, _Skin.moss)
      ..eye(_o(78, 12), 2);
  }

  void _triceratops(InkPen pen) {
    pen
      ..limb([_o(36, 48), _o(36, 65)], 9, _Skin.sandDeep)
      ..limb([_o(62, 48), _o(63, 65)], 8, _Skin.sandDeep)
      ..blob([
        _o(2, 48),
        _o(16, 38),
        _o(34, 29),
        _o(52, 26),
        _o(66, 28),
        _o(72, 42),
        _o(68, 52),
        _o(50, 56),
        _o(30, 54),
        _o(14, 50),
      ], _Skin.sand)
      ..limb([_o(28, 50), _o(28, 65)], 10, _Skin.sand)
      ..limb([_o(55, 50), _o(55, 65)], 9, _Skin.sand)
      // The big frill.
      ..blob([
        _o(60, 40),
        _o(58, 24),
        _o(66, 12),
        _o(76, 12),
        _o(80, 24),
        _o(76, 40),
        _o(68, 48),
      ], AppColors.coral)
      // The far brow horn sits behind the head, the near one in front.
      ..poly([_o(78, 28), _o(91, 8), _o(84, 30)], _Skin.bone)
      ..blob([
        _o(66, 38),
        _o(76, 28),
        _o(88, 32),
        _o(97, 44),
        _o(92, 52),
        _o(78, 52),
        _o(68, 48),
      ], _Skin.sand)
      ..poly([_o(74, 29), _o(84, 7), _o(81, 30)], _Skin.bone)
      // The short nose horn.
      ..poly([_o(88, 35), _o(94, 25), _o(93, 40)], _Skin.bone)
      ..poly([_o(93, 44), _o(100, 47), _o(93, 52)], _Skin.sandDeep)
      ..eye(_o(82, 36), 1.7);
  }

  void _ankylosaurus(InkPen pen) {
    pen
      ..limb([_o(36, 50), _o(36, 65)], 8, _Skin.clayDeep)
      ..limb([_o(66, 50), _o(66, 65)], 8, _Skin.clayDeep)
      ..limb([_o(26, 46), _o(8, 40)], 5, _Skin.clay)
      // The tail club.
      ..blob([
        _o(1, 40),
        _o(6, 32),
        _o(13, 35),
        _o(14, 44),
        _o(7, 48),
      ], _Skin.bone)
      ..blob([
        _o(16, 50),
        _o(26, 38),
        _o(42, 30),
        _o(60, 30),
        _o(76, 36),
        _o(88, 40),
        _o(98, 46),
        _o(96, 53),
        _o(82, 55),
        _o(60, 58),
        _o(36, 58),
      ], _Skin.clay)
      ..limb([_o(30, 54), _o(30, 65)], 9, _Skin.clay)
      ..limb([_o(58, 54), _o(58, 65)], 9, _Skin.clay);
    // Rows of bony armour.
    for (final (x, y) in [
      (29.0, 37.0),
      (40.0, 31.0),
      (52.0, 29.0),
      (64.0, 31.0),
      (75.0, 36.0),
    ]) {
      pen.poly([_o(x - 4, y + 2), _o(x, y - 6), _o(x + 4, y + 2)], _Skin.bone);
    }
    for (final (x, y) in [
      (28.0, 46.0),
      (40.0, 42.0),
      (52.0, 41.0),
      (64.0, 42.0),
      (76.0, 45.0),
      (34.0, 52.0),
      (46.0, 51.0),
      (58.0, 51.0),
      (70.0, 51.0),
    ]) {
      pen.disc(_o(x, y), 3, _Skin.sand);
    }
    pen.eye(_o(90, 45), 1.5);
  }

  void _pteranodon(InkPen pen) {
    pen
      // The far wing, lifted behind the body.
      ..blob([
        _o(50, 30),
        _o(62, 16),
        _o(78, 4),
        _o(70, 22),
        _o(60, 34),
      ], _Skin.plumDeep)
      // The near wing, stretched out long.
      ..blob([
        _o(58, 34),
        _o(40, 26),
        _o(20, 26),
        _o(1, 38),
        _o(22, 42),
        _o(40, 50),
        _o(54, 46),
      ], _Skin.plum)
      ..blob([
        _o(40, 44),
        _o(52, 34),
        _o(66, 32),
        _o(70, 40),
        _o(58, 48),
      ], _Skin.plum)
      // The long crest behind the head, and the long toothless beak.
      ..poly([_o(70, 30), _o(46, 15), _o(74, 25)], AppColors.coral)
      ..poly([_o(76, 25), _o(99, 33), _o(76, 33)], AppColors.sun)
      ..blob([
        _o(64, 36),
        _o(68, 27),
        _o(76, 24),
        _o(81, 29),
        _o(76, 35),
        _o(70, 38),
      ], _Skin.plum)
      ..eye(_o(75, 28.5), 1.4)
      ..limb([_o(42, 47), _o(36, 54)], 2, _Skin.plumDeep);
  }

  void _mosasaurus(InkPen pen) {
    pen
      ..blob([_o(58, 42), _o(62, 44), _o(56, 60), _o(46, 62)], _Skin.seaDeep)
      ..blob([
        _o(1, 22),
        _o(10, 34),
        _o(26, 31),
        _o(44, 27),
        _o(64, 26),
        _o(84, 30),
        _o(99, 37),
        _o(84, 39),
        _o(99, 41),
        _o(84, 46),
        _o(60, 49),
        _o(40, 48),
        _o(22, 46),
        _o(10, 44),
        _o(1, 56),
        _o(5, 40),
      ], _Skin.sea)
      ..poly([
        _o(83, 39),
        _o(85, 42),
        _o(87, 39.5),
        _o(89, 42),
        _o(91, 40),
        _o(93, 41.5),
        _o(95, 40.2),
      ], _Skin.bone)
      ..blob([_o(34, 44), _o(38, 46), _o(30, 58), _o(22, 60)], _Skin.sea)
      ..blob([_o(64, 44), _o(68, 46), _o(64, 62), _o(54, 62)], _Skin.sea)
      ..eye(_o(82, 34), 1.7);
  }

  void _elasmosaurus(InkPen pen) {
    pen
      ..blob([_o(24, 50), _o(28, 50), _o(20, 66), _o(10, 68)], _Skin.lagoonDeep)
      ..blob([_o(50, 50), _o(54, 50), _o(60, 66), _o(50, 68)], _Skin.lagoonDeep)
      ..blob([
        _o(1, 50),
        _o(14, 44),
        _o(28, 38),
        _o(44, 37),
        _o(56, 38),
        _o(66, 28),
        _o(70, 16),
        _o(80, 6),
        _o(91, 4),
        _o(99, 8),
        _o(92, 12),
        _o(82, 13),
        _o(76, 22),
        _o(72, 36),
        _o(64, 48),
        _o(50, 55),
        _o(32, 56),
        _o(16, 53),
      ], _Skin.lagoon)
      ..blob([_o(30, 52), _o(35, 52), _o(30, 67), _o(19, 69)], _Skin.lagoon)
      ..blob([_o(56, 50), _o(61, 49), _o(68, 64), _o(58, 68)], _Skin.lagoon)
      ..eye(_o(91, 7.5), 1.4);
  }

  @override
  bool shouldRepaint(_DinoPainter old) => old.creature != creature;
}

/// The background of a place. Creatures and search spots are placed on top.
class DinoScene extends StatelessWidget {
  const DinoScene({super.key, required this.place, this.children = const []});

  final DinoPlace place;
  final List<Widget> children;

  static const aspect = 16 / 10;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: aspect,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _ScenePainter(place)),
          ...children,
        ],
      ),
    ),
  );
}

/// Scenes are painted on a 160 by 100 grid.
class _ScenePainter extends CustomPainter {
  const _ScenePainter(this.place);

  final DinoPlace place;

  static const _fern = Color(0xFF3E8E5A);
  static const _fernDark = Color(0xFF2C6E45);
  static const _trunk = Color(0xFF8A5F3A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 160, size.height / 100);
    final pen = InkPen(canvas, outline: 1);
    switch (place) {
      case DinoPlace.fernForest:
        _forest(canvas, pen);
      case DinoPlace.openPlains:
        _plains(canvas, pen);
      case DinoPlace.ancientSea:
        _sea(canvas, pen);
    }
  }

  void _sky(Canvas canvas, Color top, Color bottom, double height) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, 160, height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ).createShader(Rect.fromLTWH(0, 0, 160, height)),
    );
  }

  void _fernPlant(InkPen pen, Offset base, double size, Color color) {
    for (final tip in [-1.0, -0.55, 0.0, 0.55, 1.0]) {
      final end = base + Offset(tip * size, -(1.2 - tip.abs() * 0.7) * size);
      pen.blob([
        base,
        Offset.lerp(base, end, 0.5)! + Offset(-size * 0.14, -size * 0.1),
        end,
        Offset.lerp(base, end, 0.5)! + Offset(size * 0.14, size * 0.08),
      ], color);
    }
  }

  void _palm(InkPen pen, double x, double top) {
    pen.limb([_o(x, 76), _o(x + 2, top)], 4, _trunk);
    _fernPlant(pen, _o(x + 2, top + 2), 18, _fernDark);
  }

  void _forest(Canvas canvas, InkPen pen) {
    _sky(canvas, const Color(0xFFBDE7E2), const Color(0xFFE9F5C8), 70);
    canvas.drawCircle(_o(132, 16), 9, Paint()..color = const Color(0xFFFFE27A));
    pen
      ..blob([
        _o(-10, 60),
        _o(30, 40),
        _o(70, 54),
        _o(112, 38),
        _o(170, 58),
        _o(170, 80),
        _o(-10, 80),
      ], const Color(0xFFA6D69B))
      ..blob([
        _o(-20, 72),
        _o(60, 62),
        _o(180, 68),
        _o(180, 110),
        _o(-20, 110),
      ], const Color(0xFF8FC96E));
    _palm(pen, 18, 26);
    _palm(pen, 112, 22);
    _palm(pen, 146, 34);
    _fernPlant(pen, _o(8, 98), 16, _fern);
    _fernPlant(pen, _o(66, 98), 13, _fern);
    _fernPlant(pen, _o(152, 98), 15, _fern);
  }

  void _plains(Canvas canvas, InkPen pen) {
    _sky(canvas, const Color(0xFFFFD8A8), const Color(0xFFFFF1CF), 68);
    pen
      ..blob([
        _o(84, 14),
        _o(76, 4),
        _o(90, 2),
        _o(104, -2),
        _o(112, 8),
        _o(98, 16),
      ], const Color(0xFF9A93A8))
      ..poly([
        _o(86, 18),
        _o(100, 18),
        _o(136, 66),
        _o(50, 66),
      ], const Color(0xFF9B6F55))
      ..poly([
        _o(86, 18),
        _o(100, 18),
        _o(104, 32),
        _o(97, 28),
        _o(93, 40),
        _o(89, 28),
        _o(83, 32),
      ], AppColors.coral)
      ..blob([
        _o(-20, 66),
        _o(60, 60),
        _o(180, 64),
        _o(180, 110),
        _o(-20, 110),
      ], const Color(0xFFD9C66C));
    for (final (x, y) in [
      (14.0, 90.0),
      (42.0, 78.0),
      (76.0, 92.0),
      (112.0, 80.0),
      (146.0, 92.0),
    ]) {
      _fernPlant(pen, _o(x, y), 7, const Color(0xFF9AA84A));
    }
  }

  void _sea(Canvas canvas, InkPen pen) {
    _sky(canvas, const Color(0xFFB7E3FF), const Color(0xFFE6F6FF), 36);
    canvas
      ..drawCircle(_o(28, 14), 8, Paint()..color = const Color(0xFFFFE27A))
      ..drawRect(
        Rect.fromLTWH(0, 34, 160, 66),
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6CC7E0), Color(0xFF2F86B5)],
          ).createShader(Rect.fromLTWH(0, 34, 160, 66)),
      );
    for (final x in [0.0, 20.0, 40.0, 60.0, 80.0, 100.0, 120.0, 140.0]) {
      final wave = Path()
        ..moveTo(x, 34)
        ..quadraticBezierTo(x + 10, 29, x + 20, 34);
      canvas.drawPath(
        wave,
        Paint()
          ..color = AppColors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
    pen.blob([
      _o(-20, 96),
      _o(50, 90),
      _o(110, 95),
      _o(180, 90),
      _o(180, 112),
      _o(-20, 112),
    ], const Color(0xFFE5CE93));
    for (final x in [14.0, 78.0, 142.0]) {
      pen
        ..limb([_o(x, 96), _o(x - 4, 86)], 2, AppColors.coral)
        ..limb([_o(x, 96), _o(x + 4, 84)], 2, AppColors.coral);
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.place != place;
}
