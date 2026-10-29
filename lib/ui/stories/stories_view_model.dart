import 'package:flutter/foundation.dart';

import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/story_repository.dart';
import '../../domain/models/learner_progress.dart';
import '../../domain/stories/story.dart';
import '../../domain/stories/story_rules.dart';

enum StoriesStatus { loading, ready, empty, error }

/// A story card's data: the story and how far the child has got.
class StorySummary {
  const StorySummary({
    required this.story,
    required this.foundEndingIds,
    required this.bookmark,
  });

  final Story story;
  final Set<String> foundEndingIds;

  /// Where the child stopped, if they can carry on. Only real routes
  /// through the current story are kept.
  final List<String>? bookmark;

  int get totalEndings => story.endings.length;
  bool get finished => foundEndingIds.isNotEmpty;
  bool get canContinue => bookmark != null;

  /// Endings found, in story order.
  List<StoryEnding> get foundEndings => [
    for (final ending in story.endings)
      if (foundEndingIds.contains(ending.id)) ending,
  ];
}

class StoriesViewModel extends ChangeNotifier {
  StoriesViewModel({
    required StoryRepository storyRepository,
    required ProgressRepository progressRepository,
  }) : _stories = storyRepository,
       _progress = progressRepository;

  final StoryRepository _stories;
  final ProgressRepository _progress;
  bool _disposed = false;

  StoriesStatus get status => _status;
  StoriesStatus _status = StoriesStatus.loading;

  List<StorySummary> get summaries => _summaries;
  List<StorySummary> _summaries = const [];

  int get endingsFound =>
      _summaries.fold(0, (sum, s) => sum + s.foundEndings.length);
  int get totalEndings => _summaries.fold(0, (sum, s) => sum + s.totalEndings);
  int get storiesFinished => _summaries.where((s) => s.finished).length;

  /// Loads stories and progress. Safe to call again (e.g. after reading).
  Future<void> load() async {
    List<Story> stories;
    try {
      stories = await _stories.loadStories();
    } on Exception {
      _status = StoriesStatus.error;
      _notify();
      return;
    }
    LearnerProgress progress;
    try {
      progress = await _progress.load();
    } on Exception {
      // Stories still work; endings and bookmarks just are not shown.
      progress = LearnerProgress.empty;
    }
    _summaries = [
      for (final story in stories)
        StorySummary(
          story: story,
          foundEndingIds: {
            for (final id
                in progress.storyEndings[story.id] ?? const <String>{})
              if (story.endings.any((e) => e.id == id)) id,
          },
          bookmark: _validBookmark(story, progress.storyBookmarks[story.id]),
        ),
    ];
    _status = stories.isEmpty ? StoriesStatus.empty : StoriesStatus.ready;
    _notify();
  }

  /// A bookmark saved by an older version of a story may no longer fit;
  /// those are ignored so the child simply starts again.
  static List<String>? _validBookmark(Story story, List<String>? path) {
    if (path == null || !StoryGraph(story).isValidPath(path)) return null;
    // A bookmark on an ending is finished, not resumable.
    if (story.sceneById(path.last)!.isEnding) return null;
    return path;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
