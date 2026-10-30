import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/repositories/creations_repository.dart';
import '../../data/services/sound/sound_effects_service.dart';
import '../../domain/creative/creation.dart';
import '../../domain/creative/creation_shelf.dart';
import '../../domain/voice/buddy_voice.dart';

enum CreativeStatus { loading, ready, error }

enum CreationSaveStatus { notSaved, saving, saved, full, failed }

/// Creative Island's shelf of creations.
class CreativeHubViewModel extends ChangeNotifier {
  CreativeHubViewModel({required CreationsRepository creationsRepository})
    : _repository = creationsRepository;

  final CreationsRepository _repository;
  bool _disposed = false;

  CreativeStatus get status => _status;
  CreativeStatus _status = CreativeStatus.loading;

  CreationShelf get shelf => _shelf;
  CreationShelf _shelf = CreationShelf.empty;

  /// Newest first, as children expect to see their latest work first.
  List<Creation> get newestFirst => _shelf.items.reversed.toList();

  bool get isFull => _shelf.isFull;

  Future<void> load() async {
    try {
      _shelf = await _repository.load();
      _status = CreativeStatus.ready;
    } on Exception {
      _status = CreativeStatus.error;
    }
    _notify();
  }

  /// Removes one creation (the child confirmed). Returns whether it worked.
  Future<bool> remove(String id) async {
    try {
      await _repository.remove(id);
    } on Exception {
      return false;
    }
    await load();
    return true;
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

/// Shared by the two activities: Buddy's voice and saving to the shelf.
abstract class CreativeActivityViewModel extends ChangeNotifier {
  CreativeActivityViewModel({
    required BuddyVoice voice,
    required CreationsRepository creationsRepository,
  }) : _voice = voice,
       _repository = creationsRepository {
    _voice.addListener(_notify);
  }

  final BuddyVoice _voice;
  final CreationsRepository _repository;
  bool _disposed = false;

  bool get canSpeak => _voice.canSpeak;
  bool get isSpeaking => _voice.isSpeaking;
  String? get lastSpoken => _lastSpoken;
  String? _lastSpoken;

  CreationSaveStatus get saveStatus => _saveStatus;
  CreationSaveStatus _saveStatus = CreationSaveStatus.notSaved;

  static const savedLine = 'Saved to My Creations! It looks fantastic.';
  static const fullLine =
      'Your shelf is full. Remove a creation on Creative Island to make '
      'room for this one.';

  /// Buddy's opening line for the activity.
  String get introLine;

  bool get canSave;

  /// Builds the creation to save, given its new id.
  Creation build(String id);

  void narrateIntro() => say(introLine);

  Future<void> save() async {
    if (!canSave || _saveStatus == CreationSaveStatus.saving) return;
    _saveStatus = CreationSaveStatus.saving;
    _notify();
    try {
      await _repository.add(build);
      _saveStatus = CreationSaveStatus.saved;
      say(savedLine, lead: SoundEffect.cheer);
    } on CreationsFullException {
      _saveStatus = CreationSaveStatus.full;
      say(fullLine);
    } on Exception {
      _saveStatus = CreationSaveStatus.failed;
    }
    _notify();
  }

  /// Start a new one after saving.
  void startAgain() {
    _saveStatus = CreationSaveStatus.notSaved;
    reset();
    _notify();
  }

  @protected
  void reset();

  void hearAgain() {
    final text = _lastSpoken;
    if (text != null) _sayNow(text, requested: true);
  }

  Future<void> stopSpeaking() => _voice.stop();

  @protected
  void say(String text, {bool requested = false, SoundEffect? lead}) {
    final first = _lastSpoken == null;
    _lastSpoken = text;
    // Enables "Hear again" even when nothing is read aloud automatically.
    if (first) _notify();
    _sayNow(text, requested: requested, lead: lead);
  }

  void _sayNow(String text, {bool requested = false, SoundEffect? lead}) {
    if (_disposed) return;
    unawaited(_voice.say(text, requested: requested, lead: lead));
  }

  /// A small sound for a small choice.
  @protected
  void pop() => unawaited(_voice.effect(SoundEffect.pop));

  @protected
  void changed() {
    // Editing after "full" or "failed" lets the child try saving again.
    if (_saveStatus == CreationSaveStatus.full ||
        _saveStatus == CreationSaveStatus.failed) {
      _saveStatus = CreationSaveStatus.notSaved;
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _voice.removeListener(_notify);
    // Leaving an activity always silences Buddy.
    _voice.stop().ignore();
    super.dispose();
  }
}

/// Drawing Studio: finger strokes with colours, sizes, eraser and undo.
class DrawingViewModel extends CreativeActivityViewModel {
  DrawingViewModel({required super.voice, required super.creationsRepository});

  @override
  String get introLine =>
      'Pick a colour and draw with your finger. You can undo, use the '
      'eraser, and save your picture when you are done.';

  static const pointsFullLine =
      'Wow, this picture is full of lines! Save it, or start over.';

  List<Stroke> get strokes => List.unmodifiable(_strokes);
  final List<Stroke> _strokes = [];

  /// The stroke being drawn right now.
  Stroke? get active => _active == null
      ? null
      : Stroke(
          colorIndex: colorIndex,
          sizeIndex: sizeIndex,
          eraser: eraser,
          points: List.unmodifiable(_active!),
        );
  List<DrawPoint>? _active;

  int get colorIndex => _colorIndex;
  int _colorIndex = 1;
  int get sizeIndex => _sizeIndex;
  int _sizeIndex = 1;
  bool get eraser => _eraser;
  bool _eraser = false;

  int get pointCount =>
      _strokes.fold(0, (sum, s) => sum + s.points.length) +
      (_active?.length ?? 0);

  /// The picture cannot take more lines.
  bool get pointsFull =>
      pointCount >= CreativeLimits.maxPointsPerDrawing ||
      _strokes.length >= CreativeLimits.maxStrokes;

  bool get hasDrawing => _strokes.any((s) => !s.eraser);

  @override
  bool get canSave => hasDrawing && saveStatus != CreationSaveStatus.saved;

  void pickColor(int index) {
    if (index < 0 || index >= CreativeLimits.colorCount) return;
    _colorIndex = index;
    _eraser = false;
    changed();
  }

  void pickSize(int index) {
    if (index < 0 || index >= CreativeLimits.sizeCount) return;
    _sizeIndex = index;
    changed();
  }

  void toggleEraser() {
    _eraser = !_eraser;
    changed();
  }

  void startStroke(DrawPoint point) {
    if (saveStatus == CreationSaveStatus.saved) return;
    if (pointsFull) {
      say(pointsFullLine);
      return;
    }
    _active = [_clamp(point)];
    changed();
  }

  void extendStroke(DrawPoint point) {
    final active = _active;
    if (active == null) return;
    if (pointCount >= CreativeLimits.maxPointsPerDrawing) {
      endStroke();
      say(pointsFullLine);
      return;
    }
    final p = _clamp(point);
    final last = active.last;
    final dx = p.x - last.x, dy = p.y - last.y;
    // Skip tiny moves: keeps drawings small without changing how they look.
    if (dx * dx + dy * dy <
        CreativeLimits.minPointGap * CreativeLimits.minPointGap) {
      return;
    }
    active.add(p);
    changed();
  }

  void endStroke() {
    final active = _active;
    if (active == null) return;
    _strokes.add(
      Stroke(
        colorIndex: _colorIndex,
        sizeIndex: _sizeIndex,
        eraser: _eraser,
        points: List.unmodifiable(active),
      ),
    );
    _active = null;
    changed();
  }

  void undo() {
    if (_strokes.isEmpty) return;
    _strokes.removeLast();
    changed();
  }

  void clear() {
    _strokes.clear();
    _active = null;
    changed();
  }

  @override
  Drawing build(String id) => Drawing(id: id, strokes: List.of(_strokes));

  @override
  void reset() {
    _strokes.clear();
    _active = null;
    _eraser = false;
  }

  static DrawPoint _clamp(DrawPoint p) =>
      DrawPoint(p.x.clamp(0, DrawPoint.scale), p.y.clamp(0, DrawPoint.scale));
}

/// Creature Maker: choose parts, or let Buddy surprise you.
class CreatureViewModel extends CreativeActivityViewModel {
  CreatureViewModel({
    required super.voice,
    required super.creationsRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _creature = _randomCreature();
  }

  final Random _random;

  @override
  String get introLine =>
      'Build your own creature! Pick its shape, colour, eyes and more. Tap '
      'Surprise me for a mix, and New name for another name.';

  Creature get creature => _creature;
  late Creature _creature;

  @override
  bool get canSave => saveStatus != CreationSaveStatus.saved;

  void setBody(CreatureBody v) => _update(_creature.copyWith(body: v));
  void setColor(int i) {
    if (i < 0 || i >= CreativeLimits.colorCount) return;
    _update(_creature.copyWith(colorIndex: i));
  }

  void setEyes(CreatureEyes v) =>
      _update(_creature.copyWith(eyes: v), react: true);
  void setMouth(CreatureMouth v) => _update(_creature.copyWith(mouth: v));
  void setExtra(CreatureExtra v) =>
      _update(_creature.copyWith(extra: v), react: true);
  void setPattern(CreaturePattern v) =>
      _update(_creature.copyWith(pattern: v), react: true);

  void surprise() {
    _update(_randomCreature(name: _creature.name), react: true);
  }

  void newName() {
    String name;
    do {
      name = creatureNames[_random.nextInt(creatureNames.length)];
    } while (name == _creature.name && creatureNames.length > 1);
    _update(_creature.copyWith(name: name));
    say('Hello, $name!');
  }

  /// Buddy shares a fact about the creature on request.
  void askBuddy() => say(creatureFact(_creature), requested: true);

  @override
  Creature build(String id) => _creature.copyWith(id: id);

  @override
  void reset() => _creature = _randomCreature();

  void _update(Creature next, {bool react = false}) {
    if (saveStatus == CreationSaveStatus.saved) return;
    _creature = next;
    changed();
    if (react) {
      say(creatureFact(_creature), lead: SoundEffect.pop);
    } else {
      pop();
    }
  }

  Creature _randomCreature({String? name}) {
    T pick<T>(List<T> values) => values[_random.nextInt(values.length)];
    return Creature(
      id: 'draft',
      name: name ?? pick(creatureNames),
      body: pick(CreatureBody.values),
      colorIndex: 1 + _random.nextInt(CreativeLimits.colorCount - 1),
      eyes: pick(CreatureEyes.values),
      mouth: pick(CreatureMouth.values),
      extra: pick(CreatureExtra.values),
      pattern: pick(CreaturePattern.values),
    );
  }
}
