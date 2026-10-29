import 'package:flutter/material.dart';

import '../../../domain/voice/buddy_voice.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/buddy/buddy.dart';

/// Buddy with a speech bubble and voice controls.
///
/// The text is always on screen, so speech only ever adds to it. Controls
/// depend on the voice:
/// * available, on: "Hear again" and "Voice off"
/// * available, off: "Voice on"
/// * unavailable: a short read-along note, no buttons
class BuddyGreeting extends StatelessWidget {
  const BuddyGreeting({
    super.key,
    required this.text,
    required this.voiceStatus,
    required this.isMuted,
    required this.onReplay,
    required this.onToggleMuted,
  });

  final String text;
  final VoiceStatus voiceStatus;
  final bool isMuted;
  final VoidCallback onReplay;
  final VoidCallback onToggleMuted;

  static const replayLabel = 'Hear again';
  static const voiceOffLabel = 'Voice off';
  static const voiceOnLabel = 'Voice on';
  static const unavailableMessage =
      "Buddy can't talk on this phone right now, but you can read along!";

  static const _tailWidth = 14.0;

  @override
  Widget build(BuildContext context) {
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
                    ..._voiceControls(context),
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

extension on BuddyGreeting {
  List<Widget> _voiceControls(BuildContext context) {
    switch (voiceStatus) {
      case VoiceStatus.checking:
        return const [];
      case VoiceStatus.unavailable:
        return [
          const SizedBox(height: 8),
          Text(
            BuddyGreeting.unavailableMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ];
      case VoiceStatus.available:
        return [
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (!isMuted)
                FilledButton.icon(
                  onPressed: onReplay,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text(BuddyGreeting.replayLabel),
                ),
              OutlinedButton.icon(
                onPressed: onToggleMuted,
                icon: Icon(
                  isMuted ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                ),
                label: Text(
                  isMuted
                      ? BuddyGreeting.voiceOnLabel
                      : BuddyGreeting.voiceOffLabel,
                ),
              ),
            ],
          ),
        ];
    }
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
