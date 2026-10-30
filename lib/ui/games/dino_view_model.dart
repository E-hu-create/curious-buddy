import 'dart:async';
import 'dart:math';

import '../../data/services/sound/sound_effects_service.dart';
import '../../domain/games/dino.dart';
import 'game_view_models.dart';

/// One expedition in Dino Discovery. Buddy reads the clues and the facts;
/// everything he says is also on the screen.
class DinoViewModel extends GamePlayViewModel {
  DinoViewModel({
    required this.place,
    required super.voice,
    required super.progressRepository,
    Random? random,
  }) : _random = random ?? Random() {
    _expedition = DinoExpedition(place: place, random: _random);
  }

  final DinoPlace place;
  final Random _random;

  DinoExpedition get expedition => _expedition;
  late DinoExpedition _expedition;

  /// The last wrong pick, to explain it on the screen.
  DinoCreature? get lastWrong => _lastWrong;
  DinoCreature? _lastWrong;

  @override
  String get gameId => place.id;

  @override
  String get gameTitle => place.name;

  @override
  String get introLine => '${place.intro} Tap a search spot to look for clues.';

  void look(DinoCreature creature) {
    if (isFinished || !_expedition.investigate(creature)) return;
    _lastWrong = null;
    notify();
    say('Here is a clue. ${_expedition.clue}', lead: SoundEffect.pop);
  }

  void pick(DinoCreature creature) {
    if (isFinished) return;
    final wasIdentifying = _expedition.stage == DinoStage.identify;
    switch (_expedition.pick(creature)) {
      case DinoPickResult.ignored:
        return;
      case DinoPickResult.wrong:
        _lastWrong = creature;
        notify();
        say(
          wasIdentifying
              ? "That's ${creature.name}. Here is another clue. "
                    '${_expedition.clue}'
              : "That's ${creature.name}. Try again!",
          lead: SoundEffect.gentle,
        );
      case DinoPickResult.right:
        _lastWrong = null;
        notify();
        say(
          wasIdentifying
              ? 'You found ${creature.name}! ${creature.fact}'
              : "That's right! ${_expedition.task.explanation}",
          lead: SoundEffect.correct,
        );
    }
  }

  Future<void> carryOn() async {
    if (isFinished) return;
    _expedition.carryOn();
    _lastWrong = null;
    if (_expedition.stage == DinoStage.done) {
      await finish(_expedition.stars);
      return;
    }
    notify();
    if (_expedition.stage == DinoStage.mission) say(_expedition.task.prompt);
  }

  @override
  void reset() {
    _expedition = DinoExpedition(place: place, random: _random);
    _lastWrong = null;
  }
}
