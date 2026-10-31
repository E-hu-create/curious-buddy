import 'dart:async';

import 'package:curious_buddy/data/services/voice/speech_recognition_service.dart';
import 'package:curious_buddy/data/services/voice/speech_to_text_recognition_service.dart';
import 'package:curious_buddy/data/services/voice/voice_failure.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the speech_to_text plugin.
class FakeSpeechEngine implements SpeechEngine {
  bool permissionGranted = false;
  bool grantOnInitialize = true;
  bool recognizerExists = true;
  bool onDevice = true;
  Object? throwOnInitialize;

  int initializeCalls = 0;
  int stopCalls = 0;
  int cancelCalls = 0;
  bool? lastOnDevice;
  Duration? lastListenFor;
  Duration? lastPauseFor;

  void Function(String)? _onError;
  void Function(String)? _onStatus;
  void Function(String, bool)? _onResult;

  @override
  Future<bool> initialize({
    required void Function(String error) onError,
    required void Function(String status) onStatus,
  }) async {
    initializeCalls++;
    final error = throwOnInitialize;
    if (error != null) throw error;
    _onError = onError;
    _onStatus = onStatus;
    if (grantOnInitialize) permissionGranted = true;
    return permissionGranted && recognizerExists;
  }

  @override
  Future<bool> hasPermission() async => permissionGranted;

  @override
  Future<bool> isOnDeviceAvailable() async => onDevice;

  @override
  Future<void> listen({
    required void Function(String words, bool isFinal) onResult,
    required Duration listenFor,
    required Duration pauseFor,
    required bool onDevice,
  }) async {
    _onResult = onResult;
    lastOnDevice = onDevice;
    lastListenFor = listenFor;
    lastPauseFor = pauseFor;
  }

  @override
  Future<void> stop() async => stopCalls++;

  @override
  Future<void> cancel() async => cancelCalls++;

  void result(String words, {bool isFinal = false}) =>
      _onResult!(words, isFinal);
  void error(String code) => _onError!(code);
  void status(String status) => _onStatus!(status);
}

