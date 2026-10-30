import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/themes/app_colors.dart';

/// The bright night-sky look shared by the Game Zone's menus, so they feel
/// like a game of their own.
class GameWorld extends StatelessWidget {
  const GameWorld({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.arcade,
    appBar: AppBar(
      backgroundColor: AppColors.arcade,
      foregroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    body: CustomPaint(
      painter: const _SkyPainter(),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// The big yellow button that starts a game.
class PlayButton extends StatelessWidget {
  const PlayButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.sun,
      foregroundColor: AppColors.ink,
    ),
    icon: Icon(icon),
    label: Text(label),
  );
}

/// Faint stars, kept dim so white text stays easy to read over them.
class _SkyPainter extends CustomPainter {
  const _SkyPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final dot = Paint()..color = AppColors.arcadeGlow;
    const step = 86.0;
    for (var row = 0; row * step < size.height; row++) {
      for (var column = 0; column * step < size.width + step; column++) {
        final x = column * step + (row.isOdd ? step / 2 : 0);
        canvas.drawCircle(
          Offset(x, row * step + 20),
          (row + column).isEven ? 2.5 : 1.5,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SkyPainter old) => false;
}
