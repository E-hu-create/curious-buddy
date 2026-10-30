import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:curious_buddy/data/repositories/creations_repository.dart';
import 'package:curious_buddy/data/repositories/progress_repository.dart';
import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/sound/sound_effects_service.dart';
import 'package:curious_buddy/domain/creative/creation.dart';
import 'package:curious_buddy/domain/quiz/quiz_content.dart';
import 'package:curious_buddy/domain/settings/display_settings.dart';
import 'package:curious_buddy/domain/stories/story_content.dart';
import 'package:curious_buddy/domain/voice/buddy_listener.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/domain/voice/narrator.dart';
import 'package:curious_buddy/ui/creative/creative_view_models.dart';
import 'package:curious_buddy/ui/parent_zone/parent_zone_view_model.dart';
import 'package:curious_buddy/ui/quiz/quiz_play_view_model.dart';
import 'package:curious_buddy/ui/stories/story_play_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

/// A sound that keeps "playing" until told to finish.
class _HeldSounds implements SoundEffectsService {
  Completer<void>? playing;
  final List<SoundEffect> played = [];

  @override
  Future<void> play(SoundEffect effect) {
    played.add(effect);
    return (playing = Completer<void>()).future;
  }

  void finish() => playing?.complete();
}

void main() {
  late FakeTextToSpeechService tts;
  late FakeSoundEffectsService sounds;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;

  setUp(() {
    tts = FakeTextToSpeechService();
    sounds = FakeSoundEffectsService(tts: tts);
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(textToSpeech: tts, settings: store, sounds: sounds);
  });

  tearDown(() => voice.dispose());

  group('BuddyVoice', () {
    test('a lead sound plays first; Buddy speaks when it ends', () async {
      final held = _HeldSounds();
      final v = BuddyVoice(textToSpeech: tts, settings: store, sounds: held);

      final saying = v.say('Well done!', lead: SoundEffect.correct);
      await pumpEventQueue();
      expect(held.played, [SoundEffect.correct]);
      expect(tts.spoken, isEmpty, reason: 'still waiting for the sound');

      held.finish();
      await saying;
      expect(tts.spoken, ['Well done!']);
      v.dispose();
    });

    test('old speech stops before a sound, so they never overlap', () async {
      tts.holdSpeech = true;
      final first = voice.say('A long sentence.');
      await pumpEventQueue();
      expect(tts.isSpeaking, isTrue);

      unawaited(voice.say('Right!', lead: SoundEffect.correct));
      await pumpEventQueue();
      await first;

      expect(sounds.played, [SoundEffect.correct]);
      expect(sounds.overSpeech, 0);
    });

    test('stopping during a sound cancels the line', () async {
      final held = _HeldSounds();
      final v = BuddyVoice(textToSpeech: tts, settings: store, sounds: held);
      final saying = v.say('Never spoken.', lead: SoundEffect.cheer);
      await pumpEventQueue();

      await v.stop();
      held.finish();

      expect(await saying, NarrationOutcome.interrupted);
      expect(tts.spoken, isEmpty);
      v.dispose();
    });

    test('a newer line replaces one waiting for its sound', () async {
      final held = _HeldSounds();
      final v = BuddyVoice(textToSpeech: tts, settings: store, sounds: held);
      final waiting = v.say('Old.', lead: SoundEffect.cheer);
      await pumpEventQueue();

      unawaited(v.say('New.'));
      await pumpEventQueue();
      held.finish();

      expect(await waiting, NarrationOutcome.interrupted);
      expect(tts.spoken, ['New.']);
      v.dispose();
    });

    test('sounds still play with the voice off', () async {
      await voice.setMuted(true);
      await voice.say('Quiet.', lead: SoundEffect.correct);

      expect(sounds.played, [SoundEffect.correct]);
      expect(tts.spoken, isEmpty);
    });

    test('with sounds off, Buddy still speaks', () async {
      await voice.setSoundsOn(false);
      await voice.say('Hello.', lead: SoundEffect.cheer);
      await voice.effect(SoundEffect.pop);

      expect(sounds.played, isEmpty);
      expect(tts.spoken, ['Hello.']);
      expect(await store.read(BuddyVoice.soundsKey), 'false');
    });

    test('the switch is remembered after a restart', () async {
      await voice.setSoundsOn(false);

      final again = BuddyVoice(textToSpeech: tts, settings: store);
      await again.ready;
      expect(again.soundsOn, isFalse);
      again.dispose();
    });

    test('a small effect is skipped while Buddy talks', () async {
      tts.holdSpeech = true;
      unawaited(voice.say('Talking.'));
      await pumpEventQueue();

      await voice.effect(SoundEffect.pop);

      expect(sounds.played, isEmpty);
      tts.finishSpeaking();
    });

    test('no sound service: nothing breaks', () async {
      final v = BuddyVoice(textToSpeech: tts, settings: store);
      await v.say('Fine.', lead: SoundEffect.cheer);
      await v.effect(SoundEffect.pop);

      expect(tts.spoken, ['Fine.']);
      v.dispose();
    });
  });

  group('moments', () {
    final space = starterQuizTopics.first;

    QuizPlayViewModel quiz() => QuizPlayViewModel(
      topic: space,
      level: space.levels.first,
      voice: voice,
      progressRepository: LocalProgressRepository(store),
    );

    Future<void> playRound(QuizPlayViewModel vm, int right) async {
      for (var i = 0; i < vm.total; i++) {
        final q = vm.question;
        vm.pick(
          i < right
              ? q.answerId
              : q.options.firstWhere((o) => o.id != q.answerId).id,
        );
        await pumpEventQueue();
        await vm.next();
      }
      await pumpEventQueue();
    }

    test('quiz: chime when right, soft notes when wrong', () async {
      final vm = quiz();
      final q = vm.question;

      vm.pick(q.answerId);
      await pumpEventQueue();
      expect(sounds.played, [SoundEffect.correct]);

      await vm.next();
      final next = vm.question;
      vm.pick(next.options.firstWhere((o) => o.id != next.answerId).id);
      await pumpEventQueue();
      expect(sounds.played.last, SoundEffect.gentle);
      vm.dispose();
    });

    test('quiz: a pass gets the fanfare, a low score does not', () async {
      final passed = quiz();
      await playRound(passed, 3);
      expect(sounds.played.last, SoundEffect.cheer);
      passed.dispose();

      sounds.played.clear();
      final low = quiz();
      await playRound(low, 1);
      expect(sounds.played, isNot(contains(SoundEffect.cheer)));
      low.dispose();
    });

    test('story: only a new ending gets the fanfare', () async {
      final forest = starterStories.first;
      StoryPlayViewModel story(Set<String> found) => StoryPlayViewModel(
        story: forest,
        voice: voice,
        progressRepository: LocalProgressRepository(store),
        foundEndingIds: found,
      );

      final fresh = story(const {})
        ..begin()
        ..choose('follow_stream')
        ..choose('make_mist');
      await pumpEventQueue();
      expect(sounds.played, [SoundEffect.cheer]);
      fresh.dispose();

      sounds.played.clear();
      final repeat = story(const {'mist'})
        ..begin()
        ..choose('follow_stream')
        ..choose('make_mist');
      await pumpEventQueue();
      expect(sounds.played, isEmpty);
      repeat.dispose();
    });

    test('creative: a pop for choices, the fanfare for saving', () async {
      final vm = CreatureViewModel(
        voice: voice,
        creationsRepository: LocalCreationsRepository(store),
      )..setBody(CreatureBody.tall);
      await pumpEventQueue();
      expect(sounds.played, [SoundEffect.pop]);

      await vm.save();
      await pumpEventQueue();
      expect(sounds.played.last, SoundEffect.cheer);
      vm.dispose();
    });

    test('settings: restoring defaults turns sound effects back on', () async {
      await voice.setSoundsOn(false);
      final display = DisplaySettings(settings: store);
      final listener = BuddyListener(
        recognizer: FakeSpeechRecognitionService(),
        settings: store,
        voice: voice,
      );
      final vm = ParentZoneViewModel(
        progressRepository: LocalProgressRepository(store),
        creationsRepository: LocalCreationsRepository(store),
        voice: voice,
        listener: listener,
        display: display,
      );

      await vm.restoreDefaultSettings();

      expect(voice.soundsOn, isTrue);
      vm.dispose();
      listener.dispose();
      display.dispose();
    });
  });

  group('sound files', () {
    int milliseconds(Uint8List bytes) {
      final view = ByteData.sublistView(bytes);
      final rate = view.getUint32(24, Endian.little);
      final dataBytes = view.getUint32(40, Endian.little);
      return (dataBytes / 2 / rate * 1000).round();
    }

    for (final effect in SoundEffect.values) {
      test('${effect.name} exists and matches its length in the code', () {
        final file = File(
          'android/app/src/main/res/raw/sfx_${effect.name}.wav',
        );
        expect(file.existsSync(), isTrue);
        expect(
          milliseconds(file.readAsBytesSync()),
          closeTo(effect.length.inMilliseconds, 2),
        );
      });
    }

    test('the native player knows every effect', () {
      final kotlin = File(
        'android/app/src/main/kotlin/io/github/e_hu_create/curiousbuddy/MainActivity.kt',
      ).readAsStringSync();
      for (final effect in SoundEffect.values) {
        expect(
          kotlin,
          contains('sounds["${effect.name}"] = pool.load'),
          reason: effect.name,
        );
      }
    });
  });
}
