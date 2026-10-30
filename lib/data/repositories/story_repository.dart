import 'package:flutter/foundation.dart';

import '../../domain/stories/more_stories.dart';
import '../../domain/stories/story.dart';
import '../../domain/stories/story_rules.dart';

/// Where Living Stories come from. Today: the stories
/// bundled in the app (offline). Kept behind an interface so more can be
/// added later without changing screens.
abstract interface class StoryRepository {
  /// Only valid, playable stories. Invalid ones are left out (and logged)
  /// rather than shown broken.
  Future<List<Story>> loadStories();
}

class BundledStoryRepository implements StoryRepository {
  BundledStoryRepository({this.stories = allStories});

  final List<Story> stories;

  @override
  Future<List<Story>> loadStories() async {
    final ids = <String>{};
    return [
      for (final story in stories)
        if (_isPlayable(story, ids)) story,
    ];
  }

  static bool _isPlayable(Story story, Set<String> seenIds) {
    final problems = StoryValidator.problems(story);
    if (!seenIds.add(story.id)) problems.add('duplicate id ${story.id}');
    if (problems.isEmpty) return true;
    debugPrint('Stories: skipping invalid story: ${problems.join('; ')}');
    return false;
  }
}
