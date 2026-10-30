import 'package:flutter/material.dart';

import '../../../domain/games/maze.dart';
import '../../core/themes/app_colors.dart';
import 'ink_pen.dart';

/// One wire piece, drawn in its first position and turned by the board.
class WireArt extends StatelessWidget {
  const WireArt({super.key, required this.straight, required this.lit});

  final bool straight;
  final bool lit;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _WirePainter(straight: straight, lit: lit),
    size: Size.infinite,
  );
}

class _WirePainter extends CustomPainter {
  const _WirePainter({required this.straight, required this.lit});

  final bool straight;
  final bool lit;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    final points = straight
        ? const [Offset(50, -4), Offset(50, 104)]
        : const [Offset(50, -4), Offset(50, 50), Offset(104, 50)];
    InkPen(
      canvas,
      outline: 3,
    ).limb(points, 16, lit ? AppColors.sun : AppColors.inkSoft);
  }

  @override
  bool shouldRepaint(_WirePainter old) =>
      old.straight != straight || old.lit != lit;
}

/// Words for a piece's sides, for screen readers.
String wireLabel(Set<MazeDirection> openings) =>
    openings.map((side) => side.label).join(' and ');
