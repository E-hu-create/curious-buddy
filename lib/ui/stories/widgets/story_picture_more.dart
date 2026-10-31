import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/stories/story.dart';
import '../../core/themes/app_colors.dart';
import '../../games/widgets/ink_pen.dart';
import 'story_picture_world.dart';

/// What a picture from the later stories shows, for screen readers.
String moreStoryPictureLabel(ScenePicture picture) => switch (picture) {
  ScenePicture.whaleSea => 'A young whale alone in the blue sea',
  ScenePicture.whaleReef => 'A young whale beside a bright coral reef',
  ScenePicture.whaleSong => 'Whales swimming together, singing',
  ScenePicture.snowHill => 'A white fox on a snowy hill in falling snow',
  ScenePicture.snowCrystal => 'A white fox looking at big six-sided snowflakes',
  ScenePicture.snowSunny => 'A white fox on sparkling snow under the sun',
  ScenePicture.beeMeadow => 'A honeybee in a meadow full of flowers',
  ScenePicture.beeHive => 'A honeybee beside a golden honeycomb',
  ScenePicture.beeBusy => 'Many bees flying over a meadow of flowers',
  ScenePicture.bubbleCave =>
    'A small purple dragon in a cave, sneezing bubbles',
  ScenePicture.bubbleBig => 'A small purple dragon blowing a giant bubble',
  ScenePicture.bubbleRainbow => 'A happy dragon among bright rainbow bubbles',
  ScenePicture.starNight => 'An owl on a tower under a starry sky',
  ScenePicture.starScope => 'An owl beside a brass telescope at night',
  ScenePicture.starMap => 'An owl and a star pattern glowing in the night sky',
  ScenePicture.springMountain => 'A snowy mountain with a curl of steam',
  ScenePicture.springPool => 'Warm stones and a steaming pool in the snow',
  ScenePicture.springHappy => 'A tortoise beside a warm blue pool in the snow',
  ScenePicture.seedHill => 'A dandelion clock on a windy green hill',
  ScenePicture.seedRiver => 'A tiny seed floating above a sparkling river',
  ScenePicture.seedTall => 'A yellow dandelion in full bloom in the sunshine',
  ScenePicture.robotDust =>
    'A small robot on red Mars, with dusty robots behind',
  ScenePicture.robotPanel => 'A small robot brushing a dusty solar panel',
  ScenePicture.robotSun => 'Three happy robots at a blue Mars sunset',
  ScenePicture.fossilCliff =>
    'A striped cliff above a beach, with a fallen rock',
  ScenePicture.fossilBrush => 'A spiral fossil being cleaned with a soft brush',
  ScenePicture.fossilDisplay => 'A spiral fossil in a glass museum case',
  ScenePicture.monarchField => 'An orange butterfly on a flower in a field',
  ScenePicture.monarchMountains => 'Orange butterflies flying over mountains',
  ScenePicture.monarchForest => 'Fir trees covered in orange butterflies',
  _ => worldStoryPictureLabel(picture),
};

/// Paints a picture from the later stories. Each story has one scene with
/// three versions: the start, the middle and the ending.
void paintMoreStoryPicture(Canvas canvas, Size size, ScenePicture picture) {
  final painter = _Scene(canvas, size);
  switch (picture) {
    case ScenePicture.whaleSea:
      painter.whale(0);
    case ScenePicture.whaleReef:
      painter.whale(1);
    case ScenePicture.whaleSong:
      painter.whale(2);
    case ScenePicture.snowHill:
      painter.snow(0);
    case ScenePicture.snowCrystal:
      painter.snow(1);
    case ScenePicture.snowSunny:
      painter.snow(2);
    case ScenePicture.beeMeadow:
      painter.bee(0);
    case ScenePicture.beeHive:
      painter.bee(1);
    case ScenePicture.beeBusy:
      painter.bee(2);
    case ScenePicture.bubbleCave:
      painter.dragon(0);
    case ScenePicture.bubbleBig:
      painter.dragon(1);
    case ScenePicture.bubbleRainbow:
      painter.dragon(2);
    case ScenePicture.starNight:
      painter.owl(0);
    case ScenePicture.starScope:
      painter.owl(1);
    case ScenePicture.starMap:
      painter.owl(2);
    case ScenePicture.springMountain:
      painter.spring(0);
    case ScenePicture.springPool:
      painter.spring(1);
    case ScenePicture.springHappy:
      painter.spring(2);
    case ScenePicture.seedHill:
      painter.seed(0);
    case ScenePicture.seedRiver:
      painter.seed(1);
    case ScenePicture.seedTall:
      painter.seed(2);
    case ScenePicture.robotDust:
      painter.robot(0);
    case ScenePicture.robotPanel:
      painter.robot(1);
    case ScenePicture.robotSun:
      painter.robot(2);
    case ScenePicture.fossilCliff:
      painter.fossil(0);
    case ScenePicture.fossilBrush:
      painter.fossil(1);
    case ScenePicture.fossilDisplay:
      painter.fossil(2);
    case ScenePicture.monarchField:
      painter.monarch(0);
    case ScenePicture.monarchMountains:
      painter.monarch(1);
    case ScenePicture.monarchForest:
      painter.monarch(2);
    default:
      paintWorldStoryPicture(canvas, size, picture);
  }
}

