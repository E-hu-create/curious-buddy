import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/stories/story.dart';
import '../../core/themes/app_colors.dart';
import '../../games/widgets/ink_pen.dart';

/// What a picture from the world stories shows, for screen readers.
String worldStoryPictureLabel(ScenePicture picture) => switch (picture) {
  ScenePicture.ananseVillage =>
    'A spider and his little son beside round huts and a clay pot',
  ScenePicture.ananseTree => 'A spider climbing a tall tree with a pot',
  ScenePicture.anansePot => 'A cracked clay pot with sparkles flying out',
  ScenePicture.slidePlayground => 'A bright slide in a school playground',
  ScenePicture.slideRamps => 'Toy cars racing down three different ramps',
  ScenePicture.slideParachute =>
    'A flat sheet of paper floating down beside a paper ball',
  ScenePicture.umbrellaRain => 'A beaver at a workbench in the rain',
  ScenePicture.umbrellaTest => 'Rain falling on paper, cloth, plastic and foil',
  ScenePicture.umbrellaWindow =>
    'A beaver under a clear umbrella, with a rainbow',
  ScenePicture.moleGarden => 'A mole in a garden with a puddle and dry soil',
  ScenePicture.moleTunnel => 'Layers of soil and rock, with a mole and a worm',
  ScenePicture.moleRocks => 'A sparkly rock and a striped rock underground',
  ScenePicture.canoeSea => 'A double canoe with a sail on rolling waves',
  ScenePicture.canoeStars => 'A canoe on a dark sea under bright stars',
  ScenePicture.canoeIsland => 'Birds flying towards an island at sunset',
  ScenePicture.pangolinNight =>
    'A scaly pangolin by a termite mound under the moon',
  ScenePicture.pangolinTree => 'A pangolin holding a branch with its tail',
  ScenePicture.pangolinBall => 'A pangolin curled into a scaly ball',
  _ => '',
};

/// Paints a picture from the world stories. Each story has three.
void paintWorldStoryPicture(Canvas canvas, Size size, ScenePicture picture) {
  final scene = _World(canvas, size);
  switch (picture) {
    case ScenePicture.ananseVillage:
      scene.ananse(0);
    case ScenePicture.ananseTree:
      scene.ananse(1);
    case ScenePicture.anansePot:
      scene.ananse(2);
    case ScenePicture.slidePlayground:
      scene.slide(0);
    case ScenePicture.slideRamps:
      scene.slide(1);
    case ScenePicture.slideParachute:
      scene.slide(2);
    case ScenePicture.umbrellaRain:
      scene.umbrella(0);
    case ScenePicture.umbrellaTest:
      scene.umbrella(1);
    case ScenePicture.umbrellaWindow:
      scene.umbrella(2);
    case ScenePicture.moleGarden:
      scene.mole(0);
    case ScenePicture.moleTunnel:
      scene.mole(1);
    case ScenePicture.moleRocks:
      scene.mole(2);
    case ScenePicture.canoeSea:
      scene.canoe(0);
    case ScenePicture.canoeStars:
      scene.canoe(1);
    case ScenePicture.canoeIsland:
      scene.canoe(2);
    case ScenePicture.pangolinNight:
      scene.pangolin(0);
    case ScenePicture.pangolinTree:
      scene.pangolin(1);
    case ScenePicture.pangolinBall:
      scene.pangolin(2);
    default:
      break;
  }
}

class _World {
  _World(this.canvas, this.size) : pen = InkPen(canvas, outline: 2.5);

  final Canvas canvas;
  final Size size;
  final InkPen pen;

  static const _sky = Color(0xFFCFEFFF);
  static const _grass = Color(0xFF8FC96E);
  static const _sand = Color(0xFFF3D9A4);
  static const _brown = Color(0xFF8A5F3A);
  static const _clay = Color(0xFFC9784A);
  static const _thatch = Color(0xFFD9B45A);
  static const _night = Color(0xFF1B1A4B);
  static const _forestNight = Color(0xFF203A3A);
  static const _sea = Color(0xFF3E9BB0);
  static const _seaDeep = Color(0xFF2B7387);
  static const _rain = Color(0xFF9AA6BC);
  static const _skin = Color(0xFF8D5A3B);
  static const _scale = Color(0xFFB98A55);
  static const _scaleDark = Color(0xFF8C6238);
  static const _rock = Color(0xFF8E96AB);

