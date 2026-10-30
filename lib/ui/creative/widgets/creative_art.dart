import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/creative/creation.dart';
import '../../core/themes/app_colors.dart';

/// The 8 colours shared by drawings and creatures (saved by index).
abstract final class CreativePalette {
  static const colors = [
    AppColors.ink,
    AppColors.coral,
    AppColors.sun,
    AppColors.leaf,
    AppColors.brandBlue,
    AppColors.grape,
    Color(0xFFFF8FB1),
    Color(0xFF9C6B45),
  ];
  static const names = [
    'Navy',
    'Coral',
    'Yellow',
    'Green',
    'Blue',
    'Purple',
    'Pink',
    'Brown',
  ];

  static const paper = AppColors.white;

  /// Brush widths in canvas units (of 1000).
  static const sizes = [8.0, 18.0, 36.0];
  static const sizeNames = ['Thin', 'Medium', 'Thick'];

  static Color color(int index) => colors[index.clamp(0, colors.length - 1)];
}

/// Draws a [Drawing]'s strokes (plus one in progress) at any size.
class DrawingPainter extends CustomPainter {
  const DrawingPainter({required this.strokes, this.active});

  final List<Stroke> strokes;
  final Stroke? active;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = CreativePalette.paper);
    final k = size.width / DrawPoint.scale;
    for (final stroke in [...strokes, ?active]) {
      final width =
          CreativePalette.sizes[stroke.sizeIndex] *
          k *
          (stroke.eraser ? 1.6 : 1);
      final paint = Paint()
        ..color = stroke.eraser
            ? CreativePalette.paper
            : CreativePalette.color(stroke.colorIndex)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      final points = stroke.points;
      if (points.length == 1) {
        canvas.drawCircle(
          Offset(points.first.x * k, points.first.y * k),
          width / 2,
          paint..style = PaintingStyle.fill,
        );
        continue;
      }
      final path = Path()..moveTo(points.first.x * k, points.first.y * k);
      for (final p in points.skip(1)) {
        path.lineTo(p.x * k, p.y * k);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

/// Draws a [Creature] in the app's sticker style.
class CreaturePainter extends CustomPainter {
  const CreaturePainter(this.creature);

  final Creature creature;

  static Paint _fill(Color c) => Paint()..color = c;
  static Paint _line(double w) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = AppColors.ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    final c = Offset(size.width / 2, size.height * 0.56);
    final u = s / 100;
    final color = CreativePalette.color(creature.colorIndex);
    final line = _line(math.max(1.5, 2.4 * u / 1.2));

    final body = switch (creature.body) {
      CreatureBody.round => Rect.fromCenter(
        center: c,
        width: 60 * u,
        height: 60 * u,
      ),
      CreatureBody.tall => Rect.fromCenter(
        center: c,
        width: 44 * u,
        height: 70 * u,
      ),
      CreatureBody.wide => Rect.fromCenter(
        center: c,
        width: 76 * u,
        height: 50 * u,
      ),
      CreatureBody.blob => Rect.fromCenter(
        center: c,
        width: 64 * u,
        height: 58 * u,
      ),
    };
    final bodyPath = creature.body == CreatureBody.blob
        ? _blob(body)
        : (Path()..addOval(body));

    // Extras behind the body.
    switch (creature.extra) {
      case CreatureExtra.wings:
        for (final side in [-1.0, 1.0]) {
          final wing = Path()
            ..moveTo(c.dx + side * body.width * 0.35, c.dy - 6 * u)
            ..quadraticBezierTo(
              c.dx + side * (body.width * 0.5 + 22 * u),
              c.dy - 30 * u,
              c.dx + side * (body.width * 0.5 + 16 * u),
              c.dy + 6 * u,
            )
            ..close();
          canvas
            ..drawPath(wing, _fill(AppColors.white))
            ..drawPath(wing, line);
        }
      case CreatureExtra.horns:
        for (final side in [-1.0, 1.0]) {
          final base = Offset(
            c.dx + side * body.width * 0.22,
            body.top + 6 * u,
          );
          final horn = Path()
            ..moveTo(base.dx - 5 * u, base.dy)
            ..lineTo(base.dx + side * 6 * u, base.dy - 18 * u)
            ..lineTo(base.dx + 5 * u, base.dy + 1 * u)
            ..close();
          canvas
            ..drawPath(horn, _fill(AppColors.sunTint))
            ..drawPath(horn, line);
        }
      case CreatureExtra.antennae:
        for (final side in [-1.0, 1.0]) {
          final base = Offset(
            c.dx + side * body.width * 0.15,
            body.top + 4 * u,
          );
          final tip = base + Offset(side * 10 * u, -20 * u);
          canvas
            ..drawLine(base, tip, line)
            ..drawCircle(tip, 4 * u, _fill(AppColors.coral))
            ..drawCircle(tip, 4 * u, line);
        }
      case CreatureExtra.none:
        break;
    }

    // Body and pattern.
    canvas.drawPath(bodyPath, _fill(color));
    canvas.save();
    canvas.clipPath(bodyPath);
    final mark = _fill(Colors.white.withValues(alpha: 0.45));
    switch (creature.pattern) {
      case CreaturePattern.spots:
        for (final o in const [
          Offset(-0.28, 0.18),
          Offset(0.3, 0.26),
          Offset(0.05, 0.38),
          Offset(-0.34, -0.12),
          Offset(0.36, -0.08),
        ]) {
          canvas.drawCircle(
            c + Offset(o.dx * body.width, o.dy * body.height),
            5 * u,
            mark,
          );
        }
      case CreaturePattern.stripes:
        for (var i = -2; i <= 2; i++) {
          final y = c.dy + i * body.height * 0.18 + body.height * 0.1;
          canvas.drawRect(Rect.fromLTWH(body.left, y, body.width, 4 * u), mark);
        }
      case CreaturePattern.none:
        break;
    }
    canvas.restore();
    canvas.drawPath(bodyPath, line);

    // Belly.
    final belly = Rect.fromCenter(
      center: c + Offset(0, body.height * 0.2),
      width: body.width * 0.5,
      height: body.height * 0.34,
    );
    canvas
      ..drawOval(belly, _fill(Colors.white.withValues(alpha: 0.35)))
      ..drawOval(belly, _line(1.2 * u / 1.2));

    // Eyes.
    final eyeY = c.dy - body.height * 0.14;
    final gap = body.width * 0.18;
    final eyeCenters = creature.eyes == CreatureEyes.three
        ? [
            Offset(c.dx - gap * 1.2, eyeY),
            Offset(c.dx, eyeY - 6 * u),
            Offset(c.dx + gap * 1.2, eyeY),
          ]
        : [Offset(c.dx - gap, eyeY), Offset(c.dx + gap, eyeY)];
    final eyeR = switch (creature.eyes) {
      CreatureEyes.big => 9 * u,
      CreatureEyes.three => 5.5 * u,
      _ => 6.5 * u,
    };
    for (final e in eyeCenters) {
      if (creature.eyes == CreatureEyes.sleepy) {
        final lid = Path()
          ..moveTo(e.dx - eyeR, e.dy)
          ..quadraticBezierTo(e.dx, e.dy + eyeR * 0.9, e.dx + eyeR, e.dy);
        canvas.drawPath(lid, line);
        continue;
      }
      canvas
        ..drawCircle(e, eyeR, _fill(AppColors.white))
        ..drawCircle(e, eyeR, line)
        ..drawCircle(
          e + Offset(eyeR * 0.15, eyeR * 0.1),
          eyeR * 0.5,
          _fill(AppColors.ink),
        )
        ..drawCircle(
          e + Offset(eyeR * 0.3, -eyeR * 0.15),
          eyeR * 0.16,
          _fill(AppColors.white),
        );
    }

    // Mouth.
    final m = Offset(c.dx, c.dy + body.height * 0.04);
    final w = body.width * 0.16;
    switch (creature.mouth) {
      case CreatureMouth.smile:
        canvas.drawPath(
          Path()
            ..moveTo(m.dx - w, m.dy)
            ..quadraticBezierTo(m.dx, m.dy + w * 0.9, m.dx + w, m.dy),
          line,
        );
      case CreatureMouth.grin:
        final grin = Path()
          ..moveTo(m.dx - w * 1.2, m.dy - 1 * u)
          ..quadraticBezierTo(
            m.dx,
            m.dy + w * 1.4,
            m.dx + w * 1.2,
            m.dy - 1 * u,
          )
          ..close();
        canvas
          ..drawPath(grin, _fill(AppColors.white))
          ..drawPath(grin, line);
      case CreatureMouth.open:
        final mouth = Rect.fromCenter(
          center: m + Offset(0, 3 * u),
          width: w * 1.3,
          height: w * 1.1,
        );
        canvas
          ..drawOval(mouth, _fill(AppColors.buddyMouth))
          ..drawOval(mouth, line);
      case CreatureMouth.tongue:
        canvas.drawPath(
          Path()
            ..moveTo(m.dx - w, m.dy)
            ..quadraticBezierTo(m.dx, m.dy + w * 0.8, m.dx + w, m.dy),
          line,
        );
        final tongue = Rect.fromCenter(
          center: m + Offset(w * 0.2, w * 0.55),
          width: w * 0.7,
          height: w * 0.8,
        );
        canvas
          ..drawOval(tongue, _fill(AppColors.buddyTongue))
          ..drawOval(tongue, line);
    }

    // Feet.
    for (final side in [-1.0, 1.0]) {
      final foot = Rect.fromCenter(
        center: Offset(c.dx + side * body.width * 0.2, body.bottom),
        width: 16 * u,
        height: 8 * u,
      );
      canvas
        ..drawOval(foot, _fill(color))
        ..drawOval(foot, line);
    }
  }

  /// A soft, wobbly body shape.
  static Path _blob(Rect r) {
    final c = r.center;
    final path = Path();
    const steps = 48;
    for (var i = 0; i <= steps; i++) {
      final a = i * 2 * math.pi / steps;
      final wobble = 1 + 0.07 * math.sin(a * 5);
      final p = Offset(
        c.dx + math.cos(a) * r.width / 2 * wobble,
        c.dy + math.sin(a) * r.height / 2 * wobble,
      );
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(CreaturePainter oldDelegate) =>
      oldDelegate.creature != creature;
}

/// Plain-words descriptions, for screen readers and the viewer.
abstract final class CreationDescriptions {
  static const bodyNames = {
    CreatureBody.round: 'Round',
    CreatureBody.tall: 'Tall',
    CreatureBody.wide: 'Wide',
    CreatureBody.blob: 'Wobbly',
  };
  static const eyeNames = {
    CreatureEyes.round: 'Round',
    CreatureEyes.sleepy: 'Sleepy',
    CreatureEyes.big: 'Big',
    CreatureEyes.three: 'Three',
  };
  static const mouthNames = {
    CreatureMouth.smile: 'Smile',
    CreatureMouth.grin: 'Grin',
    CreatureMouth.open: 'Open',
    CreatureMouth.tongue: 'Tongue out',
  };
  static const extraNames = {
    CreatureExtra.none: 'None',
    CreatureExtra.wings: 'Wings',
    CreatureExtra.horns: 'Horns',
    CreatureExtra.antennae: 'Antennae',
  };
  static const patternNames = {
    CreaturePattern.none: 'Plain',
    CreaturePattern.spots: 'Spots',
    CreaturePattern.stripes: 'Stripes',
  };

  static String title(Creation c) => switch (c) {
    Drawing() => 'Drawing',
    Creature(:final name) => name,
  };

  static String describe(Creation c) => switch (c) {
    Drawing(:final colorsUsed) =>
      'A drawing with ${colorsUsed.length} '
          '${colorsUsed.length == 1 ? 'colour' : 'colours'}',
    Creature() => _creature(c),
  };

  static String _creature(Creature c) {
    final parts = [
      '${eyeNames[c.eyes]!.toLowerCase()} eyes',
      'a ${mouthNames[c.mouth]!.toLowerCase()}',
      if (c.extra != CreatureExtra.none) extraNames[c.extra]!.toLowerCase(),
      if (c.pattern != CreaturePattern.none)
        patternNames[c.pattern]!.toLowerCase(),
    ];
    final list = parts.length == 1
        ? parts.first
        : '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
    return '${c.name}: a ${bodyNames[c.body]!.toLowerCase()} '
        '${CreativePalette.names[c.colorIndex].toLowerCase()} creature with '
        '$list';
  }
}

/// A creation drawn at any size, labelled for screen readers.
class CreationPicture extends StatelessWidget {
  const CreationPicture({super.key, required this.creation});

  final Creation creation;

  @override
  Widget build(BuildContext context) => Semantics(
    label: CreationDescriptions.describe(creation),
    image: true,
    child: AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: switch (creation) {
          final Drawing d => DrawingPainter(strokes: d.strokes),
          final Creature c => CreaturePainter(c),
        },
      ),
    ),
  );
}