class _Scene {
  _Scene(this.canvas, this.size) : pen = InkPen(canvas, outline: 2.5);

  final Canvas canvas;
  final Size size;
  final InkPen pen;

  static const _sea = Color(0xFF3E9BB0);
  static const _seaDeep = Color(0xFF2B7387);
  static const _snow = Color(0xFFF4FAFF);
  static const _ice = Color(0xFFCFE4FF);
  static const _caveWall = Color(0xFF4B3A73);
  static const _night = Color(0xFF1B1A4B);
  static const _brown = Color(0xFF8A5F3A);
  static const _rock = Color(0xFF8E96AB);
  static const _mars = Color(0xFFC96A3C);
  static const _marsSky = Color(0xFFE8A97C);
  static const _orange = Color(0xFFF08A24);

  /// A point, as fractions of the picture.
  Offset p(double x, double y) => Offset(size.width * x, size.height * y);

  /// A size, as a fraction of the picture's height.
  double u(double fraction) => size.height * fraction;

  void fill(Color color) =>
      canvas.drawRect(Offset.zero & size, Paint()..color = color);

  void ground(double y, Color color) =>
      pen.poly([p(-0.02, y), p(1.02, y), p(1.02, 1.02), p(-0.02, 1.02)], color);

  void hill(double top, Color color) => pen.blob([
    p(-0.1, 0.8),
    p(0.3, top),
    p(0.7, top + 0.1),
    p(1.1, 0.7),
    p(1.1, 1.2),
    p(-0.1, 1.2),
  ], color);

  void stars(int seed) {
    final random = math.Random(seed);
    final dot = Paint()..color = AppColors.sunTint;
    for (var i = 0; i < 18; i++) {
      canvas.drawCircle(
        p(random.nextDouble(), random.nextDouble() * 0.7),
        1 + random.nextDouble() * 1.6,
        dot,
      );
    }
  }

  void flower(double x, double y, Color color) {
    pen.line([p(x, y), p(x, y + 0.2)], width: 3);
    for (var i = 0; i < 5; i++) {
      final angle = i * 2 * math.pi / 5;
      pen.disc(
        p(x, y) + Offset(math.cos(angle), math.sin(angle)) * u(0.06),
        u(0.05),
        color,
      );
    }
    pen.disc(p(x, y), u(0.04), AppColors.sun);
  }

  void bubble(double x, double y, double radius, [Color? color]) {
    canvas.drawCircle(
      p(x, y),
      u(radius),
      Paint()..color = (color ?? AppColors.white).withValues(alpha: 0.35),
    );
    canvas.drawCircle(
      p(x, y),
      u(radius),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.ink,
    );
    canvas.drawCircle(
      p(x, y) - Offset(u(radius * 0.35), u(radius * 0.35)),
      u(radius * 0.18),
      Paint()..color = AppColors.white,
    );
  }

  // ------------------------------------------------------------ The whale