  Offset p(double x, double y) => Offset(size.width * x, size.height * y);
  double u(double fraction) => size.height * fraction;

  void fill(Color color) =>
      canvas.drawRect(Offset.zero & size, Paint()..color = color);

  void ground(double y, Color color) =>
      pen.poly([p(-0.02, y), p(1.02, y), p(1.02, 1.02), p(-0.02, 1.02)], color);

  void band(double top, double bottom, Color color) => pen.poly([
    p(-0.02, top),
    p(1.02, top),
    p(1.02, bottom),
    p(-0.02, bottom),
  ], color);

  void stars(int seed, {double below = 0.6}) {
    final random = math.Random(seed);
    final dot = Paint()..color = AppColors.sunTint;
    for (var i = 0; i < 22; i++) {
      canvas.drawCircle(
        p(random.nextDouble(), random.nextDouble() * below),
        1 + random.nextDouble() * 1.8,
        dot,
      );
    }
  }

  void sparkle(double x, double y, double r, Color color) {
    final points = [
      for (var i = 0; i < 8; i++)
        p(x, y) +
            Offset.fromDirection(
              -math.pi / 2 + i * math.pi / 4,
              i.isEven ? u(r) : u(r * 0.35),
            ),
    ];
    pen.poly(points, color);
  }

  void cloud(double x, double y, double s, Color color) => pen.blob([
    p(x - 0.12 * s, y + 0.04 * s),
    p(x - 0.08 * s, y - 0.05 * s),
    p(x, y - 0.09 * s),
    p(x + 0.09 * s, y - 0.05 * s),
    p(x + 0.13 * s, y + 0.04 * s),
  ], color);

  void bird(double x, double y, double s) => pen.line([
    p(x - 0.04 * s, y - 0.02 * s),
    p(x, y + 0.01 * s),
    p(x + 0.04 * s, y - 0.02 * s),
  ], width: 3);

  // ----------------------------------------------------------- Ananse

  /// A friendly spider. [s] scales it; [potOnBack] adds the clay pot.
  void spider(double x, double y, double s, {bool potOnBack = false}) {
    for (final side in [-1.0, 1.0]) {
      for (final (dy, reach, lift) in [
        (-0.05, 0.12, 0.09),
        (-0.01, 0.15, 0.06),
        (0.03, 0.15, 0.03),
        (0.07, 0.12, 0.0),
      ]) {
        pen.line([
          p(x + side * 0.03 * s, y + dy * s),
          p(x + side * reach * 0.65 * s, y + (dy - lift) * s),
          p(x + side * reach * s, y + (dy + 0.07) * s),
        ], width: 2.5);
      }
    }
    pen
      ..disc(p(x, y + 0.04 * s), u(0.08 * s), _brown)
      ..disc(p(x, y - 0.06 * s), u(0.055 * s), _brown)
      ..eye(p(x - 0.018 * s, y - 0.07 * s), u(0.013 * s))
      ..eye(p(x + 0.018 * s, y - 0.07 * s), u(0.013 * s));
    if (potOnBack) pot(x, y + 0.06 * s, 0.55 * s);
  }

  void pot(double x, double y, double s) {
    pen
      ..blob([
        p(x - 0.08 * s, y - 0.06 * s),
        p(x + 0.08 * s, y - 0.06 * s),
        p(x + 0.12 * s, y + 0.06 * s),
        p(x, y + 0.14 * s),
        p(x - 0.12 * s, y + 0.06 * s),
      ], _clay)
      ..poly([
        p(x - 0.06 * s, y - 0.1 * s),
        p(x + 0.06 * s, y - 0.1 * s),
        p(x + 0.06 * s, y - 0.06 * s),
        p(x - 0.06 * s, y - 0.06 * s),
      ], _clay);
  }

  void hut(double x, double base, double s) {
    pen
      ..poly([
        p(x - 0.11 * s, base),
        p(x - 0.11 * s, base - 0.2 * s),
        p(x + 0.11 * s, base - 0.2 * s),
        p(x + 0.11 * s, base),
      ], const Color(0xFFE2A46C))
      ..poly([
        p(x - 0.15 * s, base - 0.18 * s),
        p(x, base - 0.42 * s),
        p(x + 0.15 * s, base - 0.18 * s),
      ], _thatch)
      ..poly([
        p(x - 0.03 * s, base),
        p(x - 0.03 * s, base - 0.1 * s),
        p(x + 0.03 * s, base - 0.1 * s),
        p(x + 0.03 * s, base),
      ], _brown);
  }

