import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/voice/text_to_speech_service.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:curious_buddy/domain/voice/narrator.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

void main() {
  late FakeTextToSpeechService tts;
  late InMemoryKeyValueStore store;

  setUp(() {
    tts = FakeTextToSpeechService();
    store = InMemoryKeyValueStore();
  });

  BuddyVoice build([KeyValueStore? settings]) =>
      BuddyVoice(textToSpeech: tts, settings: settings ?? store);

  test('defaults: normal speed and reads automatically', () async {
    final voice = build();
    await voice.ready;

    expect(voice.speed, SpeechSpeed.normal);
    expect(voice.autoRead, isTrue);
    expect(tts.speed, SpeechSpeed.normal);
    voice.dispose();
  });

  test('speed is applied to the engine, saved and restored', () async {
    final voice = build();
    await voice.setSpeed(SpeechSpeed.slower);

    expect(tts.speed, SpeechSpeed.slower);
    expect(await store.read(BuddyVoice.speedKey), 'slower');
    voice.dispose();

    tts.speed = SpeechSpeed.normal;
    final again = build();
    await again.ready;
    expect(again.speed, SpeechSpeed.slower);
    expect(tts.speed, SpeechSpeed.slower, reason: 'applied on start-up');
    again.dispose();
  });

  test('an unknown saved speed falls back to normal', () async {
    await store.write(BuddyVoice.speedKey, 'warp');
    final voice = build();
    await voice.ready;

    expect(voice.speed, SpeechSpeed.normal);
    voice.dispose();
  });

  test('automatic reading off: only requested lines are spoken', () async {
    final voice = build();
    await voice.setAutoRead(false);

    expect(await voice.say('A new page.'), NarrationOutcome.skipped);
    expect(
      await voice.say('Hear again.', requested: true),
      NarrationOutcome.spoken,
    );
    expect(tts.spoken, ['Hear again.']);
    expect(await store.read(BuddyVoice.autoReadKey), 'false');
    voice.dispose();
  });

  test(
    'automatic reading off: a new page still silences the old one',
    () async {
      tts.holdSpeech = true;
      final voice = build();
      await voice.setAutoRead(false);
      final playing = voice.say('Read page.', requested: true);
      await pumpEventQueue();
      expect(voice.isSpeaking, isTrue);

      await voice.say('Next page.');

      expect(voice.isSpeaking, isFalse);
      expect(await playing, NarrationOutcome.interrupted);
      voice.dispose();
    },
  );

  test('automatic reading is restored after a restart', () async {
    await store.write(BuddyVoice.autoReadKey, 'false');
    final voice = build();
    await voice.ready;

    expect(voice.autoRead, isFalse);
    voice.dispose();
  });

  test('storage failures fall back to safe defaults', () async {
    final voice = build(FailingKeyValueStore());
    await voice.ready;

    expect(voice.isMuted, isFalse);
    expect(voice.speed, SpeechSpeed.normal);
    expect(voice.autoRead, isTrue);
    await voice.setSpeed(SpeechSpeed.faster);
    expect(voice.speed, SpeechSpeed.faster, reason: 'applies this session');
    voice.dispose();
  });
}
