import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/repositories/creations_repository.dart';
import '../../data/repositories/mission_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/quiz_repository.dart';
import '../../data/repositories/story_repository.dart';
import '../../domain/voice/buddy_voice.dart';
import '../../domain/wardrobe/buddy_wardrobe.dart';
import '../../domain/wardrobe/wardrobe.dart';
import '../core/themes/app_colors.dart';
import '../core/themes/app_theme.dart';
import '../core/widgets/buddy/buddy.dart';
import '../core/widgets/motion.dart';
import '../missions/widgets/stage_widgets.dart';
import 'wardrobe_view_model.dart';

/// Dress up Buddy with what has been earned. He wears it everywhere.
class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({
    super.key,
    required this.progressRepository,
    required this.missionRepository,
    required this.storyRepository,
    required this.quizRepository,
    required this.creationsRepository,
    required this.voice,
    required this.wardrobe,
  });

  final ProgressRepository progressRepository;
  final MissionRepository missionRepository;
  final StoryRepository storyRepository;
  final QuizRepository quizRepository;
  final CreationsRepository creationsRepository;
  final BuddyVoice voice;
  final BuddyWardrobe wardrobe;

  static const title = "Buddy's Wardrobe";
  static const help =
      'Tap something you have earned to put it on Buddy. Tap '
      'it again to take it off.';
  static const wearing = 'Wearing';
  static const errorMessage =
      "Buddy couldn't open his wardrobe. Please try again.";
  static const retryLabel = 'Try again';

  static String unlocked(int n, int total) => '$n of $total earned';
  static String itemLabel(String title, {required bool worn}) =>
      '$title, ${worn ? 'wearing' : 'tap to wear'}';

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  late final WardrobeViewModel _vm = WardrobeViewModel(
    progressRepository: widget.progressRepository,
    missionRepository: widget.missionRepository,
    storyRepository: widget.storyRepository,
    quizRepository: widget.quizRepository,
    creationsRepository: widget.creationsRepository,
    voice: widget.voice,
    wardrobe: widget.wardrobe,
  );

  @override
  void initState() {
    super.initState();
    unawaited(_open());
  }

  Future<void> _open() async {
    await _vm.load();
    if (mounted) _vm.narrateIntro();
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: .stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        WardrobeScreen.title,
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._body(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    switch (_vm.status) {
      case WardrobeStatus.loading:
        return const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                semanticsLabel: "Opening Buddy's wardrobe",
              ),
            ),
          ),
        ];
      case WardrobeStatus.error:
        return [
          Text(WardrobeScreen.errorMessage, style: textTheme.bodyLarge),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton(
              onPressed: () => unawaited(_open()),
              child: const Text(WardrobeScreen.retryLabel),
            ),
          ),
        ];
      case WardrobeStatus.ready:
        return [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: AppShapes.sticker(AppColors.buddyBelly),
            child: Column(
              children: [
                const Buddy(height: 190, waveOnAppear: false),
                const SizedBox(height: 8),
                Text(
                  WardrobeScreen.unlocked(
                    _vm.unlockedCount,
                    WardrobeItem.values.length,
                  ),
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                MissionVoiceBar(
                  canSpeak: _vm.canSpeak,
                  isSpeaking: _vm.isSpeaking,
                  onHearAgain: _vm.lastSpoken == null ? null : _vm.hearAgain,
                  onStop: () => unawaited(_vm.stopSpeaking()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(WardrobeScreen.help, style: textTheme.bodyLarge),
          for (final slot in WardrobeSlot.values) ...[
            const SizedBox(height: 18),
            Semantics(
              header: true,
              child: Text(slot.title, style: textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            for (final item in WardrobeItem.values.where((i) => i.slot == slot))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _ItemTile(
                  item: item,
                  unlocked: _vm.isUnlocked(item),
                  worn: _vm.look.inSlot(slot) == item,
                  hint: _vm.progressText(item),
                  onTap: () => _vm.toggle(item),
                ),
              ),
          ],
        ];
    }
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({
    required this.item,
    required this.unlocked,
    required this.worn,
    required this.hint,
    required this.onTap,
  });

  final WardrobeItem item;
  final bool unlocked;
  final bool worn;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      button: unlocked,
      selected: worn,
      label: unlocked
          ? WardrobeScreen.itemLabel(item.title, worn: worn)
          : '${item.title}, locked, $hint',
      excludeSemantics: true,
      child: StickerPress(
        enabled: unlocked,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: unlocked ? onTap : null,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              decoration: BoxDecoration(
                color: worn
                    ? AppColors.leafTint
                    : unlocked
                    ? AppColors.white
                    : AppColors.paper,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.ink, width: worn ? 3 : 1.5),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: AppTheme.minTouchTarget + 4,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        worn
                            ? Icons.check_circle_rounded
                            : unlocked
                            ? Icons.checkroom_rounded
                            : Icons.lock_rounded,
                        color: unlocked ? AppColors.ink : AppColors.inkSoft,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Text(item.title, style: textTheme.titleMedium),
                            if (worn)
                              Text(
                                WardrobeScreen.wearing,
                                style: textTheme.bodyMedium,
                              )
                            else if (!unlocked)
                              Text(hint, style: textTheme.bodyMedium),
                          ],
                        ),
                      ),
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
}