  void ananse(int version) {
    if (version == 0) {
      fill(AppColors.sunTint);
      ground(0.74, _sand);
      hut(0.18, 0.76, 1);
      hut(0.84, 0.76, 0.8);
      pot(0.66, 0.78, 0.7);
      spider(0.42, 0.62, 1.1);
      spider(0.52, 0.86, 0.55);
      return;
    }
    if (version == 1) {
      fill(_sky);
      ground(0.86, _grass);
      pen
        ..limb([p(0.5, 0.95), p(0.5, 0.2)], 26, _brown)
        ..blob([
          p(0.2, 0.26),
          p(0.32, 0.06),
          p(0.6, 0.0),
          p(0.82, 0.12),
          p(0.8, 0.3),
          p(0.5, 0.36),
        ], AppColors.leaf);
      spider(0.5, 0.52, 0.9, potOnBack: true);
      spider(0.24, 0.84, 0.5);
      return;
    }
    fill(AppColors.grapeTint);
    ground(0.82, _sand);
    pot(0.5, 0.62, 1.6);
    pen.line([p(0.48, 0.48), p(0.52, 0.58), p(0.47, 0.7)], width: 3);
    for (final (x, y, r, c) in [
      (0.3, 0.22, 0.06, AppColors.sun),
      (0.5, 0.12, 0.05, AppColors.coral),
      (0.7, 0.24, 0.06, AppColors.sun),
      (0.18, 0.4, 0.04, AppColors.brandBlue),
      (0.84, 0.42, 0.04, AppColors.leaf),
    ]) {
      sparkle(x, y, r, c);
    }
    spider(0.84, 0.8, 0.5);
  }

  // ------------------------------------------------------------ Slide

  void child(double x, double y, double s, Color shirt) {
    pen
      ..limb(
        [p(x - 0.02 * s, y + 0.12 * s), p(x - 0.03 * s, y + 0.24 * s)],
        5,
        _skin,
      )
      ..limb(
        [p(x + 0.02 * s, y + 0.12 * s), p(x + 0.03 * s, y + 0.24 * s)],
        5,
        _skin,
      )
      ..blob([
        p(x - 0.05 * s, y + 0.02 * s),
        p(x + 0.05 * s, y + 0.02 * s),
        p(x + 0.06 * s, y + 0.14 * s),
        p(x - 0.06 * s, y + 0.14 * s),
      ], shirt)
      ..disc(p(x, y - 0.04 * s), u(0.07 * s), _skin)
      ..eye(p(x - 0.02 * s, y - 0.05 * s), u(0.01 * s))
      ..eye(p(x + 0.02 * s, y - 0.05 * s), u(0.01 * s));
  }

  void toyCar(double x, double y, double s, Color color, double tilt) {
    canvas
      ..save()
      ..translate(p(x, y).dx, p(x, y).dy)
      ..rotate(tilt)
      ..translate(-p(x, y).dx, -p(x, y).dy);
    pen
      ..poly([
        p(x - 0.06 * s, y - 0.03 * s),
        p(x + 0.06 * s, y - 0.03 * s),
        p(x + 0.06 * s, y + 0.02 * s),
        p(x - 0.06 * s, y + 0.02 * s),
      ], color)
      ..disc(p(x - 0.035 * s, y + 0.03 * s), u(0.022 * s), AppColors.ink)
      ..disc(p(x + 0.035 * s, y + 0.03 * s), u(0.022 * s), AppColors.ink);
    canvas.restore();
  }

