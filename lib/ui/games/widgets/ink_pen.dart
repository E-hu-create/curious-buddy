import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';

/// Draws the sticker style used for game pictures: flat colour with an ink
/// outline. Pictures are sketched as a few points, which are smoothed here.
class InkPen {
  InkPen(this.canvas, {this.outline = 1.5});

  final Canvas canvas;
  final double outline;

  Paint get _ink => Paint()
    ..color = AppColors.ink
    ..style = PaintingStyle.stroke
    ..strokeWidth = outline
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round;

  void _fillAndOutline(Path path, Color fill) {
    canvas
      ..drawPath(path, Paint()..color = fill)
      ..drawPath(path, _ink);
  }

  /// A smooth closed shape through [points].
  void blob(List<Offset> points, Color fill) {
    final n = points.length;
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    for (var i = 0; i < n; i++) {
      final before = points[(i + n - 1) % n];
      final from = points[i];
      final to = points[(i + 1) % n];
      final after = points[(i + 2) % n];
      final a = from + (to - before) / 6;
      final b = to - (after - from) / 6;
      path.cubicTo(a.dx, a.dy, b.dx, b.dy, to.dx, to.dy);
    }
    _fillAndOutline(path..close(), fill);
  }

  /// A closed shape with sharp corners.
  void poly(List<Offset> points, Color fill) {
    _fillAndOutline(Path()..addPolygon(points, true), fill);
  }

  /// A thick rounded stroke: a leg, an arm, a branch.
  void limb(List<Offset> points, double width, Color fill) {
    final path = Path()..addPolygon(points, false);
    Paint stroke(Color color, double w) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;
    canvas
      ..drawPath(path, stroke(AppColors.ink, width + outline * 2))
      ..drawPath(path, stroke(fill, width));
  }

  void disc(Offset center, double radius, Color fill) {
    _fillAndOutline(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      fill,
    );
  }

  /// A plain ink line with no fill.
  void line(List<Offset> points, {double? width}) {
    canvas.drawPath(
      Path()..addPolygon(points, false),
      _ink..strokeWidth = width ?? outline,
    );
  }

  /// A friendly eye with a small highlight.
  void eye(Offset center, [double radius = 2]) {
    canvas
      ..drawCircle(center, radius, Paint()..color = AppColors.ink)
      ..drawCircle(
        center + Offset(-radius * 0.3, -radius * 0.35),
        radius * 0.35,
        Paint()..color = AppColors.white,
      );
  }
}
