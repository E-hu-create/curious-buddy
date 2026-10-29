import 'package:flutter/material.dart';

import '../../../domain/voice/buddy_voice.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/buddy/buddy.dart';

/// Buddy with his speech bubble: what the child asked, Buddy's reply, an
/// optional activity to open, and voice controls.
///
/// The reply is always on screen, so speech only ever adds to it. Voice
/// controls:
/// * available, on, talking: "Stop talking" and "Voice off"
/// * available, on, quiet: "Hear again" and "Voice off"
/// * available, off: "Voice on"
/// * unavailable: a short read-along note, no buttons
class BuddyGreeting extends StatelessWidget {
  const BuddyGreeting({
    super.key,
    required this.text,
    required this.voiceStatus,
    required this.isMuted,
    this.onReplay,
    required this.onToggleMuted,
    this.isSpeaking = false,
    this.onStop,
    this.mood = BuddyMood.happy,
    this.youAsked,
    this.questionHidden = false,
    this.actionLabel,
    this.onAction,
    this.status,
  });

  final String text;
  final VoiceStatus voiceStatus;
  final bool isMuted;
  final bool isSpeaking;
  final BuddyMood mood;
  final String? youAsked;
  final bool questionHidden;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// What Buddy is doing ("Talking...", "Thinking..."), shown under him.
  /// Null when idle.
  final BuddyStatus? status;

  /// Null disables "Hear again" (e.g. while Buddy is listening).
  final VoidCallback? onReplay;
  final VoidCallback? onStop;
  final VoidCallback onToggleMuted;

  static const replayLabel = 'Hear again';
  static const stopLabel = 'Stop talking';
  static const voiceOffLabel = 'Voice off';
  static const voiceOnLabel = 'Voice on';
  static const unavailableMessage =
      "Buddy can't talk on this phone right now, but you can read along!";
  static const hiddenQuestionNote =
      "You shared something private, so I'm not showing it.";

  static String youAskedLabel(String question) => 'You asked: "$question"';

  static const _tailWidth = 14.0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final asked = youAsked;
    final action = onAction;
    final label = actionLabel;
    return Row(
      crossAxisAlignment: .center,
      children: [
        Column(
          mainAxisSize: .min,
          children: [
            Buddy(height: 132, mood: mood),
            if (status case final status?) ...[
              const SizedBox(height: 6),
              _StatusBadge(status),
            ],
          ],
        ),
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
                    if (questionHidden)
                      _Note(BuddyGreeting.hiddenQuestionNote)
                    else if (asked != null)
                      _Note(BuddyGreeting.youAskedLabel(asked)),
                    // Announced by screen readers whenever Buddy replies.
                    Semantics(
                      liveRegion: true,
                      child: Text(text, style: textTheme.bodyLarge),
                    ),
                    if (action != null && label != null) ...[
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: action,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(label),
                      ),
                    ],
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

enum BuddyStatus {
  thinking('Thinking...', Icons.more_horiz_rounded),
  talking('Talking...', Icons.graphic_eq_rounded),
  listening('Listening...', Icons.hearing_rounded);

  const BuddyStatus(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge(this.status);

  final BuddyStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.sunTint,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.ink, width: 1.5),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          Icon(status.icon, size: 16, color: AppColors.ink),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
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
              if (isSpeaking)
                FilledButton.icon(
                  onPressed: onStop,
                  icon: const Icon(Icons.stop_rounded),
                  label: const Text(BuddyGreeting.stopLabel),
                )
              else if (!isMuted)
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