  void slide(int version) {
    fill(_sky);
    ground(0.82, _grass);
    if (version == 0) {
      pen
        ..line([p(0.2, 0.82), p(0.2, 0.3)], width: 4)
        ..line([p(0.3, 0.82), p(0.3, 0.3)], width: 4);
      for (final y in [0.4, 0.5, 0.6, 0.7]) {
        pen.line([p(0.2, y), p(0.3, y)], width: 3);
      }
      pen.poly([
        p(0.2, 0.3),
        p(0.32, 0.3),
        p(0.8, 0.78),
        p(0.86, 0.82),
        p(0.74, 0.82),
      ], AppColors.coral);
      child(0.46, 0.38, 0.9, AppColors.sun);
      child(0.86, 0.6, 0.8, AppColors.brandBlue);
      return;
    }
    if (version == 1) {
      for (final (i, color) in [
        AppColors.grape,
        const Color(0xFFC9955A),
        AppColors.white,
      ].indexed) {
        final top = 0.2 + i * 0.22;
        pen.poly([
          p(0.08, top),
          p(0.12, top - 0.03),
          p(0.92, top + 0.16),
          p(0.88, top + 0.19),
        ], color);
      }
      toyCar(0.3, 0.2, 1, AppColors.coral, 0.2);
      toyCar(0.55, 0.5, 1, AppColors.sun, 0.2);
      toyCar(0.82, 0.8, 1, AppColors.leaf, 0.2);
      return;
    }
    pen.blob([
      p(0.38, 0.2),
      p(0.58, 0.16),
      p(0.62, 0.24),
      p(0.42, 0.28),
    ], AppColors.white);
    for (final dx in [0.42, 0.5, 0.58]) {
      pen.line([p(dx, 0.32), p(dx, 0.4)], width: 2);
    }
    pen
      ..blob([
        p(0.74, 0.62),
        p(0.8, 0.58),
        p(0.84, 0.64),
        p(0.78, 0.69),
      ], AppColors.white)
      ..line([p(0.79, 0.44), p(0.79, 0.54)], width: 2);
    child(0.2, 0.52, 1, AppColors.grape);
  }

  // ----------------------------------------------------------- Beaver

  void beaver(double x, double y, double s) {
    pen
      ..blob([
        p(x + 0.06 * s, y + 0.12 * s),
        p(x + 0.22 * s, y + 0.08 * s),
        p(x + 0.24 * s, y + 0.16 * s),
        p(x + 0.08 * s, y + 0.18 * s),
      ], const Color(0xFF5A4A3A))
      ..blob([
        p(x - 0.1 * s, y - 0.02 * s),
        p(x + 0.08 * s, y - 0.04 * s),
        p(x + 0.1 * s, y + 0.16 * s),
        p(x - 0.08 * s, y + 0.18 * s),
      ], _brown)
      ..disc(p(x - 0.02 * s, y - 0.1 * s), u(0.09 * s), _brown)
      ..poly([
        p(x - 0.04 * s, y - 0.04 * s),
        p(x, y - 0.04 * s),
        p(x, y),
        p(x - 0.04 * s, y),
      ], AppColors.white)
      ..eye(p(x - 0.05 * s, y - 0.12 * s), u(0.013 * s))
      ..eye(p(x + 0.02 * s, y - 0.12 * s), u(0.013 * s));
  }

  void rain(double from, double to, int seed) {
    final random = math.Random(seed);
    for (var i = 0; i < 16; i++) {
      final x = from + random.nextDouble() * (to - from);
      final y = random.nextDouble() * 0.5;
      pen.line([p(x, y), p(x - 0.01, y + 0.06)], width: 2);
    }
  }

