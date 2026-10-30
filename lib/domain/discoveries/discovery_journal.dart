/// My Discoveries: a journal worked out from what is already saved. It
/// stores nothing of its own, so resetting progress empties it. Pure logic:
/// no Flutter, no storage.
///
/// Saved ids that no longer match any content are ignored. Story endings
/// not yet found never appear here, so nothing is spoiled.
library;

import '../games/games.dart';
import '../missions/mission.dart';
import '../models/learner_progress.dart';
import '../quiz/quiz.dart';
import '../quiz/quiz_rules.dart';
import '../stories/story.dart';

enum ExplorerRank {
  beginner('Curious Beginner', 0),
  keen('Keen Explorer', 3),
  brave('Brave Adventurer', 10),
  master('Master Discoverer', 20);

  const ExplorerRank(this.title, this.needed);

  final String title;

  /// Discoveries needed to reach this rank.
  final int needed;

  static ExplorerRank forCount(int discoveries) =>
      values.lastWhere((rank) => discoveries >= rank.needed);

  ExplorerRank? get next =>
      index + 1 < values.length ? values[index + 1] : null;
}

class BadgeEntry {
  const BadgeEntry({required this.mission, required this.earned});

  final Mission mission;
  final bool earned;
}

class StoryDiscoveries {
  const StoryDiscoveries({required this.story, required this.found});

  final Story story;

  /// Endings found, in story order.
  final List<StoryEnding> found;

  int get remaining => story.endings.length - found.length;
}

class TopicStars {
  const TopicStars({required this.topic, required this.stars});

  final QuizTopic topic;
  final int stars;

  int get maxStars => topic.levels.length * 3;
}

enum AdventureKind { mission, story, quiz, creative }

/// One suggestion for what to do next.
class NextAdventure {
  const NextAdventure({required this.kind, required this.text});

  final AdventureKind kind;
  final String text;
}

class DiscoveryJournal {
  const DiscoveryJournal({
    required this.badges,
    required this.stories,
    required this.quizzes,
    required this.creations,
    required this.next,
    this.gameStars = 0,
  });

  /// Builds the journal. A null list means that content could not be
  /// loaded; its section is left out and the rest still works.
  factory DiscoveryJournal.build({
    required LearnerProgress progress,
    List<Mission>? missions,
    List<Story>? stories,
    List<QuizTopic>? topics,
    int? creations,
  }) {
    final badges = missions == null
        ? null
        : [
            for (final m in missions)
              BadgeEntry(
                mission: m,
                earned: progress.completedMissionIds.contains(m.id),
              ),
          ];
    final storyEntries = stories == null
        ? null
        : [
            for (final s in stories)
              StoryDiscoveries(
                story: s,
                found: [
                  for (final e in s.endings)
                    if (progress.storyEndings[s.id]?.contains(e.id) ?? false) e,
                ],
              ),
          ];
    final quizEntries = topics == null
        ? null
        : [
            for (final t in topics)
              TopicStars(
                topic: t,
                stars: t.levels.fold(
                  0,
                  (sum, l) =>
                      sum +
                      QuizRules.stars(
                        progress.quizBest[l.id] ?? 0,
                        l.questions.length,
                      ),
                ),
              ),
          ];
    return DiscoveryJournal(
      badges: badges,
      stories: storyEntries,
      quizzes: quizEntries,
      creations: creations,
      gameStars: ArenaRules.totalStars(progress.gameBest),
      next: _next(progress, missions, stories, topics),
    );
  }

  final List<BadgeEntry>? badges;
  final List<StoryDiscoveries>? stories;
  final List<TopicStars>? quizzes;
  final int? creations;
  final NextAdventure next;

  /// Stars earned in the Game Zone.
  final int gameStars;

  int get casesSolved => badges?.where((b) => b.earned).length ?? 0;
  int get endingsFound =>
      stories?.fold<int>(0, (sum, s) => sum + s.found.length) ?? 0;
  int get quizStars => quizzes?.fold<int>(0, (sum, q) => sum + q.stars) ?? 0;
  int get creationCount => creations ?? 0;