void main() {
  late FakeSpeechEngine engine;
  late SpeechToTextRecognitionService service;

  SpeechToTextRecognitionService build({bool platformSupported = true}) =>
      service = SpeechToTextRecognitionService(
        createEngine: () => engine,
        platformSupported: platformSupported,
      );

  setUp(() => engine = FakeSpeechEngine());

  Future<void> granted() async {
    build();
    await service.requestPermission();
  }

  group('permission', () {
    test('checking never prompts', () async {
      build();

      expect(await service.checkPermission(), MicrophonePermission.unknown);
      expect(engine.initializeCalls, 0);
    });

    test('request prompts once via initialize and reports granted', () async {
      build();

      expect(await service.requestPermission(), MicrophonePermission.granted);
      expect(engine.initializeCalls, 1);
    });

    test('denied after asking is reported as denied', () async {
      engine.grantOnInitialize = false;
      build();

      expect(await service.requestPermission(), MicrophonePermission.denied);
      expect(await service.checkPermission(), MicrophonePermission.denied);
    });

    test('initialize throwing (no recogniser) does not crash', () async {
      engine
        ..throwOnInitialize = PlatformException(code: 'recognizerNotAvailable')
        ..permissionGranted = true;
      build();

      expect(await service.requestPermission(), MicrophonePermission.granted);
      expect(
        await service.listen(),
        isA<ListenFailed>().having(
          (f) => f.reason,
          'reason',
          VoiceFailure.unavailable,
        ),
      );
    });

    test('unsupported platform: unavailable, never initialises', () async {
      build(platformSupported: false);

      expect(await service.isAvailable(), isFalse);
      expect(await service.requestPermission(), MicrophonePermission.unknown);
      expect(await service.listen(), isA<ListenFailed>());
      expect(engine.initializeCalls, 0);
    });
  });

  group('listening', () {
    // Permission was granted in an earlier session, so this session never
    // asks again. The recogniser must still start (bug found on a Samsung
    // A51: "Talking isn't available" after restarting the app).
    test(
      'listens after a restart when permission was granted before',
      () async {
        engine.permissionGranted = true;
        build();

        final session = service.listen();
        await pumpEventQueue();
        engine.result('why is the sky blue', isFinal: true);

        expect(await session, isA<ListenHeard>());
        expect(engine.initializeCalls, 1);
      },
    );

    test('a restart never prompts before the child taps Talk', () async {
      engine.permissionGranted = true;
      build();

      expect(await service.checkPermission(), MicrophonePermission.granted);
      expect(engine.initializeCalls, 0);
    });

    test('refuses to listen without permission', () async {
      build();

      expect(
        await service.listen(),
        isA<ListenFailed>().having(
          (f) => f.reason,
          'reason',
          VoiceFailure.permissionDenied,
        ),
      );
    });

    test('final result returns the words, partials reported live', () async {
      await granted();
      final partials = <String>[];
      final session = service.listen(onWords: partials.add);
      await pumpEventQueue();

      engine
        ..result('why is')
        ..result('why is the sky blue', isFinal: true);

      expect(
        await session,
        isA<ListenHeard>().having(
          (h) => h.transcript,
          'transcript',
          'why is the sky blue',
        ),
      );
      expect(partials, ['why is', 'why is the sky blue']);
    });

    test('passes the time limits through', () async {
      await granted();
      unawaited(
        service.listen(
          maxDuration: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
        ),
      );
      await pumpEventQueue();

      expect(engine.lastListenFor, const Duration(seconds: 15));
      expect(engine.lastPauseFor, const Duration(seconds: 3));
      await service.cancel();
    });

    test('"done" status finishes with the words so far', () async {
      await granted();
      final session = service.listen();
      await pumpEventQueue();
      engine
        ..result('hello buddy')
        ..status('done');

      expect(await session, isA<ListenHeard>());
    });

    test('no match / speech timeout means nothing heard', () async {
      for (final code in ['error_no_match', 'error_speech_timeout']) {
        await granted();
        final session = service.listen();
        await pumpEventQueue();
        engine.error(code);

        expect(await session, isA<ListenNothingHeard>(), reason: code);
      }
    });

    test('network errors are reported as network', () async {
      await granted();
      final session = service.listen(allowOnline: true);
      await pumpEventQueue();
      engine.error('error_network');

      expect(
        await session,
        isA<ListenFailed>().having(
          (f) => f.reason,
          'reason',
          VoiceFailure.network,
        ),
      );
    });

    test('stop keeps the words heard so far', () async {
      await granted();
      final session = service.listen();
      await pumpEventQueue();
      engine.result('tell me a fact');

      await service.stopListening();

      expect(
        await session,
        isA<ListenHeard>().having((h) => h.transcript, 't', 'tell me a fact'),
      );
      expect(engine.stopCalls, 1);
    });

    test('cancel discards words and stops the engine', () async {
      await granted();
      final session = service.listen();
      await pumpEventQueue();
      engine.result('never mind');

      await service.cancel();

      expect(await session, isA<ListenCancelled>());
      expect(engine.cancelCalls, 1);
    });

    test('stop and cancel when idle are safe and do nothing', () async {
      await granted();

      await service.stopListening();
      await service.cancel();

      expect(engine.stopCalls, 0);
      expect(engine.cancelCalls, 0);
    });

    test('a second listen while one is open is refused', () async {
      await granted();
      unawaited(service.listen());
      await pumpEventQueue();

      expect(await service.listen(), isA<ListenFailed>());
      await service.cancel();
    });

    test(
      'never hangs if the plugin goes quiet',
      () async {
        await granted();
        final session = service.listen(
          maxDuration: const Duration(milliseconds: 10),
        );
        await pumpEventQueue();
        engine.result('half a sent');

        // Safety timer = maxDuration + 5s; use a real wait with fake time off.
        final result = await session.timeout(
          const Duration(seconds: 7),
          onTimeout: () =>
              const ListenFailed(VoiceFailure.platformError, 'hung'),
        );
        expect(result, isA<ListenHeard>());
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });

  group('on-device only unless a grown-up allows online', () {
    test(
      'online not allowed and on-device available: on-device session',
      () async {
        await granted();
        unawaited(service.listen());
        await pumpEventQueue();

        expect(engine.lastOnDevice, isTrue);
        await service.cancel();
      },
    );

    test('online not allowed and no on-device recogniser: refuses', () async {
      engine.onDevice = false;
      await granted();

      expect(
        await service.listen(),
        isA<ListenFailed>().having(
          (f) => f.reason,
          'reason',
          VoiceFailure.offlineUnavailable,
        ),
      );
      expect(engine.lastOnDevice, isNull, reason: 'engine.listen not called');
    });

    test('online allowed: may use the online recogniser', () async {
      engine.onDevice = false;
      await granted();
      unawaited(service.listen(allowOnline: true));
      await pumpEventQueue();

      expect(engine.lastOnDevice, isFalse);
      await service.cancel();
    });

    test('missing on-device language pack is reported as offline', () async {
      await granted();
      final session = service.listen();
      await pumpEventQueue();
      engine.error('error_language_unavailable');

      expect(
        await session,
        isA<ListenFailed>().having(
          (f) => f.reason,
          'reason',
          VoiceFailure.offlineUnavailable,
        ),
      );
    });

    test('supportsOnDevice never prompts', () async {
      build();

      expect(await service.supportsOnDevice(), isTrue);
      expect(engine.initializeCalls, 0);
    });
  });

  test('the plugin is created on first use, not on construction', () async {
    var created = 0;
    final lazy = SpeechToTextRecognitionService(
      createEngine: () {
        created++;
        return engine;
      },
      platformSupported: true,
    );
    expect(created, 0);

    await lazy.checkPermission();
    expect(created, 1);
  });
}
