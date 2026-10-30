import 'dart:async';

import 'package:flutter/material.dart';

import '../../../domain/games/games.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';
import '../../core/widgets/buddy/buddy.dart';
import '../../core/widgets/motion.dart';
import '../../missions/widgets/stage_widgets.dart';
import '../../quiz/widgets/quiz_widgets.dart';
import '../game_view_models.dart';
import 'picture_art.dart';

/// Draws a game token: a coloured shape, or a number.
class TokenView extends StatelessWidget {
  const TokenView({super.key, required this.token, this.size = 40});

  final GameToken token;
  final double size;

  static Color colorOf(GameColor color) => switch (color) {
    GameColor.coral => AppColors.coral,
    GameColor.sun => AppColors.sun,
    GameColor.leaf => AppColors.leaf,
    GameColor.blue => AppColors.brandBlue,
    GameColor.grape => AppColors.grape,
  };

  static IconData iconOf(GameShape shape) => switch (shape) {
    GameShape.circle => Icons.circle,
    GameShape.square => Icons.square_rounded,
    // Solid like the other shapes; turned to point up in [build].
    GameShape.triangle => Icons.play_arrow_rounded,
    GameShape.star => Icons.star_rounded,
    GameShape.heart => Icons.favorite_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final picture = token.picture;
    if (picture != null) {
      return PictureArt(picture: picture, size: size);
    }
    final number = token.number;
    if (number != null) {
      return SizedBox(
        width: size * 1.3,
        height: size,
        child: FittedBox(
          child: Text(
            '$number',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      );
    }
    final icon = Icon(
      iconOf(token.shape!),
      size: size,
      color: colorOf(token.color!),
      semanticLabel: token.label,
    );
    return token.shape == GameShape.triangle
        ? RotatedBox(quarterTurns: 3, child: icon)
        : icon;
  }
}

/// The frame shared by the games: voice controls, the game, and the finish
/// panel.
class GameShell extends StatelessWidget {
  const GameShell({
    super.key,
    required this.vm,
    required this.child,
    this.nextButton,
    this.nextResult,
    this.backButton = backLabel,
    this.finishExtra,
  });

  final GamePlayViewModel vm;
  final Widget child;

  /// The label for moving on, if there is something to move on to. The screen
  /// closes with [nextResult].
  final String? nextButton;
  final Object? nextResult;
  final String backButton;

  /// Shown under the stars when the game is finished.
  final Widget? finishExtra;

  static const playAgainLabel = 'Play again';
  static const nextLabel = 'Next level';
  static const backLabel = 'Back to the Arena';
  static const saveFailed =
      "Your stars are shown, but they couldn't be saved this time.";
  static const noStarsNote =
      'Get 3 right to earn a star and open the next '
      'level.';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CelebrationOverlay(
      listenable: vm,
      celebrationKey: () => vm.isFinished && vm.stars == 3 ? 'stars' : null,
      child: Scaffold(
        appBar: AppBar(title: Text(vm.gameTitle, style: textTheme.titleMedium)),
        body: SafeArea(
          child: ListenableBuilder(
            listenable: vm,
            builder: (context, _) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      Row(
                        children: [
                          Buddy(
                            height: 72,
                            mood: vm.isFinished
                                ? BuddyMood.excited
                                : BuddyMood.curious,
                            waveOnAppear: false,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: MissionVoiceBar(
                              canSpeak: vm.canSpeak,
                              isSpeaking: vm.isSpeaking,
                              onHearAgain: vm.lastSpoken == null
                                  ? null
                                  : vm.hearAgain,
                              onStop: () => unawaited(vm.stopSpeaking()),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (vm.isFinished) _finish(context) else child,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _finish(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final next = nextButton;
    final extra = finishExtra;
    return Column(
      crossAxisAlignment: .stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: AppShapes.sticker(AppColors.sunTint, depth: 4),
          child: Column(
            children: [
              Semantics(
                header: true,
                child: Text(
                  vm.finishLine,
                  style: textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              QuizStars(stars: vm.stars, size: 36, animate: true),
              if (vm.stars == 0) ...[
                const SizedBox(height: 8),
                Text(
                  noStarsNote,
                  style: textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        if (extra != null) ...[const SizedBox(height: 12), extra],
        if (vm.saveStatus == GameSaveStatus.failed) ...[
          const SizedBox(height: 12),
          Text(saveFailed, style: textTheme.bodyMedium),
        ],
        const SizedBox(height: 16),
        if (next != null && vm.stars > 0) ...[
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(nextResult),
            icon: const Icon(Icons.arrow_upward_rounded),
            label: Text(next),
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          onPressed: vm.playAgain,
          icon: const Icon(Icons.replay_rounded),
          label: const Text(playAgainLabel),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
          label: Text(backButton),
        ),
      ],
    );
  }
}
