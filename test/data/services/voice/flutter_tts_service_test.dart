import 'package:curious_buddy/data/services/voice/flutter_tts_service.dart';
import 'package:curious_buddy/data/services/voice/text_to_speech_service.dart';
import 'package:curious_buddy/data/services/voice/voice_failure.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the Android side of the flutter_tts plugin.
class FakeTtsPlatform {
  FakeTtsPlatform({this.installed = const {'en-US'}}) {
    messenger.setMockMethodCallHandler(channel, _handle);
  }

  static const channel = MethodChannel('flutter_tts');
  static final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  Set<String> installed;
  final List<MethodCall> calls = [];
  Object speakReturns = 1;
  bool throwOnSpeak = false;

  List<String> get methods => [for (final call in calls) call.method];

  Future<Object?> _handle(MethodCall call) async {
    calls.add(call);
    switch (call.method) {
      case 'isLanguageAvailable':
        return installed.contains(call.arguments);
      case 'speak':
        if (throwOnSpeak) {
          throw PlatformException(code: 'TtsError', message: 'engine died');
        }
        return speakReturns;
      default:
        return 1;
    }
  }

  /// Simulates the engine calling back into Dart.
  Future<void> emit(String method, [Object? arguments]) =>
      messenger.handlePlatformMessage(
        channel.name,
        const StandardMethodCodec().encodeMethodCall(
          MethodCall(method, arguments),
        ),
        (_) {},
      );

  void detach() => messenger.setMockMethodCallHandler(channel, null);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeTtsPlatform platform;

  setUp(() => platform = FakeTtsPlatform());
  tearDown(() => platform.detach());

  group('availability', () {
    test('uses US English when installed and configures the voice', () async {
      final service = FlutterTtsService();

      expect(await service.isAvailable(), isTrue);
      expect(service.language, 'en-US');
      expect(
        platform.methods,
        containsAllInOrder([
          'awaitSpeakCompletion',
          'isLanguageAvailable',
          'setLanguage',
          'setSpeechRate',
          'setPitch',
          'setVolume',
        ]),
      );
    });

    test('falls back to another English voice', () async {
      platform.installed = {'en-GB'};
      final service = FlutterTtsService();

      expect(await service.isAvailable(), isTrue);
      expect(service.language, 'en-GB');
    });

    test('no English voice installed means unavailable', () async {
      platform.installed = {'fr-FR'};
      final service = FlutterTtsService();

      expect(await service.isAvailable(), isFalse);
      expect(
        await service.speak('Hi'),
        isA<SpeakFailed>().having(
          (f) => f.reason,
          'reason',
          VoiceFailure.unavailable,
        ),
      );
      expect(platform.methods, isNot(contains('speak')));
    });

    test('missing plugin means unavailable, not a crash', () async {
      platform.detach();
      final service = FlutterTtsService();

      expect(await service.isAvailable(), isFalse);
    });

    test('is checked once and cached', () async {
      final service = FlutterTtsService();
      await service.isAvailable();
      await service.isAvailable();

      expect(
        platform.methods.where((m) => m == 'isLanguageAvailable'),
        hasLength(1),
      );
    });
  });

  group('speak', () {
    late FlutterTtsService service;

    setUp(() async {
      service = FlutterTtsService();
      await service.isAvailable();
    });

    test('completes when the engine reports it finished', () async {
      final result = service.speak('Hello');
      await pumpEventQueue();
      // Android sends {text, focus}; other platforms send the text alone.
      final arguments = platform.calls.last.arguments;
      expect(arguments is Map ? arguments['text'] : arguments, 'Hello');

      await platform.emit('speak.onComplete');

      expect(await result, isA<SpeakCompleted>());
    });

    test('engine error resolves as a failure instead of hanging', () async {
      final result = service.speak('Hello');
      await pumpEventQueue();

      await platform.emit('speak.onError', 'Error from TextToSpeech - -8');

      expect(
        await result,
        isA<SpeakFailed>()
            .having((f) => f.reason, 'reason', VoiceFailure.platformError)
            .having((f) => f.detail, 'detail', contains('-8')),
      );
    });

    test('speak rejected by the engine is a failure', () async {
      platform.speakReturns = 0;

      expect(await service.speak('Hello'), isA<SpeakFailed>());
    });

    test('platform exception is a failure', () async {
      platform.throwOnSpeak = true;

      expect(await service.speak('Hello'), isA<SpeakFailed>());
    });

    test('stop interrupts and tells the engine to stop', () async {
      final result = service.speak('A long sentence');
      await pumpEventQueue();

      await service.stop();

      expect(await result, isA<SpeakInterrupted>());
      expect(platform.methods.last, 'stop');
    });

    test('a new line interrupts the previous one', () async {
      final first = service.speak('One');
      await pumpEventQueue();
      final second = service.speak('Two');
      await pumpEventQueue();

      expect(await first, isA<SpeakInterrupted>());
      await platform.emit('speak.onComplete');
      expect(await second, isA<SpeakCompleted>());
    });

    test('times out if the engine never answers', () async {
      final quick = FlutterTtsService(
        timeoutFor: (_) => const Duration(milliseconds: 20),
      );
      await quick.isAvailable();

      final result = await quick.speak('Hello');

      expect(
        result,
        isA<SpeakFailed>().having((f) => f.detail, 'detail', 'timed out'),
      );
      await pumpEventQueue();
      expect(platform.methods.last, 'stop');
    });

    test('stop when idle is safe', () async {
      await service.stop();

      expect(platform.methods.last, 'stop');
    });
  });
}
