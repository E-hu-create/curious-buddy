import 'dart:async';

import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/voice/speech_recognition_service.dart';
import 'package:curious_buddy/domain/voice/buddy_listener.dart';
import 'package:curious_buddy/domain/voice/buddy_voice.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../testing/fakes.dart';

void main() {
  late FakeTextToSpeechService tts;
  late FakeSpeechRecognitionService speech;
  late InMemoryKeyValueStore store;
  late BuddyVoice voice;
  late BuddyListener listener;

  BuddyListener build({KeyValueStore? settings}) => listener = BuddyListener(
    recognizer: speech,
    settings: settings ?? store,
    voice: voice,
  );

  setUp(() {
    tts = FakeTextToSpeechService();
    speech = FakeSpeechRecognitionService()
      ..permission = MicrophonePermission.granted;
    store = InMemoryKeyValueStore();
    voice = BuddyVoice(textToSpeech: tts, settings: store);
  });

  tearDown(() {
    listener.dispose();
    voice.dispose();
  });

  test('creating it touches nothing', () async {
    build();
    await listener.ready;

    expect(speech.totalCalls, 0);
    expect(listener.isListening, isFalse);
    expect(listener.allowOnline, isFalse);
  });

  test('listen returns what was heard', () async {
    build();

    final result = await listener.listen();

    expect(result, isA<ListenHeard>());
    expect(speech.listenCalls, 1);
  });

  test('tracks listening and live words', () async {
    speech.holdListening = true;
    build();
    final session = listener.listen();
    await pumpEventQueue();
    expect(listener.isListening, isTrue);

    speech.hear('hello');
    expect(listener.words, 'hello');

    speech.finish();
    await session;
    expect(listener.isListening, isFalse);
  });

  test('stops Buddy talking before listening', () async {
    tts.holdSpeech = true;
    build();
    unawaited(voice.say('Long story'));
    await pumpEventQueue();
    expect(tts.isSpeaking, isTrue);

    unawaited(listener.listen());
    await pumpEventQueue();

    expect(tts.isSpeaking, isFalse);
  });

  test('a second listen while listening is ignored', () async {
    speech.holdListening = true;
    build();
    unawaited(listener.listen());
    await pumpEventQueue();

    final second = await listener.listen();

    expect(second, isA<ListenFailed>());
    expect(speech.listenCalls, 1);
  });

  test('stop keeps words; cancel discards', () async {
    speech.holdListening = true;
    build();

    var session = listener.listen();
    await pumpEventQueue();
    speech.hear('keep me');
    await listener.stop();
    expect(await session, isA<ListenHeard>());

    session = listener.listen();
    await pumpEventQueue();
    speech.hear('drop me');
    await listener.cancel();
    expect(await session, isA<ListenCancelled>());
  });

  test('stop and cancel when idle do not touch the recogniser', () async {
    build();

    await listener.stop();
    await listener.cancel();

    expect(speech.totalCalls, 0);
  });

  test('dispose cancels an open session', () async {
    speech.holdListening = true;
    final disposable = BuddyListener(
      recognizer: speech,
      settings: store,
      voice: voice,
    );
    build(); // for tearDown
    final session = disposable.listen();
    await pumpEventQueue();

    disposable.dispose();

    expect(await session, isA<ListenCancelled>());
  });

  group('allow online (grown-up setting)', () {
    test('defaults to off and passes it to the recogniser', () async {
      build();
      await listener.listen();

      expect(speech.lastAllowOnline, isFalse);
    });

    test('can be turned on, is saved, and is passed on', () async {
      build();
      await listener.setAllowOnline(true);
      expect(await store.read(BuddyListener.allowOnlineKey), 'true');

      await listener.listen();
      expect(speech.lastAllowOnline, isTrue);
    });

    test('is restored from settings', () async {
      await store.write(BuddyListener.allowOnlineKey, 'true');
      build();
      await listener.ready;

      expect(listener.allowOnline, isTrue);
    });

    test('unreadable setting stays off', () async {
      build(settings: FailingKeyValueStore());
      await listener.ready;

      expect(listener.allowOnline, isFalse);
    });
  });
}
