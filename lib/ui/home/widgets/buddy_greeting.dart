import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/buddy/buddy.dart';

/// Buddy with a speech bubble. The text is always on screen; [onSpeak] adds
/// an optional "Hear Buddy" button only when speech is available.
class BuddyGreeting extends StatelessWidget {
  const BuddyGreeting({super.key, required this.text, this.onSpeak});

  final String text;
  final VoidCallback? onSpeak;

  static const _tailWidth = 14.0;

  @override
  Widget build(BuildContext context) {
    final speak = onSpeak;
    return Row(
      crossAxisAlignment: .center,
      children: [
        const Buddy(height: 132),
        const SizedBox(width: 6),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                margin: const EdgeInsets.only(left: _tailWidth),
                padding: const EdgeInsets.all(16),
                decoration: AppShapes.sticker(AppColors.white, depth: 4),
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisSize: .min,
                  children: [
                    Text(text, style: Theme.of(context).textTheme.bodyLarge),
                    if (speak != null) ...[
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: speak,
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text('Hear Buddy'),
                      ),
                    ],
                  ],
                ),
              ),
              const Positioned(
                left: 0,
                top: 24,
                child: CustomPaint(
                  size: Size(_tailWidth + 3, 22),
                  painter: _BubbleTailPainter(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small triangle pointing at Buddy. Its fill covers the bubble's border
/// where they join so the outline reads as one shape.
class _BubbleTailPainter extends CustomPainter {
  const _BubbleTailPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const join = BuddyGreeting._tailWidth;
    final fill = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(size.width, size.height)
      ..close();
    final edge = Path()
      ..moveTo(join + 1, 0)
      ..lineTo(0, size.height / 2)
      ..lineTo(join + 1, size.height);
    canvas
      ..drawPath(fill, Paint()..color = AppColors.white)
      ..drawPath(
        edge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = AppShapes.outlineWidth
          ..strokeJoin = StrokeJoin.round
          ..color = AppColors.ink,
      );
  }

  @override
  bool shouldRepaint(_BubbleTailPainter oldDelegate) => false;
}