  void whaleBody(double x, double y, double scale, Color color) {
    final s = scale;
    pen
      ..blob([
        p(x - 0.17 * s, y - 0.12 * s),
        p(x - 0.12 * s, y - 0.02 * s),
        p(x - 0.05 * s, y - 0.1 * s),
        p(x - 0.07 * s, y + 0.06 * s),
      ], color)
      ..blob([
        p(x - 0.08 * s, y + 0.04 * s),
        p(x + 0.02 * s, y - 0.1 * s),
        p(x + 0.16 * s, y - 0.1 * s),
        p(x + 0.24 * s, y + 0.06 * s),
        p(x + 0.14 * s, y + 0.18 * s),
        p(x, y + 0.14 * s),
      ], color)
      ..eye(p(x + 0.17 * s, y), u(0.022 * s));
  }

  void whale(int version) {
    fill(_sea);
    ground(0.86, _seaDeep);
    if (version == 1) {
      for (final (x, color) in [
        (0.08, AppColors.coral),
        (0.2, AppColors.sun),
        (0.82, AppColors.grape),
        (0.93, AppColors.coral),
      ]) {
        pen
          ..limb([p(x, 0.88), p(x, 0.6)], 8, color)
          ..limb([p(x, 0.74), p(x + 0.05, 0.62)], 6, color);
      }
    }
    whaleBody(0.45, 0.42, 1.1, AppColors.brandBlue);
    if (version == 2) {
      whaleBody(0.17, 0.72, 0.6, AppColors.brandBlueDeep);
      whaleBody(0.78, 0.72, 0.7, AppColors.brandBlueDeep);
      for (final (x, y) in [(0.8, 0.2), (0.88, 0.32), (0.1, 0.3)]) {
        pen
          ..disc(p(x, y), u(0.03), AppColors.sun)
          ..line([p(x + 0.02, y), p(x + 0.02, y - 0.12)], width: 3);
      }
    }
  }

  // -------------------------------------------------------------- The fox

