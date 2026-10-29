import 'story.dart';

/// Checks that a story is playable and genuinely branching.
abstract final class StoryValidator {
  static const maxWordsPerScene = 110;
  static const minEndings = 2;

  /// Empty when the story is valid.
  static List<String> problems(Story story) {
    final issues = <String>[];
    void check(bool ok, String message) {
      if (!ok) issues.add('${story.id}: $message');
    }

    check(_validId(story.id), 'invalid id');
    check(story.title.trim().isNotEmpty, 'missing title');
    check(story.intro.trim().isNotEmpty, 'missing intro');
    check(story.scenes.isNotEmpty, 'no scenes');
    if (story.scenes.isEmpty) return issues;

    final ids = [for (final s in story.scenes) s.id];
    check(ids.toSet().length == ids.length, 'scene ids must be unique');
    check(
      story.sceneById(story.startSceneId) != null,
      'start scene ${story.startSceneId} does not exist',
    );

    final endingIds = [for (final e in story.endings) e.id];
    check(
      endingIds.toSet().length == endingIds.length,
      'ending ids must be unique',
    );
    check(endingIds.length >= minEndings, 'needs at least $minEndings endings');

    for (final scene in story.scenes) {
      final where = 'scene ${scene.id}';
      check(_validId(scene.id), '$where: invalid id');
      check(scene.title.trim().isNotEmpty, '$where: missing title');
      check(scene.text.trim().isNotEmpty, '$where: missing text');
      check(
        _words(scene.text) <= maxWordsPerScene,
        '$where: text too long to read aloud comfortably',
      );
      if (scene.isEnding) {
        check(scene.choices.isEmpty, '$where: an ending cannot have choices');
        final ending = scene.ending!;
        check(_validId(ending.id), '$where: invalid ending id');
        check(ending.title.trim().isNotEmpty, '$where: ending needs a title');
        check(
          ending.discovery.trim().isNotEmpty,
          '$where: ending needs a discovery',
        );
      } else {
        check(scene.choices.isNotEmpty, '$where: needs a choice or an ending');
        final choiceIds = [for (final c in scene.choices) c.id];
        check(
          choiceIds.toSet().length == choiceIds.length,
          '$where: choice ids must be unique',
        );
        final targets = [for (final c in scene.choices) c.nextSceneId];
        check(
          targets.toSet().length == targets.length,
          '$where: two choices lead to the same scene (fake branching)',
        );
        for (final choice in scene.choices) {
          check(choice.text.trim().isNotEmpty, '$where: empty choice text');
          check(
            story.sceneById(choice.nextSceneId) != null,
            '$where: choice ${choice.id} points at missing scene '
            '${choice.nextSceneId}',
          );
          check(
            choice.nextSceneId != scene.id,
            '$where: choice ${choice.id} loops to itself',
          );
        }
      }
    }
    if (issues.isNotEmpty) return issues;

    final graph = StoryGraph(story);
    final unreachable = ids.toSet().difference(graph.reachable);
    check(unreachable.isEmpty, 'unreachable scenes: ${unreachable.join(', ')}');
    check(!graph.hasCycle, 'scenes form a loop');
    final stuck = graph.reachable.where((id) => !graph.canFinish(id));
    check(stuck.isEmpty, 'cannot reach an ending from: ${stuck.join(', ')}');
    check(
      graph.reachableEndingIds.length == endingIds.length,
      'some endings can never be reached',
    );
    return issues;
  }

  static bool _validId(String id) => RegExp(r'^[a-z0-9_\-]+$').hasMatch(id);

  static int _words(String text) =>
      text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}

/// Graph questions about a story (assumes every choice target exists).
class StoryGraph {
  StoryGraph(this.story);

  final Story story;

  late final Map<String, List<String>> _next = {
    for (final scene in story.scenes)
      scene.id: [for (final c in scene.choices) c.nextSceneId],
  };

  /// Scene ids reachable from the start.
  late final Set<String> reachable = () {
    final seen = <String>{};
    final queue = [story.startSceneId];
    while (queue.isNotEmpty) {
      final id = queue.removeLast();
      if (!seen.add(id)) continue;
      queue.addAll(_next[id] ?? const []);
    }
    return seen;
  }();

  late final bool hasCycle = () {
    const visiting = 1, done = 2;
    final state = <String, int>{};
    bool visit(String id) {
      if (state[id] == visiting) return true;
      if (state[id] == done) return false;
      state[id] = visiting;
      for (final next in _next[id] ?? const <String>[]) {
        if (visit(next)) return true;
      }
      state[id] = done;
      return false;
    }

    return _next.keys.any(visit);
  }();

  late final Set<String> reachableEndingIds = {
    for (final id in reachable) ?story.sceneById(id)?.ending?.id,
  };

  final Map<String, bool> _finishes = {};

  /// Whether every path from [sceneId] eventually ends (no dead ends and
  /// no loops). Safe on broken content: a scene seen again while still
  /// being checked counts as not finishing.
  bool canFinish(String sceneId) {
    if (_finishes[sceneId] case final known?) return known;
    _finishes[sceneId] = false;
    final scene = story.sceneById(sceneId);
    final result =
        scene != null &&
        (scene.isEnding ||
            scene.choices.every((c) => canFinish(c.nextSceneId)));
    return _finishes[sceneId] = result;
  }

  /// Number of distinct paths from the start to any ending (0 if the story
  /// loops, since it would be endless).
  int get pathCount => hasCycle ? 0 : _paths(story.startSceneId);

  int _paths(String id) {
    final scene = story.sceneById(id);
    if (scene == null) return 0;
    if (scene.isEnding) return 1;
    return scene.choices.fold(0, (sum, c) => sum + _paths(c.nextSceneId));
  }

  /// Whether [path] (scene ids from the start) is a real route through the
  /// story with no repeats. Used to check saved bookmarks before resuming.
  bool isValidPath(List<String> path) {
    if (path.isEmpty || path.first != story.startSceneId) return false;
    if (path.toSet().length != path.length) return false;
    for (var i = 0; i + 1 < path.length; i++) {
      final scene = story.sceneById(path[i]);
      if (scene == null) return false;
      if (!scene.choices.any((c) => c.nextSceneId == path[i + 1])) {
        return false;
      }
    }
    return story.sceneById(path.last) != null;
  }
}
