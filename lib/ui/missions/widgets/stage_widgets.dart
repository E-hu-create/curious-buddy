import 'package:flutter/material.dart';

import '../../../domain/missions/mission.dart';
import '../../../domain/missions/mission_rules.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';

/// "Hear again" / "Stop talking" for mission narration. Hidden when Buddy's
/// voice is off or unavailable; all text is on screen anyway.
class MissionVoiceBar extends StatelessWidget {
  const MissionVoiceBar({
    super.key,
    required this.canSpeak,
    required this.isSpeaking,
    required this.onHearAgain,
    required this.onStop,
  });

  final bool canSpeak;
  final bool isSpeaking;
  final VoidCallback? onHearAgain;
  final VoidCallback onStop;

  static const hearAgainLabel = 'Hear again';
  static const stopLabel = 'Stop talking';

  @override
  Widget build(BuildContext context) {
    if (!canSpeak) return const SizedBox.shrink();
    return Align(
      alignment: Alignment.centerLeft,
      child: isSpeaking
          ? FilledButton.icon(
              onPressed: onStop,
              icon: const Icon(Icons.stop_rounded),
              label: const Text(stopLabel),
            )
          : OutlinedButton.icon(
              onPressed: onHearAgain,
              icon: const Icon(Icons.replay_rounded),
              label: const Text(hearAgainLabel),
            ),
    );
  }
}

/// A clue: face down until inspected, then readable and speakable.
class ClueCard extends StatelessWidget {
  const ClueCard({
    super.key,
    required this.clue,
    required this.inspected,
    required this.onInspect,
    required this.onRead,
    required this.canSpeak,
  });

  final Clue clue;
  final bool inspected;
  final VoidCallback onInspect;
  final VoidCallback onRead;
  final bool canSpeak;

  static const inspectLabel = 'Inspect clue';

  static String readLabel(Clue clue) => 'Read "${clue.title}" aloud';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(14),
      decoration: AppShapes.sticker(
        inspected ? AppColors.white : AppColors.grapeTint,
        depth: 3,
        radius: 18,
      ),
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          Row(
            children: [
              Icon(
                inspected ? Icons.search_rounded : Icons.help_outline_rounded,
                color: AppColors.ink,
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(clue.title, style: textTheme.titleMedium)),
              if (inspected && canSpeak)
                IconButton(
                  tooltip: readLabel(clue),
                  onPressed: onRead,
                  icon: const Icon(Icons.volume_up_rounded),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (inspected)
            Text(clue.text, style: textTheme.bodyLarge)
          else
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: onInspect,
                icon: const Icon(Icons.search_rounded),
                label: const Text(inspectLabel),
              ),
            ),
        ],
      ),
    );
  }
}

/// A large, accessible answer option (single or multi select).
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.multi = false,
  });

  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    final icon = multi
        ? (selected ? Icons.check_box_rounded : Icons.check_box_outline_blank)
        : (selected
              ? Icons.radio_button_checked_rounded
              : Icons.radio_button_unchecked_rounded);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 60),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.sunTint : AppColors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.ink,
                width: selected ? 3 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.ink),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tap pieces to build the order; tap a placed piece to take it back.
class OrderBuilder extends StatelessWidget {
  const OrderBuilder({
    super.key,
    required this.total,
    required this.placed,
    required this.remaining,
    required this.onPlace,
    required this.onRemove,
    required this.onClear,
    required this.enabled,
  });

  final int total;
  final List<OrderPiece> placed;
  final List<OrderPiece> remaining;
  final ValueChanged<String> onPlace;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;
  final bool enabled;

  static const yourOrderLabel = 'Your order';
  static const piecesLabel = 'Tap the pieces in order';
  static const clearLabel = 'Start over';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Text(yourOrderLabel, style: textTheme.titleMedium),
        const SizedBox(height: 8),
        for (var i = 0; i < total; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Slot(
              number: i + 1,
              piece: i < placed.length ? placed[i] : null,
              onTap: enabled && i < placed.length
                  ? () => onRemove(placed[i].id)
                  : null,
            ),
          ),
        if (remaining.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(piecesLabel, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final piece in remaining)
                OutlinedButton(
                  onPressed: enabled ? () => onPlace(piece.id) : null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.leafTint,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  child: Text(piece.text, textAlign: TextAlign.start),
                ),
            ],
          ),
        ],
        if (placed.isNotEmpty && enabled) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onClear,
              icon: const Icon(Icons.undo_rounded),
              label: const Text(clearLabel),
            ),
          ),
        ],
      ],
    );
  }
}

class _Slot extends StatelessWidget {
  const _Slot({required this.number, required this.piece, required this.onTap});

  final int number;
  final OrderPiece? piece;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final piece = this.piece;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: onTap != null,
      label: piece == null
          ? 'Spot $number, empty'
          : 'Spot $number: ${piece.text}. Tap to take back.',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: piece == null ? AppColors.paper : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.ink, width: 1.5),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.sun,
                child: Text(
                  '$number',
                  style: textTheme.labelLarge?.copyWith(color: AppColors.ink),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  piece?.text ?? '...',
                  style: textTheme.bodyLarge?.copyWith(
                    color: piece == null ? AppColors.inkSoft : AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Encouraging result of a check, always with the reasoning.
class FeedbackPanel extends StatelessWidget {
  const FeedbackPanel({super.key, required this.result, this.explanation});

  final CheckResult result;

  /// Shown under a correct answer when it adds to the feedback.
  final String? explanation;

  static const correctTitle = 'Great reasoning!';
  static const tryAgainTitle = 'Keep investigating!';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final explanation = this.explanation;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: AppShapes.sticker(
          result.correct ? AppColors.leafTint : AppColors.coralTint,
          depth: 3,
          radius: 18,
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Row(
              children: [
                Icon(
                  result.correct
                      ? Icons.check_circle_rounded
                      : Icons.lightbulb_rounded,
                  color: AppColors.ink,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result.correct ? correctTitle : tryAgainTitle,
                    style: textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(result.feedback, style: textTheme.bodyLarge),
            if (explanation != null && explanation != result.feedback) ...[
              const SizedBox(height: 8),
              Text(explanation, style: textTheme.bodyLarge),
            ],
          ],
        ),
      ),
    );
  }
}