  /// Everything that counts towards the explorer rank.
  int get discoveries =>
      casesSolved + endingsFound + quizStars + creationCount + gameStars;

  ExplorerRank get rank => ExplorerRank.forCount(discoveries);

  /// How many more to reach the next rank, or null at the top.
  int? get toNextRank {
    final next = rank.next;
    return next == null ? null : next.needed - discoveries;
  }

  bool get isEmpty => discoveries == 0;

  /// One or two short sentences for Buddy to read.
  String get summary {
    if (isEmpty) {
      return 'Your journal is ready for its first discovery! '
          'Everything you do will appear here.';
    }
    final parts = [
      if (casesSolved > 0) 'solved ${_n(casesSolved, 'case')}',
      if (endingsFound > 0) 'found ${_n(endingsFound, 'story ending')}',
      if (quizStars > 0) 'earned ${_n(quizStars, 'quiz star')}',
      if (creationCount > 0) 'made ${_n(creationCount, 'creation')}',
      if (gameStars > 0) 'won ${_n(gameStars, 'game star')}',
    ];
    final list = parts.length == 1
        ? parts.first
        : '${parts.sublist(0, parts.length - 1).join(', ')} '
              'and ${parts.last}';
    return "Look at everything you've done! You've $list.";
  }

  static String _n(int n, String one) => '$n $one${n == 1 ? '' : 's'}';

  /// Suggests the area with the least done so far, so the child is nudged
  /// towards something new. Ties go in the order of the Home cards.
  static NextAdventure _next(
    LearnerProgress progress,
    List<Mission>? missions,
    List<Story>? stories,
    List<QuizTopic>? topics,
  ) {
    final options = <(double, NextAdventure)>[];

    if (missions != null) {
      final open = missions.where(
        (m) => !progress.completedMissionIds.contains(m.id),
      );
      if (open.isNotEmpty) {
        options.add((
          1 - open.length / missions.length,
          NextAdventure(
            kind: AdventureKind.mission,
            text: 'Crack the case: ${open.first.title}',
          ),
        ));
      }
    }

    if (stories != null) {
      final total = stories.fold<int>(0, (sum, s) => sum + s.endings.length);
      final found = stories.fold<int>(
        0,
        (sum, s) =>
            sum +
            s.endings
                .where(
                  (e) => progress.storyEndings[s.id]?.contains(e.id) ?? false,
                )
                .length,
      );
      final open = stories.where(
        (s) => s.endings.any(
          (e) => !(progress.storyEndings[s.id]?.contains(e.id) ?? false),
        ),
      );
      if (open.isNotEmpty) {
        // A story the child already started comes first.
        final started = open.where(
          (s) => progress.storyBookmarks.containsKey(s.id),
        );
        final story = started.isEmpty ? open.first : started.first;
        options.add((
          total == 0 ? 1 : found / total,
          NextAdventure(
            kind: AdventureKind.story,
            text: started.isEmpty
                ? 'Find a new ending: ${story.title}'
                : 'Carry on reading: ${story.title}',
          ),
        ));
      }
    }

    if (topics != null) {
      var levels = 0, passed = 0;
      NextAdventure? firstOpen;
      for (final t in topics) {
        for (final (i, l) in t.levels.indexed) {
          levels++;
          final best = progress.quizBest[l.id] ?? 0;
          if (QuizRules.passes(best, l.questions.length)) {
            passed++;
          } else if (firstOpen == null &&
              QuizRules.isUnlocked(t, i, progress.quizBest)) {
            firstOpen = NextAdventure(
              kind: AdventureKind.quiz,
              text: 'Take on the ${t.title} quiz',
            );
          }
        }
      }
      if (firstOpen != null) {
        options.add((levels == 0 ? 1 : passed / levels, firstOpen));
      }
    }

    if (options.isEmpty) {
      return const NextAdventure(
        kind: AdventureKind.creative,
        text: 'Make something new on Creative Island',
      );
    }
    var best = options.first;
    for (final option in options.skip(1)) {
      if (option.$1 < best.$1) best = option;
    }
    return best.$2;
  }
}