  void umbrella(int version) {
    if (version == 0) {
      fill(_rain);
      rain(0, 1, 3);
      ground(0.8, const Color(0xFF6E8F5A));
      pen.poly([
        p(0.4, 0.62),
        p(0.95, 0.62),
        p(0.95, 0.68),
        p(0.4, 0.68),
      ], const Color(0xFFC9955A));
      pen
        ..line([p(0.44, 0.68), p(0.44, 0.82)], width: 4)
        ..line([p(0.91, 0.68), p(0.91, 0.82)], width: 4);
      for (final (x, c) in [
        (0.5, AppColors.white),
        (0.62, AppColors.coral),
        (0.74, AppColors.brandBlueTint),
        (0.86, const Color(0xFFD0D4DC)),
      ]) {
        pen.poly([
          p(x - 0.05, 0.54),
          p(x + 0.05, 0.54),
          p(x + 0.05, 0.62),
          p(x - 0.05, 0.62),
        ], c);
      }
      beaver(0.2, 0.6, 1);
      return;
    }
    if (version == 1) {
      fill(_rain);
      rain(0, 1, 9);
      ground(0.86, const Color(0xFF6E8F5A));
      for (final (i, (color, wet)) in [
        (AppColors.white, true),
        (AppColors.coral, true),
        (AppColors.brandBlueTint, false),
        (const Color(0xFFD0D4DC), false),
      ].indexed) {
        final x = 0.14 + i * 0.24;
        pen.poly([
          p(x - 0.09, 0.5),
          p(x + 0.09, 0.5),
          p(x + 0.09, 0.66),
          p(x - 0.09, 0.66),
        ], color);
        if (wet) {
          for (final dx in [-0.04, 0.03]) {
            pen.blob([
              p(x + dx, 0.7),
              p(x + dx + 0.015, 0.74),
              p(x + dx, 0.77),
              p(x + dx - 0.015, 0.74),
            ], AppColors.brandBlue);
          }
        } else {
          sparkle(x, 0.76, 0.03, AppColors.sun);
        }
      }
      return;
    }
    fill(_sky);
    for (final (i, color) in [
      AppColors.coral,
      AppColors.sun,
      AppColors.leaf,
      AppColors.brandBlue,
    ].indexed) {
      canvas.drawArc(
        Rect.fromCenter(
          center: p(0.5, 0.86),
          width: u(1.6 - i * 0.12),
          height: u(1.3 - i * 0.12),
        ),
        math.pi,
        math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = u(0.05)
          ..color = color.withValues(alpha: 0.7),
      );
    }
    ground(0.84, _grass);
    canvas.drawArc(
      Rect.fromCenter(center: p(0.5, 0.42), width: u(0.7), height: u(0.5)),
      math.pi,
      math.pi,
      true,
      Paint()..color = AppColors.white.withValues(alpha: 0.45),
    );
    canvas.drawArc(
      Rect.fromCenter(center: p(0.5, 0.42), width: u(0.7), height: u(0.5)),
      math.pi,
      math.pi,
      true,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = AppColors.ink,
    );
    pen.line([p(0.5, 0.42), p(0.5, 0.62)], width: 3);
    beaver(0.48, 0.66, 0.9);
  }

  // ------------------------------------------------------------- Mole

  void moleFace(double x, double y, double s) {
    pen
      ..blob([
        p(x - 0.1 * s, y + 0.06 * s),
        p(x - 0.06 * s, y - 0.08 * s),
        p(x + 0.06 * s, y - 0.08 * s),
        p(x + 0.1 * s, y + 0.06 * s),
      ], const Color(0xFF4A4458))
      ..disc(p(x, y - 0.02 * s), u(0.025 * s), AppColors.cheek)
      ..eye(p(x - 0.04 * s, y - 0.05 * s), u(0.01 * s))
      ..eye(p(x + 0.04 * s, y - 0.05 * s), u(0.01 * s));
    for (final side in [-1.0, 1.0]) {
      pen.blob([
        p(x + side * 0.1 * s, y + 0.02 * s),
        p(x + side * 0.16 * s, y + 0.04 * s),
        p(x + side * 0.14 * s, y + 0.1 * s),
        p(x + side * 0.09 * s, y + 0.07 * s),
      ], AppColors.cheek);
    }
  }

