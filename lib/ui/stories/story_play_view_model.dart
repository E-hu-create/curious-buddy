import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/repositories/progress_repository.dart';
import '../../domain/models/learner_progress.dart';
import '../../domain/stories/story.dart';
import '../../domain/stories/story_rules.dart';
import '../../domain/voice/buddy_voice.dart';

enum StoryPhase { intro, scene }

enum StorySaveStatus { idle, saving, saved, failed }

/// Reading one story: intro, then scene by scene until an ending. Buddy
/// narrates through the shared [BuddyVoice] (so speech never overlaps), and
/// every word spoken is also on screen, so the story works with the voice
/// off. The microphone is never used here.
///
/// The path so far is saved after every choice, so the child can carry on
/// later. Reaching an ending records it and clears the bookmark.
class StoryPlayViewModel extends ChangeNotifier {
  StoryPlayViewModel({
    required this.story,
    required BuddyVoice voice,
    required ProgressRepository progressRepository,
    List<String>? resumePath,
    Set<String> foundEndingIds = const {},
  }) : _voice = voice,
       _progressRepository = progressRepository,
       _graph = StoryGraph(story),
       _foundBefore = {...foundEndingIds},
       _found = {...foundEndingIds} {
    _voice.addListener(_notify);
    if (resumePath != null && _graph.isValidPath(resumePath)) {
      _path.addAll(resumePath);
      _phase = StoryPhase.scene;
    }
    resumed = _path.isNotEmpty;
    _onResumedPage = resumed;
  }

  final Story story;
  final BuddyVoice _voice;
  final ProgressRepository _progressRepository;
  final StoryGraph _graph;
  bool _disposed = false;

  StoryPhase get phase => _phase;
  StoryPhase _phase = StoryPhase.intro;

  /// Whether this visit carried on from a bookmark.
  late final bool resumed;

  /// True only on the page the child carried on from, until they move on.
  bool get onResumedPage => _onResumedPage;
  bool _onResumedPage = false;

  /// Scene ids from the start to the current scene. Never repeats a scene.
  List<String> get path => List.unmodifiable(_path);
  final List<String> _path = [];

  StoryScene get scene => story.sceneById(_path.last)!;
  int get sceneNumber => _path.length;
  bool get atEnding => _phase == StoryPhase.scene && scene.isEnding;

  /// What the last choice led to, shown above the scene. Null on the first
  /// scene and after resuming.
  String? get consequence => _consequence;
  String? _consequence;

  /// Endings found so far, including this visit.
  Set<String> get foundEndingIds => Set.unmodifiable(_found);
  final Set<String> _found;
  final Set<String> _foundBefore;
  int get totalEndings => story.endings.length;

  /// True when the current ending had not been found before this visit.
  bool get isNewEnding => atEnding && !_foundBefore.contains(scene.ending!.id);

  StorySaveStatus get saveStatus => _saveStatus;
  StorySaveStatus _saveStatus = StorySaveStatus.idle;

  // ---------------------------------------------------------------- voice

  bool get canSpeak => _voice.canSpeak;
  bool get isSpeaking => _voice.isSpeaking;
  String? get lastSpoken => _lastSpoken;
  String? _lastSpoken;

  // -------------------------------------------------------------- actions

  /// Called when the page opens: the intro, or the scene when resuming.
  void narrateOpening() =>
      _phase == StoryPhase.intro ? _say(story.intro) : _say(_sceneNarration());

  /// Begin at the first scene.
  void begin() {
    _goTo([story.startSceneId], consequence: null);
  }

  /// Follow one of the current scene's choices. Ignored if the choice is
  /// not on this scene or would revisit a scene (loop protection).
  void choose(String choiceId) {
    if (_phase != StoryPhase.scene || scene.isEnding) return;
    StoryChoice? choice;
    for (final c in scene.choices) {
      if (c.id == choiceId) choice = c;
    }
    if (choice == null || _path.contains(choice.nextSceneId)) return;
    if (story.sceneById(choice.nextSceneId) == null) return;
    _goTo([..._path, choice.nextSceneId], consequence: choice.consequence);
  }

  /// Start the story again from the first scene, forgetting the bookmark.
  /// Endings already found stay found.
  void restart() {
    _foundBefore.addAll(_found);
    _goTo([story.startSceneId], consequence: null);
  }

  /// Read the current scene aloud again.
  void readScene() => _say(_sceneNarration());

  /// Read the choices aloud, numbered as on screen.
  void readChoices() {
    if (_phase != StoryPhase.scene || scene.isEnding) return;
    _say(choicesNarration(scene));
  }

  void hearAgain() {
    final text = _lastSpoken;
    if (text != null) _sayNow(text);
  }

  Future<void> stopSpeaking() => _voice.stop();

  /// Completes when all saving started so far has finished.
  @visibleForTesting
  Future<void> get saved => _saving;

  @visibleForTesting
  static String choicesNarration(StoryScene scene) => [
    'What should we do?',
    for (final (i, c) in scene.choices.indexed) 'Choice ${i + 1}: ${c.text}.',
  ].join(' ');

  // ------------------------------------------------------------ internals

  void _goTo(List<String> path, {required String? consequence}) {
    _path
      ..clear()
      ..addAll(path);
    _phase = StoryPhase.scene;
    _onResumedPage = false;
    _consequence = consequence;
    final scene = this.scene;
    if (scene.ending case final ending?) _found.add(ending.id);
    _notify();
    _say(_sceneNarration());
    _save(scene);
  }

  String _sceneNarration() {
    final scene = this.scene;
    return [
      ?_consequence,
      scene.text,
      if (scene.ending case final ending?)
        'The end. You found the ending called ${ending.title}. '
            'You discovered: ${ending.discovery}',
    ].join(' ');
  }

  // Saves run one after another so a quick tap cannot overwrite a newer
  // save with an older one.
  Future<void> _saving = Future.value();

  void _save(StoryScene scene) {
    final path = List.of(_path);
    _saveStatus = StorySaveStatus.saving;
    _saving = _saving.then((_) async {
      try {
        final progress = await _progressRepository.load();
        await _progressRepository.save(_updated(progress, scene, path));
        _saveStatus = StorySaveStatus.saved;
      } on Exception {
        // The story carries on; it just will not be remembered this time.
        _saveStatus = StorySaveStatus.failed;
      }
      _notify();
    });
  }

  LearnerProgress _updated(
    LearnerProgress progress,
    StoryScene scene,
    List<String> path,
  ) => switch (scene.ending) {
    final ending? => progress.withStoryEnding(story.id, ending.id),
    null => progress.withStoryBookmark(story.id, path),
  };

  void _say(String text) {
    _lastSpoken = text;
    _sayNow(text);
  }

  void _sayNow(String text) {
    if (_disposed) return;
    unawaited(_voice.say(text));
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _voice.removeListener(_notify);
    // Leaving a story always silences Buddy.
    _voice.stop().ignore();
    super.dispose();
  }
}
