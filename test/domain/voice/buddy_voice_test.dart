import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/domain/voice/narrator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

void main() {
  late FakeTextToSpeechService tts;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;

  BuddyVoice build({KeyValueStore? settings}) =>
      voice = BuddyVoice(textToSpeech: tts, settings: settings ?? store);

  setUp(() {
    tts = FakeTextToSpeechService();
    store = InMemoryKeyValueStore();
  });

  tearDown(() => voice.dispose());

  group('availability', () {
    test('starts as checking, then available', () async {
      build();
      expect(voice.status, VoiceStatus.checking);

      await voice.ready;

      expect(voice.status, VoiceStatus.available);
      expect(voice.canSpeak, isTrue);
    });

    test('unavailable engine falls back to text only', () async {
      tts.available = false;
      build();
      await voice.ready;

      expect(voice.status, VoiceStatus.unavailable);
      expect(await voice.say('Hi'), NarrationOutcome.textOnly);
      expect(tts.spoken, isEmpty);
    });

    test('engine failure while speaking falls back to text only', () async {
      tts.throwOnSpeak = Exception('engine crashed');
      build();

      expect(await voice.say('Hi'), NarrationOutcome.textOnly);
    });
  });

  group('welcome', () {
    test('is spoken only once per session', () async {
      build();

      expect(await voice.welcomeOnce('Hello'), NarrationOutcome.spoken);
      expect(await voice.welcomeOnce('Hello'), NarrationOutcome.skipped);
      expect(await voice.welcomeOnce('Hello'), NarrationOutcome.skipped);

      expect(tts.spoken, ['Hello']);
      expect(voice.hasWelcomed, isTrue);
    });

    test('is not spoken when muted, and not replayed by unmuting', () async {
      await store.write(BuddyVoice.mutedKey, 'true');
      build();

      expect(await voice.welcomeOnce('Hello'), NarrationOutcome.muted);
      await voice.setMuted(false);

      expect(tts.spoken, isEmpty);
    });

    test('stop before the engine is ready cancels the welcome', () async {
      build();
      final welcome = voice.welcomeOnce('Hello');
      await voice.stop();

      expect(await welcome, NarrationOutcome.interrupted);
      expect(tts.spoken, isEmpty);
    });
  });

  group('replay', () {
    test('say can be repeated', () async {
      build();

      await voice.say('Look!');
      await voice.say('Look!');

      expect(tts.spoken, ['Look!', 'Look!']);
    });

    test('a new line interrupts the one playing', () async {
      tts.holdSpeech = true;
      build();
      final first = voice.say('One');
      await pumpEventQueue();

      final second = voice.say('Two');
      await pumpEventQueue();

      expect(await first, NarrationOutcome.interrupted);
      expect(tts.spoken, ['One', 'Two']);
      tts.finishSpeaking();
      expect(await second, NarrationOutcome.spoken);
    });
  });

  group('stop', () {
    test('stops speech that is playing', () async {
      tts.holdSpeech = true;
      build();
      final line = voice.say('A long story');
      await pumpEventQueue();
      expect(tts.isSpeaking, isTrue);

      await voice.stop();

      expect(tts.isSpeaking, isFalse);
      expect(await line, NarrationOutcome.interrupted);
    });

    test('dispose stops speech', () async {
      tts.holdSpeech = true;
      final disposable = BuddyVoice(textToSpeech: tts, settings: store);
      build(); // for tearDown
      final line = disposable.say('Bye');
      await pumpEventQueue();

      disposable.dispose();
      await pumpEventQueue();

      expect(tts.isSpeaking, isFalse);
      expect(await line, NarrationOutcome.interrupted);
    });
  });

  group('mute', () {
    test('muting stops current speech and silences later lines', () async {
      tts.holdSpeech = true;
      build();
      final line = voice.say('Talking');
      await pumpEventQueue();

      await voice.setMuted(true);

      expect(tts.isSpeaking, isFalse);
      expect(await line, NarrationOutcome.interrupted);
      expect(await voice.say('More'), NarrationOutcome.muted);
      expect(tts.spoken, ['Talking']);
      expect(voice.canSpeak, isFalse);
    });

    test('unmuting does not start speaking by itself', () async {
      build();
      await voice.setMuted(true);
      await voice.setMuted(false);

      expect(tts.spoken, isEmpty);
      expect(await voice.say('Back'), NarrationOutcome.spoken);
    });

    test('setting is saved and restored', () async {
      build();
      await voice.setMuted(true);
      expect(await store.read(BuddyVoice.mutedKey), 'true');
      voice.dispose();

      build();
      await voice.ready;
      expect(voice.isMuted, isTrue);
    });

    test('notifies listeners only when the setting changes', () async {
      build();
      await voice.ready;
      var notifications = 0;
      voice.addListener(() => notifications++);

      await voice.setMuted(true);
      await voice.setMuted(true);
      await voice.setMuted(false);

      expect(notifications, 2);
    });

    test('still applies for the session when saving fails', () async {
      build(settings: ReadOnlyKeyValueStore());

      await voice.setMuted(true);

      expect(voice.isMuted, isTrue);
      expect(await voice.say('Hi'), NarrationOutcome.muted);
    });

    test('unreadable saved setting defaults to voice on', () async {
      build(settings: FailingKeyValueStore());
      await voice.ready;

      expect(voice.isMuted, isFalse);
    });
  });
}