  void flake(double x, double y, double radius) {
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final tip = p(x, y) + Offset(math.cos(angle), math.sin(angle)) * radius;
      pen.line([p(x, y), tip], width: 2.5);
    }
  }

  void snow(int version) {
    fill(version == 2 ? const Color(0xFFCDEFF4) : const Color(0xFF8FB7D9));
    if (version == 2) pen.disc(p(0.84, 0.2), u(0.11), AppColors.sun);
    hill(0.5, _snow);
    // The fox.
    pen
      ..blob([p(0.26, 0.72), p(0.1, 0.62), p(0.12, 0.8), p(0.26, 0.8)], _snow)
      ..blob([p(0.26, 0.82), p(0.32, 0.62), p(0.46, 0.62), p(0.5, 0.82)], _snow)
      ..poly([p(0.44, 0.5), p(0.45, 0.38), p(0.5, 0.47)], _snow)
      ..poly([p(0.53, 0.47), p(0.58, 0.38), p(0.59, 0.5)], _snow)
      ..blob([p(0.42, 0.56), p(0.51, 0.46), p(0.6, 0.56), p(0.52, 0.68)], _snow)
      ..eye(p(0.48, 0.55), u(0.018))
      ..eye(p(0.55, 0.55), u(0.018))
      ..disc(p(0.515, 0.63), u(0.016), AppColors.ink);
    if (version == 0) {
      for (final (x, y) in [
        (0.1, 0.2),
        (0.3, 0.1),
        (0.56, 0.22),
        (0.74, 0.1),
        (0.9, 0.3),
      ]) {
        flake(x, y, u(0.04));
      }
    }
    if (version == 1) {
      flake(0.2, 0.22, u(0.14));
      flake(0.8, 0.26, u(0.17));
    }
  }

  // -------------------------------------------------------------- The bee

  void beeBody(double x, double y, double s) {
    pen
      ..disc(p(x - 0.01 * s, y - 0.09 * s), u(0.06 * s), AppColors.white)
      ..disc(p(x + 0.04 * s, y - 0.09 * s), u(0.06 * s), AppColors.white)
      ..blob([
        p(x - 0.08 * s, y),
        p(x, y - 0.07 * s),
        p(x + 0.08 * s, y),
        p(x, y + 0.07 * s),
      ], AppColors.sun)
      ..line([
        p(x - 0.02 * s, y - 0.06 * s),
        p(x - 0.02 * s, y + 0.06 * s),
      ], width: 4)
      ..line([
        p(x + 0.03 * s, y - 0.06 * s),
        p(x + 0.03 * s, y + 0.06 * s),
      ], width: 4);
  }

  void bee(int version) {
    fill(const Color(0xFFCFEFFF));
    if (version == 1) {
      fill(const Color(0xFFFFE9B8));
      final hex = u(0.11);
      for (var row = 0; row < 3; row++) {
        for (var col = 0; col < 6; col++) {
          final x = 0.08 + col * 0.17 + (row.isOdd ? 0.085 : 0);
          final y = 0.25 + row * 0.26;
          pen.poly([
            for (var i = 0; i < 6; i++)
              p(x, y) +
                  Offset(
                        math.cos(i * math.pi / 3 + math.pi / 6),
                        math.sin(i * math.pi / 3 + math.pi / 6),
                      ) *
                      hex,
          ], AppColors.sun);
        }
      }
      beeBody(0.5, 0.5, 1.5);
      return;
    }
    ground(0.74, const Color(0xFF8FC96E));
    for (final (x, color) in [
      (0.14, AppColors.coral),
      (0.34, AppColors.grape),
      (0.56, AppColors.coral),
      (0.76, AppColors.grape),
      (0.92, AppColors.coral),
    ]) {
      flower(x, 0.68, color);
    }
    if (version == 0) {
      beeBody(0.5, 0.3, 1.3);
    } else {
      for (final (x, y) in [
        (0.14, 0.34),
        (0.34, 0.2),
        (0.56, 0.36),
        (0.76, 0.18),
        (0.9, 0.4),
      ]) {
        beeBody(x, y, 0.8);
      }
    }
  }

  // ----------------------------------------------------------- The dragon

  void dragon(int version) {
    fill(version == 2 ? const Color(0xFFCFEFFF) : _caveWall);
    ground(0.84, version == 2 ? const Color(0xFF8FC96E) : _rock);
    const scale = AppColors.grape;
    pen
      ..blob([p(0.14, 0.8), p(0.03, 0.62), p(0.1, 0.84), p(0.26, 0.86)], scale)
      ..poly([p(0.22, 0.52), p(0.28, 0.36), p(0.34, 0.5)], AppColors.sun)
      ..blob([
        p(0.16, 0.88),
        p(0.18, 0.56),
        p(0.36, 0.46),
        p(0.42, 0.88),
      ], scale)
      ..blob([p(0.34, 0.5), p(0.46, 0.38), p(0.56, 0.5), p(0.44, 0.6)], scale)
      ..eye(p(0.45, 0.46), u(0.025));
    if (version == 0) {
      bubble(0.64, 0.42, 0.05);
      bubble(0.74, 0.3, 0.07);
      bubble(0.86, 0.46, 0.04);
    } else if (version == 1) {
      bubble(0.76, 0.42, 0.3);
    } else {
      for (final (x, y, r, c) in [
        (0.66, 0.26, 0.1, AppColors.coral),
        (0.82, 0.46, 0.13, AppColors.sun),
        (0.58, 0.62, 0.07, AppColors.leaf),
        (0.9, 0.16, 0.07, AppColors.grape),
        (0.74, 0.74, 0.06, AppColors.brandBlue),
      ]) {
        bubble(x, y, r, c);
      }
    }
  }

  // -------------------------------------------------------------- The owl

  void owlBody(double x, double y) {
    pen
      ..blob([
        p(x - 0.09, y + 0.12),
        p(x - 0.1, y - 0.14),
        p(x, y - 0.22),
        p(x + 0.1, y - 0.14),
        p(x + 0.09, y + 0.12),
        p(x, y + 0.2),
      ], const Color(0xFFB9743C))
      ..disc(p(x - 0.04, y - 0.1), u(0.06), AppColors.white)
      ..disc(p(x + 0.04, y - 0.1), u(0.06), AppColors.white)
      ..eye(p(x - 0.04, y - 0.1), u(0.03))
      ..eye(p(x + 0.04, y - 0.1), u(0.03))
      ..poly([
        p(x - 0.015, y - 0.05),
        p(x + 0.015, y - 0.05),
        p(x, y),
      ], AppColors.sun);
  }

  void owl(int version) {
    fill(_night);
    stars(21 + version);
    ground(0.84, const Color(0xFF2B2A6B));
    pen.poly([p(0.1, 0.84), p(0.1, 0.62), p(0.34, 0.62), p(0.34, 0.84)], _rock);
    owlBody(0.22, 0.46);
    if (version == 1) {
      pen
        ..limb([p(0.48, 0.74), p(0.76, 0.34)], 14, AppColors.backpackShade)
        ..limb([p(0.62, 0.56), p(0.56, 0.84)], 5, AppColors.inkSoft)
        ..limb([p(0.62, 0.56), p(0.7, 0.84)], 5, AppColors.inkSoft);
    }
    if (version == 2) {
      final points = [
        p(0.5, 0.26),
        p(0.6, 0.18),
        p(0.7, 0.3),
        p(0.82, 0.2),
        p(0.9, 0.42),
        p(0.72, 0.54),
      ];
      pen.line(points);
      for (final point in points) {
        canvas.drawCircle(point, u(0.024), Paint()..color = AppColors.sun);
      }
    }
  }

  // ----------------------------------------------------------- The spring

  void steam(double x, double y) {
    for (final dx in [0.0, 0.05, -0.05]) {
      pen.line([
        p(x + dx, y),
        p(x + dx + 0.02, y - 0.08),
        p(x + dx - 0.01, y - 0.16),
        p(x + dx + 0.02, y - 0.24),
      ]);
    }
  }

  void spring(int version) {
    fill(const Color(0xFFCDE3F4));
    pen
      ..poly([p(0.1, 0.8), p(0.44, 0.14), p(0.84, 0.8)], _rock)
      ..poly([
        p(0.34, 0.34),
        p(0.44, 0.14),
        p(0.54, 0.34),
        p(0.46, 0.3),
      ], _snow);
    ground(0.74, _snow);
    if (version == 0) {
      steam(0.62, 0.5);
      return;
    }
    pen.blob([
      p(0.3, 0.86),
      p(0.46, 0.76),
      p(0.76, 0.76),
      p(0.9, 0.86),
      p(0.7, 0.96),
      p(0.44, 0.96),
    ], AppColors.brandBlue);
    steam(0.6, 0.72);
    if (version == 2) {
      // Tessa the tortoise.
      pen
        ..limb([p(0.08, 0.92), p(0.08, 0.96)], 6, AppColors.leaf)
        ..limb([p(0.22, 0.92), p(0.22, 0.96)], 6, AppColors.leaf)
        ..disc(p(0.28, 0.84), u(0.05), AppColors.leaf)
        ..eye(p(0.3, 0.83), u(0.012))
        ..blob([
          p(0.04, 0.92),
          p(0.1, 0.76),
          p(0.2, 0.76),
          p(0.26, 0.92),
        ], AppColors.buddyTealDeep);
    }
  }

  // ------------------------------------------------------------- The seed

  void seedHead(double x, double y, double radius) {
    final stem = Paint()
      ..color = AppColors.ink
      ..strokeWidth = 1.5;
    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi / 8;
      final tip = p(x, y) + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas
        ..drawLine(p(x, y), tip, stem)
        ..drawCircle(tip, 3, Paint()..color = AppColors.white);
    }
  }

  void parachute(double x, double y) {
    pen.line([p(x, y), p(x, y + 0.14)], width: 2);
    seedHead(x, y, u(0.07));
    canvas.drawCircle(p(x, y + 0.16), 3.5, Paint()..color = _brown);
  }

  void seed(int version) {
    fill(const Color(0xFFCFEFFF));
    if (version == 2) pen.disc(p(0.84, 0.2), u(0.12), AppColors.sun);
    if (version == 1) {
      ground(0.7, AppColors.brandBlue);
      for (final (x, y) in [(0.2, 0.8), (0.55, 0.9), (0.8, 0.78)]) {
        pen.line([p(x, y), p(x + 0.04, y - 0.02), p(x + 0.08, y)]);
      }
      parachute(0.46, 0.28);
      return;
    }
    hill(0.62, const Color(0xFF8FC96E));
    pen.limb([p(0.42, 0.92), p(0.42, 0.42)], 4, AppColors.leaf);
    if (version == 0) {
      seedHead(0.42, 0.36, u(0.16));
      parachute(0.68, 0.2);
    } else {
      for (var i = 0; i < 10; i++) {
        final angle = i * math.pi / 5;
        pen.disc(
          p(0.42, 0.36) + Offset(math.cos(angle), math.sin(angle)) * u(0.09),
          u(0.05),
          AppColors.sun,
        );
      }
      pen.disc(p(0.42, 0.36), u(0.07), AppColors.backpackShade);
    }
  }

  // ------------------------------------------------------------ The robot

  void robotBody(double x, double y, double s, {bool dusty = false}) {
    final body = dusty ? const Color(0xFFD9A07A) : AppColors.sun;
    final head = dusty ? const Color(0xFFE8BFA3) : AppColors.white;
    pen
      ..limb(
        [p(x - 0.05 * s, y + 0.2 * s), p(x + 0.05 * s, y + 0.2 * s)],
        10,
        AppColors.inkSoft,
      )
      ..poly([
        p(x - 0.07 * s, y - 0.02 * s),
        p(x + 0.07 * s, y - 0.02 * s),
        p(x + 0.07 * s, y + 0.18 * s),
        p(x - 0.07 * s, y + 0.18 * s),
      ], body)
      ..poly([
        p(x - 0.06 * s, y - 0.2 * s),
        p(x + 0.06 * s, y - 0.2 * s),
        p(x + 0.06 * s, y - 0.02 * s),
        p(x - 0.06 * s, y - 0.02 * s),
      ], head)
      ..eye(p(x - 0.025 * s, y - 0.11 * s), u(0.022 * s))
      ..eye(p(x + 0.025 * s, y - 0.11 * s), u(0.022 * s));
  }

  void robot(int version) {
    fill(version == 2 ? const Color(0xFF6E8FBF) : _marsSky);
    if (version == 2) {
      canvas.drawCircle(
        p(0.82, 0.6),
        u(0.3),
        Paint()..color = _ice.withValues(alpha: 0.5),
      );
      canvas.drawCircle(
        p(0.82, 0.6),
        u(0.06),
        Paint()..color = AppColors.white,
      );
    }
    ground(0.74, _mars);
    if (version == 0) {
      robotBody(0.28, 0.56, 1);
      robotBody(0.62, 0.56, 0.8, dusty: true);
      robotBody(0.84, 0.56, 0.8, dusty: true);
    } else if (version == 1) {
      robotBody(0.24, 0.56, 1);
      pen
        ..poly([
          p(0.46, 0.5),
          p(0.9, 0.5),
          p(0.84, 0.72),
          p(0.4, 0.72),
        ], AppColors.brandBlueDeep)
        ..blob([
          p(0.68, 0.5),
          p(0.8, 0.5),
          p(0.82, 0.68),
          p(0.64, 0.7),
        ], const Color(0xFFD9A07A))
        ..limb([p(0.31, 0.58), p(0.46, 0.58)], 4, AppColors.inkSoft);
    } else {
      robotBody(0.2, 0.56, 0.9);
      robotBody(0.42, 0.56, 0.9);
      robotBody(0.64, 0.56, 0.9);
    }
  }

  // ----------------------------------------------------------- The fossil

  void spiral(double x, double y, double radius) {
    pen.disc(p(x, y), radius, AppColors.paper);
    final points = [
      for (var t = 0.0; t < 3 * 2 * math.pi; t += 0.3)
        p(x, y) +
            Offset(math.cos(t), math.sin(t)) *
                (radius * 0.9 * t / (6 * math.pi)),
    ];
    pen.line(points, width: 2);
  }

  void fossil(int version) {
    if (version == 2) {
      fill(const Color(0xFFFFE9B8));
      ground(0.8, const Color(0xFFB9743C));
      pen.poly([
        p(0.3, 0.8),
        p(0.7, 0.8),
        p(0.7, 0.68),
        p(0.3, 0.68),
      ], AppColors.paper);
      spiral(0.5, 0.42, u(0.2));
      canvas.drawRect(
        Rect.fromPoints(p(0.3, 0.14), p(0.7, 0.68)),
        Paint()..color = AppColors.white.withValues(alpha: 0.25),
      );
      pen.line([p(0.3, 0.68), p(0.3, 0.14), p(0.7, 0.14), p(0.7, 0.68)]);
      return;
    }
    fill(const Color(0xFFCFEFFF));
    if (version == 0) {
      final bands = [
        (0.12, const Color(0xFFB9A58A)),
        (0.28, const Color(0xFF9A8570)),
        (0.44, const Color(0xFFC9B79A)),
        (0.58, const Color(0xFF8A7560)),
      ];
      for (final (y, color) in bands) {
        pen.poly([
          p(0.02, 0.76),
          p(0.02, y),
          p(0.72, y + 0.02),
          p(0.84, 0.76),
        ], color);
      }
      ground(0.76, const Color(0xFFE5CE93));
      pen.blob([
        p(0.42, 0.9),
        p(0.5, 0.74),
        p(0.68, 0.74),
        p(0.74, 0.9),
      ], _rock);
      spiral(0.58, 0.84, u(0.05));
      return;
    }
    fill(const Color(0xFFE5CE93));
    spiral(0.42, 0.5, u(0.3));
    pen
      ..limb([p(0.92, 0.1), p(0.7, 0.62)], 8, const Color(0xFFB9743C))
      ..poly([
        p(0.66, 0.6),
        p(0.76, 0.64),
        p(0.68, 0.76),
        p(0.6, 0.72),
      ], AppColors.sun);
  }

  // -------------------------------------------------------- The butterfly

  void butterfly(double x, double y, double s) {
    pen
      ..blob([
        p(x, y),
        p(x - 0.07 * s, y - 0.14 * s),
        p(x - 0.11 * s, y - 0.02 * s),
      ], _orange)
      ..blob([
        p(x, y),
        p(x + 0.07 * s, y - 0.14 * s),
        p(x + 0.11 * s, y - 0.02 * s),
      ], _orange)
      ..blob([
        p(x, y),
        p(x - 0.08 * s, y + 0.02 * s),
        p(x - 0.05 * s, y + 0.1 * s),
      ], _orange)
      ..blob([
        p(x, y),
        p(x + 0.08 * s, y + 0.02 * s),
        p(x + 0.05 * s, y + 0.1 * s),
      ], _orange)
      ..limb([p(x, y - 0.06 * s), p(x, y + 0.06 * s)], 2, AppColors.ink);
  }

  void monarch(int version) {
    fill(const Color(0xFFCFEFFF));
    if (version == 0) {
      ground(0.74, const Color(0xFFD9C66C));
      flower(0.3, 0.62, AppColors.coral);
      flower(0.72, 0.66, AppColors.grape);
      butterfly(0.5, 0.34, 1.7);
      return;
    }
    if (version == 1) {
      pen
        ..poly([
          p(-0.05, 0.92),
          p(0.24, 0.42),
          p(0.54, 0.92),
        ], const Color(0xFF8A95B5))
        ..poly([p(0.34, 0.92), p(0.68, 0.34), p(1.05, 0.92)], _rock);
      ground(0.86, const Color(0xFF8FC96E));
      for (final (x, y) in [
        (0.14, 0.2),
        (0.38, 0.3),
        (0.58, 0.14),
        (0.86, 0.24),
      ]) {
        butterfly(x, y, 0.8);
      }
      return;
    }
    ground(0.86, const Color(0xFF8FC96E));
    for (final x in [0.16, 0.5, 0.84]) {
      pen.limb([p(x, 0.9), p(x, 0.7)], 7, _brown);
      pen.poly([
        p(x - 0.15, 0.72),
        p(x, 0.08),
        p(x + 0.15, 0.72),
      ], const Color(0xFF3E8E5A));
      for (final (dx, y) in [
        (0.0, 0.26),
        (-0.06, 0.46),
        (0.06, 0.5),
        (-0.03, 0.62),
      ]) {
        butterfly(x + dx, y, 0.45);
      }
    }
  }
}
