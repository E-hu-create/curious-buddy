import 'package:flutter/material.dart';

import '../../../domain/games/robot.dart';
import '../../core/themes/app_colors.dart';
import 'ink_pen.dart';

Offset _o(double x, double y) => Offset(x, y);

/// The little robot the child programs.
class RobotFigure extends StatelessWidget {
  const RobotFigure({super.key, this.size = 40});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: const _RobotPainter());
}

class _RobotPainter extends CustomPainter {
  const _RobotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 100);
    InkPen(canvas, outline: 4)
      ..line([_o(50, 22), _o(50, 8)], width: 4)
      ..disc(_o(50, 8), 6, AppColors.coral)
      ..limb([_o(12, 56), _o(12, 72)], 8, AppColors.backpackShade)
      ..limb([_o(88, 56), _o(88, 72)], 8, AppColors.backpackShade)
      ..limb([_o(34, 86), _o(34, 94)], 12, AppColors.inkSoft)
      ..limb([_o(66, 86), _o(66, 94)], 12, AppColors.inkSoft)
      ..poly([_o(22, 50), _o(78, 50), _o(78, 88), _o(22, 88)], AppColors.sun)
      ..poly([_o(20, 20), _o(80, 20), _o(80, 52), _o(20, 52)], AppColors.white)
      ..eye(_o(37, 36), 7)
      ..eye(_o(63, 36), 7)
      ..disc(_o(50, 69), 7, AppColors.coral);
  }

  @override
  bool shouldRepaint(_RobotPainter old) => false;
}

/// The grid with its rocks and flag. The robot is placed on top.
class RobotGridArt extends StatelessWidget {
  const RobotGridArt({super.key, required this.puzzle});

  final RobotPuzzle puzzle;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _GridPainter(puzzle), size: Size.infinite);
}

class _GridPainter extends CustomPainter {
  const _GridPainter(this.puzzle);

  final RobotPuzzle puzzle;

  static const _light = Color(0xFFDCE9FF);
  static const _dark = Color(0xFFC6DAFB);
  static const _rock = Color(0xFF8E96AB);

  @override
  void paint(Canvas canvas, Size size) {
    final cell = size.width / puzzle.size;
    for (var i = 0; i < puzzle.size * puzzle.size; i++) {
      final row = i ~/ puzzle.size;
      final column = i % puzzle.size;
      canvas.drawRect(
        Rect.fromLTWH(column * cell, row * cell, cell, cell),
        Paint()..color = (row + column).isEven ? _light : _dark,
      );
    }
    for (final rock in puzzle.rocks) {
      _inCell(canvas, rock, cell, (pen) {
        pen.blob([
          _o(14, 76),
          _o(22, 38),
          _o(48, 20),
          _o(76, 32),
          _o(88, 76),
        ], _rock);
      });
    }
    _inCell(canvas, puzzle.goal, cell, (pen) {
      pen
        ..limb([_o(34, 14), _o(34, 88)], 4, AppColors.inkSoft)
        ..poly([_o(36, 14), _o(82, 30), _o(36, 46)], AppColors.leaf);
    });
  }

  void _inCell(
    Canvas canvas,
    int index,
    double cell,
    void Function(InkPen) draw,
  ) {
    canvas
      ..save()
      ..translate((index % puzzle.size) * cell, (index ~/ puzzle.size) * cell)
      ..scale(cell / 100);
    draw(InkPen(canvas, outline: 4));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.puzzle != puzzle;
}
