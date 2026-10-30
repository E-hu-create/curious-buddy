import 'package:flutter/material.dart';

import '../../../domain/games/maze.dart';
import '../../core/themes/app_colors.dart';
import 'ink_pen.dart';

/// A drawn maze with its gems and treasure chest. Buddy is placed on top.
class MazeArt extends StatelessWidget {
  const MazeArt({super.key, required this.game});

  final MazeGame game;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _MazePainter(game), size: Size.infinite);
}

Offset _o(double x, double y) => Offset(x, y);

class _MazePainter extends CustomPainter {
  const _MazePainter(this.game);

  final MazeGame game;

  static const _floor = Color(0xFFE9F7D9);
  static const _gem = Color(0xFF5CC8F2);
  static const _wood = Color(0xFFB9743C);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / game.size;
    canvas.drawRect(Offset.zero & size, Paint()..color = _floor);
    for (final index in game.gems.difference(game.collected)) {
      _inCell(canvas, index, cell, _drawGem);
    }
    _inCell(canvas, game.treasure, cell, _drawChest);

    final wall = Paint()
      ..color = AppColors.ink
      ..strokeWidth = (cell / 9).clamp(2.5, 5)
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < game.openings.length; i++) {
      final x = (i % game.size) * cell;
      final y = (i ~/ game.size) * cell;
      final open = game.openings[i];
      if (!open.contains(MazeDirection.up)) {
        canvas.drawLine(_o(x, y), _o(x + cell, y), wall);
      }
      if (!open.contains(MazeDirection.left)) {
        canvas.drawLine(_o(x, y), _o(x, y + cell), wall);
      }
      if (!open.contains(MazeDirection.right)) {
        canvas.drawLine(_o(x + cell, y), _o(x + cell, y + cell), wall);
      }
      if (!open.contains(MazeDirection.down)) {
        canvas.drawLine(_o(x, y + cell), _o(x + cell, y + cell), wall);
      }
    }
  }

  /// Runs [draw] on a 100 by 100 grid inside one cell.
  void _inCell(
    Canvas canvas,
    int index,
    double cell,
    void Function(InkPen) draw,
  ) {
    canvas
      ..save()
      ..translate((index % game.size) * cell, (index ~/ game.size) * cell)
      ..scale(cell / 100);
    draw(InkPen(canvas, outline: 4));
    canvas.restore();
  }

  void _drawGem(InkPen pen) {
    pen
      ..poly([_o(34, 26), _o(66, 26), _o(82, 44), _o(50, 80), _o(18, 44)], _gem)
      ..line([_o(18, 44), _o(82, 44)], width: 3);
  }

  void _drawChest(InkPen pen) {
    pen
      ..poly([_o(16, 48), _o(84, 48), _o(84, 82), _o(16, 82)], _wood)
      ..blob([
        _o(16, 50),
        _o(20, 28),
        _o(50, 20),
        _o(80, 28),
        _o(84, 50),
      ], AppColors.backpackShade)
      ..poly([_o(42, 42), _o(58, 42), _o(58, 62), _o(42, 62)], AppColors.sun);
  }

  @override
  bool shouldRepaint(_MazePainter old) => true;
}