  void mole(int version) {
    if (version == 0) {
      fill(_sky);
      ground(0.6, const Color(0xFF7A5A3E));
      pen
        ..blob([
          p(0.04, 0.72),
          p(0.18, 0.66),
          p(0.36, 0.7),
          p(0.3, 0.8),
          p(0.08, 0.8),
        ], const Color(0xFF6C8FB0))
        ..poly([
          p(0.62, 0.6),
          p(1.02, 0.6),
          p(1.02, 1.02),
          p(0.62, 1.02),
        ], const Color(0xFFD7B98A));
      for (final x in [0.7, 0.8, 0.9]) {
        pen.line([p(x, 0.7), p(x + 0.04, 0.78)], width: 2);
      }
      for (final x in [0.12, 0.24]) {
        pen.blob([
          p(x, 0.66),
          p(x + 0.02, 0.56),
          p(x + 0.04, 0.66),
        ], AppColors.leaf);
      }
      pen.blob([
        p(0.38, 0.62),
        p(0.48, 0.5),
        p(0.58, 0.62),
      ], const Color(0xFF5E4430));
      moleFace(0.48, 0.5, 0.9);
      return;
    }
    if (version == 1) {
      fill(_sky);
      band(0.18, 0.4, const Color(0xFF4E3826));
      band(0.4, 0.6, const Color(0xFFB0703F));
      band(0.6, 0.8, const Color(0xFFE2C48A));
      band(0.8, 1.02, _rock);
      band(0.14, 0.18, _grass);
      pen.blob([
        p(0.3, 0.5),
        p(0.62, 0.46),
        p(0.66, 0.56),
        p(0.32, 0.6),
      ], const Color(0xFF3A2A1C));
      moleFace(0.6, 0.5, 0.8);
      pen.limb(
        [p(0.16, 0.3), p(0.2, 0.26), p(0.25, 0.32), p(0.3, 0.28)],
        6,
        AppColors.cheek,
      );
      return;
    }
    fill(const Color(0xFF4E3826));
    pen.blob([
      p(0.08, 0.86),
      p(0.12, 0.5),
      p(0.38, 0.42),
      p(0.46, 0.7),
      p(0.38, 0.88),
    ], const Color(0xFFC9C1C9));
    final random = math.Random(4);
    for (var i = 0; i < 14; i++) {
      canvas.drawCircle(
        p(0.14 + random.nextDouble() * 0.26, 0.52 + random.nextDouble() * 0.3),
        u(0.012),
        Paint()..color = i.isEven ? AppColors.ink : const Color(0xFFF2D6E0),
      );
    }
    for (final (i, color) in [
      const Color(0xFFE8C08A),
      const Color(0xFFD69C62),
      const Color(0xFFE8C08A),
      const Color(0xFFC9884E),
    ].indexed) {
      final top = 0.5 + i * 0.09;
      pen.poly([
        p(0.54, top),
        p(0.92, top - 0.02),
        p(0.92, top + 0.09),
        p(0.54, top + 0.09),
      ], color);
    }
    moleFace(0.5, 0.22, 0.9);
  }

  // ------------------------------------------------------------ Canoe

  void canoeBoat(double x, double y, double s, Color hull) {
    for (final dy in [0.0, 0.07]) {
      pen.blob([
        p(x - 0.26 * s, y + dy * s - 0.01),
        p(x + 0.26 * s, y + dy * s - 0.01),
        p(x + 0.2 * s, y + (dy + 0.05) * s),
        p(x - 0.2 * s, y + (dy + 0.05) * s),
      ], hull);
    }
    pen
      ..line([p(x, y), p(x, y - 0.36 * s)], width: 3)
      ..poly([
        p(x, y - 0.36 * s),
        p(x + 0.04 * s, y - 0.04 * s),
        p(x + 0.22 * s, y - 0.3 * s),
      ], AppColors.paper);
  }

  void swells(double top, Color light, Color dark) {
    for (var i = 0; i < 4; i++) {
      final y = top + i * 0.08;
      pen.blob([
        p(-0.1, y + 0.05),
        p(0.25, y - 0.02),
        p(0.6, y + 0.03),
        p(1.1, y - 0.01),
        p(1.1, y + 0.2),
        p(-0.1, y + 0.2),
      ], i.isEven ? light : dark);
    }
  }

  void canoe(int version) {
    if (version == 0) {
      fill(_sky);
      swells(0.6, _sea, _seaDeep);
      canoeBoat(0.5, 0.62, 1, _brown);
      bird(0.2, 0.2, 1.4);
      bird(0.32, 0.12, 1);
      return;
    }
    if (version == 1) {
      fill(_night);
      stars(18, below: 0.62);
      sparkle(0.78, 0.5, 0.05, AppColors.sun);
      swells(0.64, const Color(0xFF233A6B), const Color(0xFF1A2B52));
      canoeBoat(0.4, 0.66, 1, const Color(0xFF3A2A1C));
      return;
    }
    fill(const Color(0xFFFFC98A));
    pen.disc(p(0.5, 0.58), u(0.12), AppColors.sun);
    cloud(0.52, 0.22, 1.2, AppColors.white);
    pen
      ..blob([p(0.28, 0.62), p(0.5, 0.48), p(0.74, 0.62)], _grass)
      ..limb([p(0.6, 0.56), p(0.62, 0.4)], 4, _brown)
      ..blob([p(0.62, 0.4), p(0.52, 0.36), p(0.56, 0.42)], AppColors.leaf)
      ..blob([p(0.62, 0.4), p(0.72, 0.36), p(0.68, 0.42)], AppColors.leaf);
    swells(0.62, _sea, _seaDeep);
    for (final (x, y) in [(0.16, 0.3), (0.26, 0.38), (0.84, 0.34)]) {
      bird(x, y, 1);
    }
    canoeBoat(0.22, 0.74, 0.55, _brown);
  }

