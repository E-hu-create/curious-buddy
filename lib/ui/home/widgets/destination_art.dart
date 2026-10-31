import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';
import '../../games/widgets/ink_pen.dart';
import '../home_destination.dart';

Offset _o(double x, double y) => Offset(x, y);

const _sand = Color(0xFFF3D9A4);
const _wood = Color(0xFFB9772E);
const _lens = Color(0xFFBFE6FF);

/// The picture at the top of a Home card: a small drawn scene of what is
/// inside. Decorative only; the card's title says where it goes.
class DestinationArt extends StatelessWidget {
  const DestinationArt({super.key, required this.destination});

  final HomeDestination destination;

  static const height = 104.0;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.ink, width: AppShapes.outlineWidth),
      ),
      child: CustomPaint(
        size: Size.infinite,
        painter: _ScenePainter(destination),
      ),
    ),
  );
}

/// Paints a full-width sky and ground, then the scene, drawn on a 160 by
/// 100 grid and scaled to fit the middle of the banner.
class _ScenePainter extends CustomPainter {
  const _ScenePainter(this.destination);

  final HomeDestination destination;

  @override
  void paint(Canvas canvas, Size size) {
    final (sky, ground, groundTop) = switch (destination) {
      HomeDestination.missions => (AppColors.brandBlueTint, _sand, 0.72),
      HomeDestination.stories => (AppColors.arcade, null, 1.0),
      HomeDestination.storyMaker => (AppColors.grapeTint, null, 1.0),
      HomeDestination.quiz => (AppColors.brandBlue, null, 1.0),
      HomeDestination.games => (AppColors.coral, null, 1.0),
      HomeDestination.creative => (
        AppColors.brandBlueTint,
        AppColors.brandBlue,
        0.74,
      ),
      HomeDestination.discoveries => (AppColors.arcadeGlow, null, 1.0),
      HomeDestination.wardrobe => (AppColors.white, AppColors.grapeTint, 0.82),
    };
    canvas.drawRect(Offset.zero & size, Paint()..color = sky);
    if (ground != null) {
      canvas.drawRect(
        Rect.fromLTRB(0, size.height * groundTop, size.width, size.height),
        Paint()..color = ground,
      );
    }

    final scale = min(size.width / 160, size.height / 100);
    canvas
      ..save()
      ..translate(
        (size.width - 160 * scale) / 2,
        (size.height - 100 * scale) / 2,
      )
      ..scale(scale);
    final pen = InkPen(canvas, outline: 2.2);
    switch (destination) {
      case HomeDestination.missions:
        _missions(canvas, pen);
      case HomeDestination.stories:
        _stories(canvas, pen);
      case HomeDestination.storyMaker:
        _storyMaker(canvas, pen);
      case HomeDestination.quiz:
        _quiz(canvas, pen);
      case HomeDestination.games:
        _games(canvas, pen);
      case HomeDestination.creative:
        _creative(canvas, pen);
      case HomeDestination.discoveries:
        _discoveries(canvas, pen);
      case HomeDestination.wardrobe:
        _wardrobe(canvas, pen);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) =>
      oldDelegate.destination != destination;
}

// ------------------------------------------------------------- helpers

/// A rectangle turned by [angle] radians around its centre.
List<Offset> _card(Offset center, double w, double h, double angle) {
  final c = cos(angle), s = sin(angle);
  return [
    for (final (x, y) in [
      (-w / 2, -h / 2),
      (w / 2, -h / 2),
      (w / 2, h / 2),
      (-w / 2, h / 2),
    ])
      center + Offset(x * c - y * s, x * s + y * c),
  ];
}

List<Offset> _star(Offset center, double outer, [double inner = 0.45]) => [
  for (var i = 0; i < 10; i++)
    center +
        Offset.fromDirection(
          -pi / 2 + i * pi / 5,
          i.isEven ? outer : outer * inner,
        ),
];

void _text(
  Canvas canvas,
  String text,
  Offset center,
  double size,
  Color color, {
  double angle = 0,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: 'Nunito',
        fontWeight: FontWeight.w800,
        fontSize: size,
        height: 1,
        color: color,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  canvas
    ..save()
    ..translate(center.dx, center.dy)
    ..rotate(angle);
  painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
  canvas.restore();
}

void _footprint(InkPen pen, Offset at, double size, Color fill) {
  pen
    ..blob([
      at + Offset(-size * 0.5, 0),
      at + Offset(0, -size * 0.9),
      at + Offset(size * 0.5, 0),
      at + Offset(0, size * 0.8),
    ], fill)
    ..disc(at + Offset(-size * 0.45, -size * 1.25), size * 0.2, fill)
    ..disc(at + Offset(0, -size * 1.45), size * 0.22, fill)
    ..disc(at + Offset(size * 0.45, -size * 1.25), size * 0.2, fill);
}

// -------------------------------------------------------------- scenes

/// A magnifying glass over a trail of footprints, and a note with a clue.
void _missions(Canvas canvas, InkPen pen) {
  for (final (x, y) in [
    (12.0, 92.0),
    (28.0, 84.0),
    (44.0, 92.0),
    (60.0, 84.0),
  ]) {
    _footprint(pen, _o(x, y), 4, AppColors.inkSoft);
  }
  pen.poly(_card(_o(30, 34), 34, 34, -0.18), AppColors.white);
  _text(canvas, '?', _o(30, 35), 28, AppColors.coral, angle: -0.18);
  pen
    ..limb([_o(118, 62), _o(142, 90)], 10, _wood)
    ..disc(_o(100, 44), 30, AppColors.sun)
    ..disc(_o(100, 44), 22, _lens);
  _footprint(pen, _o(100, 52), 7, AppColors.inkSoft);
  canvas.drawArc(
    Rect.fromCircle(center: _o(100, 44), radius: 16),
    pi * 1.1,
    pi * 0.4,
    false,
    Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round,
  );
}

/// An open book at night, with a castle, a tree and stars rising out.
void _stories(Canvas canvas, InkPen pen) {
  for (final (x, y, r) in [
    (16.0, 16.0, 4.0),
    (62.0, 10.0, 3.0),
    (96.0, 22.0, 3.5),
    (150.0, 44.0, 3.0),
    (10.0, 52.0, 3.0),
  ]) {
    pen.poly(_star(_o(x, y), r), AppColors.sun);
  }
  pen
    ..disc(_o(132, 18), 10, AppColors.white)
    ..disc(_o(137, 14), 8, AppColors.arcade);
  // Castle on the left page.
  pen
    ..poly([_o(34, 50), _o(56, 50), _o(56, 82), _o(34, 82)], AppColors.coral)
    ..poly([_o(31, 50), _o(45, 30), _o(59, 50)], AppColors.grape)
    ..line([_o(45, 30), _o(45, 20)], width: 2)
    ..poly([_o(45, 20), _o(54, 23), _o(45, 26)], AppColors.sun)
    ..poly([_o(41, 66), _o(49, 66), _o(49, 82), _o(41, 82)], AppColors.ink);
  // Tree on the right page.
  pen
    ..limb([_o(112, 84), _o(112, 60)], 6, _wood)
    ..blob([
      _o(96, 54),
      _o(102, 38),
      _o(118, 34),
      _o(128, 48),
      _o(122, 62),
      _o(104, 64),
    ], AppColors.leaf);
  // The book.
  pen
    ..poly([_o(14, 80), _o(78, 76), _o(80, 98), _o(16, 98)], AppColors.white)
    ..poly([_o(82, 76), _o(146, 80), _o(144, 98), _o(80, 98)], AppColors.white)
    ..line([_o(80, 76), _o(80, 98)], width: 2.5);
  for (final y in [84.0, 90.0]) {
    pen
      ..line([_o(26, y), _o(68, y - 2)], width: 1.4)
      ..line([_o(92, y - 2), _o(134, y)], width: 1.4);
  }
}

/// Three picture cards (a hero, a place, a mystery) and a magic wand.
void _storyMaker(Canvas canvas, InkPen pen) {
  pen.poly(_card(_o(36, 54), 36, 50, -0.28), AppColors.white);
  pen.poly(_star(_o(36, 54), 12), AppColors.sun);
  pen.poly(_card(_o(68, 48), 36, 50, 0), AppColors.white);
  pen
    ..poly([_o(54, 64), _o(64, 40), _o(74, 64)], AppColors.leaf)
    ..poly([_o(64, 64), _o(74, 46), _o(84, 64)], AppColors.buddyTeal);
  pen.poly(_card(_o(100, 54), 36, 50, 0.28), AppColors.white);
  _text(canvas, '?', _o(100, 55), 30, AppColors.grape, angle: 0.28);
  pen
    ..limb([_o(118, 92), _o(146, 34)], 6, AppColors.ink)
    ..limb([_o(142, 42), _o(146, 34)], 6, AppColors.white);
  for (final (x, y, r) in [
    (146.0, 22.0, 8.0),
    (130.0, 16.0, 4.5),
    (156.0, 40.0, 4.0),
  ]) {
    pen.poly(_star(_o(x, y), r), AppColors.sun);
  }
}

/// A question card with three answers, one ticked, and stars.
void _quiz(Canvas canvas, InkPen pen) {
  pen.poly([_o(40, 10), _o(120, 10), _o(120, 56), _o(40, 56)], AppColors.white);
  _text(canvas, '?', _o(80, 34), 38, AppColors.brandBlueDeep);
  for (final (i, x) in [24.0, 64.0, 104.0].indexed) {
    pen.poly([
      _o(x, 66),
      _o(x + 34, 66),
      _o(x + 34, 88),
      _o(x, 88),
    ], i == 1 ? AppColors.leaf : AppColors.white);
  }
  pen.line([_o(73, 77), _o(79, 83), _o(90, 71)], width: 3.5);
  for (final (x, y, r) in [
    (20.0, 22.0, 9.0),
    (140.0, 20.0, 9.0),
    (144.0, 46.0, 6.0),
    (16.0, 48.0, 5.0),
  ]) {
    pen.poly(_star(_o(x, y), r), AppColors.sun);
  }
}

/// A game controller with bright buttons, and coins floating up.
void _games(Canvas canvas, InkPen pen) {
  pen.blob([
    _o(30, 44),
    _o(80, 38),
    _o(130, 44),
    _o(146, 76),
    _o(128, 90),
    _o(108, 72),
    _o(52, 72),
    _o(32, 90),
    _o(14, 76),
  ], AppColors.arcade);
  pen
    ..poly([
      _o(36, 52),
      _o(44, 52),
      _o(44, 58),
      _o(50, 58),
      _o(50, 66),
      _o(44, 66),
      _o(44, 72),
      _o(36, 72),
      _o(36, 66),
      _o(30, 66),
      _o(30, 58),
      _o(36, 58),
    ], AppColors.white)
    ..disc(_o(116, 52), 5, AppColors.sun)
    ..disc(_o(126, 61), 5, AppColors.leaf)
    ..disc(_o(106, 61), 5, AppColors.brandBlue)
    ..disc(_o(116, 70), 5, AppColors.grape)
    ..disc(_o(80, 60), 4, AppColors.arcadeGlow);
  for (final (x, y) in [(56.0, 18.0), (80.0, 12.0), (104.0, 18.0)]) {
    pen.disc(_o(x, y), 7, AppColors.sun);
    _text(canvas, '★', _o(x, y + 0.5), 8, AppColors.backpackShade);
  }
}

/// An island with a palm tree, a paint palette and a brush.
void _creative(Canvas canvas, InkPen pen) {
  pen
    ..disc(_o(24, 20), 11, AppColors.sun)
    ..blob([
      _o(14, 80),
      _o(50, 62),
      _o(110, 60),
      _o(150, 80),
      _o(80, 88),
    ], _sand)
    ..limb([_o(104, 74), _o(108, 52), _o(116, 30)], 6, _wood);
  const top = Offset(116, 30);
  for (final tip in [_o(90, 34), _o(100, 14), _o(134, 14), _o(144, 38)]) {
    final mid = (top + tip) / 2;
    final side = Offset(-(tip - top).dy, (tip - top).dx) * 0.22;
    pen.blob([top, mid + side, tip, mid - side * 0.4], AppColors.leaf);
  }
  pen.blob([
    _o(24, 64),
    _o(40, 50),
    _o(68, 50),
    _o(80, 62),
    _o(64, 76),
    _o(36, 78),
  ], AppColors.white);
  for (final (x, y, c) in [
    (38.0, 60.0, AppColors.coral),
    (50.0, 56.0, AppColors.sun),
    (62.0, 60.0, AppColors.brandBlue),
    (48.0, 68.0, AppColors.grape),
  ]) {
    pen.disc(_o(x, y), 4, c);
  }
  pen
    ..limb([_o(70, 82), _o(88, 66)], 4, _wood)
    ..limb([_o(88, 66), _o(93, 61)], 5, AppColors.coral);
}

/// An open treasure chest with gold spilling out, and a trophy.
void _discoveries(Canvas canvas, InkPen pen) {
  canvas.drawCircle(
    _o(58, 52),
    36,
    Paint()..color = AppColors.white.withValues(alpha: 0.18),
  );
  pen
    ..poly([_o(26, 32), _o(90, 32), _o(84, 50), _o(32, 50)], _wood)
    ..poly([_o(28, 56), _o(88, 56), _o(88, 90), _o(28, 90)], _wood)
    ..poly([_o(28, 56), _o(88, 56), _o(88, 64), _o(28, 64)], AppColors.sun)
    ..poly([_o(52, 64), _o(64, 64), _o(64, 76), _o(52, 76)], AppColors.sun);
  for (final (x, y) in [
    (40.0, 52.0),
    (54.0, 48.0),
    (68.0, 52.0),
    (78.0, 50.0),
  ]) {
    pen.disc(_o(x, y), 6, AppColors.sun);
  }
  pen
    ..poly([_o(36, 46), _o(42, 40), _o(48, 46), _o(42, 52)], AppColors.coral)
    ..poly([
      _o(72, 40),
      _o(78, 34),
      _o(84, 40),
      _o(78, 46),
    ], AppColors.brandBlue);
  // The trophy.
  pen
    ..limb([_o(110, 36), _o(104, 46), _o(112, 52)], 3, AppColors.sun)
    ..limb([_o(138, 36), _o(144, 46), _o(136, 52)], 3, AppColors.sun)
    ..poly([
      _o(110, 26),
      _o(138, 26),
      _o(134, 52),
      _o(126, 60),
      _o(122, 60),
      _o(114, 52),
    ], AppColors.sun)
    ..poly([_o(120, 60), _o(128, 60), _o(128, 76), _o(120, 76)], AppColors.sun)
    ..poly([
      _o(108, 76),
      _o(140, 76),
      _o(140, 88),
      _o(108, 88),
    ], AppColors.backpackShade);
  pen.poly(_star(_o(124, 40), 7), AppColors.white);
}

/// A clothes rail with a party hat, a T-shirt and a scarf.
void _wardrobe(Canvas canvas, InkPen pen) {
  pen
    ..line([_o(14, 16), _o(146, 16)], width: 4)
    ..line([_o(18, 16), _o(18, 92)], width: 4)
    ..line([_o(142, 16), _o(142, 92)], width: 4);
  for (final x in [44.0, 82.0, 120.0]) {
    pen.line([_o(x, 16), _o(x, 24), _o(x - 12, 32), _o(x + 12, 32), _o(x, 24)]);
  }
  // Party hat.
  pen.poly([_o(32, 72), _o(44, 32), _o(56, 72)], AppColors.sun);
  pen
    ..line([_o(37, 56), _o(51, 56)], width: 3)
    ..disc(_o(44, 32), 4, AppColors.coral)
    ..blob([_o(30, 72), _o(44, 68), _o(58, 72), _o(44, 77)], AppColors.coral);
  // T-shirt.
  pen.poly([
    _o(70, 32),
    _o(94, 32),
    _o(104, 44),
    _o(96, 50),
    _o(94, 46),
    _o(94, 78),
    _o(70, 78),
    _o(70, 46),
    _o(68, 50),
    _o(60, 44),
  ], AppColors.coral);
  pen.poly(_star(_o(82, 56), 8), AppColors.sun);
  // Scarf.
  pen
    ..limb([_o(110, 32), _o(108, 60), _o(114, 82)], 8, AppColors.leaf)
    ..limb([_o(130, 32), _o(132, 60), _o(126, 82)], 8, AppColors.leaf)
    ..line([_o(108, 46), _o(112, 46)], width: 2)
    ..line([_o(128, 46), _o(132, 46)], width: 2);
}