  // --------------------------------------------------------- Pangolin

  /// A pangolin walking right; scaly rows painted over its body.
  void pangolinBody(double x, double y, double s) {
    pen
      ..limb(
        [
          p(x - 0.14 * s, y + 0.02 * s),
          p(x - 0.26 * s, y + 0.08 * s),
          p(x - 0.32 * s, y + 0.14 * s),
        ],
        12 * s,
        _scale,
      )
      ..limb(
        [p(x - 0.06 * s, y + 0.08 * s), p(x - 0.07 * s, y + 0.15 * s)],
        6 * s,
        _scaleDark,
      )
      ..limb(
        [p(x + 0.08 * s, y + 0.08 * s), p(x + 0.09 * s, y + 0.15 * s)],
        6 * s,
        _scaleDark,
      )
      ..blob([
        p(x - 0.16 * s, y + 0.06 * s),
        p(x - 0.06 * s, y - 0.1 * s),
        p(x + 0.1 * s, y - 0.09 * s),
        p(x + 0.16 * s, y + 0.06 * s),
        p(x, y + 0.1 * s),
      ], _scale)
      ..blob([
        p(x + 0.13 * s, y),
        p(x + 0.2 * s, y - 0.02 * s),
        p(x + 0.27 * s, y + 0.04 * s),
        p(x + 0.15 * s, y + 0.07 * s),
      ], const Color(0xFFD9B88A))
      ..eye(p(x + 0.19 * s, y + 0.01 * s), u(0.012 * s));
    scales(x, y - 0.02 * s, s);
  }

  void scales(double x, double y, double s) {
    final ink = Paint()
      ..color = _scaleDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var row = 0; row < 3; row++) {
      for (var i = 0; i < 4; i++) {
        final cx = x + (-0.1 + i * 0.065 + row * 0.02) * s;
        final cy = y + (-0.04 + row * 0.045) * s;
        canvas.drawArc(
          Rect.fromCircle(center: p(cx, cy), radius: u(0.03 * s)),
          0,
          math.pi,
          false,
          ink,
        );
      }
    }
  }

  void pangolin(int version) {
    if (version == 1) {
      fill(_forestNight);
      stars(7, below: 0.3);
      pen
        ..limb([p(-0.05, 0.4), p(0.6, 0.46), p(1.05, 0.38)], 14, _brown)
        ..blob([
          p(0.6, 0.0),
          p(0.9, 0.06),
          p(1.05, 0.2),
          p(0.7, 0.24),
        ], const Color(0xFF3E8E5A))
        ..blob([
          p(0.0, 0.04),
          p(0.3, 0.0),
          p(0.36, 0.18),
          p(0.04, 0.22),
        ], const Color(0xFF3E8E5A));
      pangolinBody(0.46, 0.34, 1.2);
      pen.limb([p(0.08, 0.46), p(0.06, 0.52), p(0.12, 0.54)], 5, _scaleDark);
      return;
    }
    fill(_forestNight);
    stars(11, below: 0.5);
    pen.disc(p(0.84, 0.16), u(0.08), AppColors.paper);
    ground(0.8, const Color(0xFF4E6B3A));
    if (version == 0) {
      pen.blob([
        p(0.62, 0.82),
        p(0.7, 0.4),
        p(0.78, 0.32),
        p(0.86, 0.42),
        p(0.94, 0.82),
      ], _clay);
      pangolinBody(0.32, 0.7, 1.2);
      return;
    }
    pen.disc(p(0.5, 0.64), u(0.18), _scale);
    for (var ring = 0; ring < 3; ring++) {
      final r = 0.15 - ring * 0.045;
      for (var i = 0; i < 9; i++) {
        final angle = i * 2 * math.pi / 9 + ring * 0.3;
        canvas.drawArc(
          Rect.fromCircle(
            center: p(0.5, 0.64) + Offset.fromDirection(angle, u(r)),
            radius: u(0.035),
          ),
          angle - math.pi / 2,
          math.pi,
          false,
          Paint()
            ..color = _scaleDark
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
  }
}
