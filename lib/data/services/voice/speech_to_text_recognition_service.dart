import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'speech_recognition_service.dart';
import 'voice_failure.dart';

/// The few plugin operations this app uses, so the logic below can be
/// tested without a phone. [PluginSpeechEngine] is the only class that
/// touches `speech_to_text`.
abstract interface class SpeechEngine {
  /// Initialises the recogniser. **Shows the system permission prompt** if
  /// the microphone has not been granted yet. Returns false if denied or no
  /// recogniser exists.
  Future<bool> initialize({
    required void Function(String error) onError,
    required void Function(String status) onStatus,
  });

  /// Checks the permission without prompting.
  Future<bool> hasPermission();

  /// True only if the phone can recognise speech without the network.
  Future<bool> isOnDeviceAvailable();

  Future<void> listen({
    required void Function(String words, bool isFinal) onResult,
    required Duration listenFor,
    required Duration pauseFor,
    required bool onDevice,
  });

  Future<void> stop();
  Future<void> cancel();
}

/// Tap-to-talk on Android's built-in speech recogniser.
///
/// The plugin's own `onDevice` flag only *prefers* on-device recognition and
/// silently falls back to a recogniser that may go online. So when online
/// is not allowed, this service first asks Android directly whether
/// on-device recognition exists, and refuses to listen if it does not.
class SpeechToTextRecognitionService implements SpeechRecognitionService {
  SpeechToTextRecognitionService({
    SpeechEngine Function()? createEngine,
    bool? platformSupported,
  }) : _createEngine = createEngine ?? PluginSpeechEngine.new,
       _platformSupported =
           platformSupported ??
           (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  final SpeechEngine Function() _createEngine;
  final bool _platformSupported;

  /// Created on first use, like the TTS plugin, so nothing touches platform
  /// channels before the Flutter binding exists.
  late final SpeechEngine _engine = _createEngine();

  bool _initialized = false;
  bool _askedOnce = false;
  Completer<ListenResult>? _session;
  String _words = '';
  bool _onDeviceSession = false;
  Timer? _safetyTimer;

  @override
  Future<bool> isAvailable() async => _platformSupported;

  @override
  Future<bool> supportsOnDevice() async {
    if (!_platformSupported) return false;
    try {
      return await _engine.isOnDeviceAvailable();
    } on Exception {
      return false;
    }
  }

  @override
  Future<MicrophonePermission> checkPermission() async {
    if (!_platformSupported) return MicrophonePermission.unknown;
    try {
      if (await _engine.hasPermission()) return MicrophonePermission.granted;
    } on Exception catch (error) {
      debugPrint('STT: permission check failed ($error)');
    }
    return _askedOnce
        ? MicrophonePermission.denied
        : MicrophonePermission.unknown;
  }

  @override
  Future<MicrophonePermission> requestPermission() async {
    if (!_platformSupported) return MicrophonePermission.unknown;
    _askedOnce = true;
    try {
      _initialized = await _engine.initialize(
        onError: _onError,
        onStatus: _onStatus,
      );
    } on Exception catch (error) {
      // e.g. "recognizerNotAvailable" when the phone has no recogniser.
      debugPrint('STT: initialize failed ($error)');
      _initialized = false;
    }
    return await checkPermission();
  }

  @override
  Future<ListenResult> listen({
    Duration maxDuration = const Duration(seconds: 15),
    Duration pauseFor = const Duration(seconds: 3),
    bool allowOnline = false,
    void Function(String words)? onWords,
  }) async {
    if (!_platformSupported) {
      return const ListenFailed(VoiceFailure.unavailable);
    }
    if (_session != null) {
      return const ListenFailed(
        VoiceFailure.platformError,
        'already listening',
      );
    }
    if (await checkPermission() != MicrophonePermission.granted) {
      return const ListenFailed(VoiceFailure.permissionDenied);
    }
    if (!_initialized) {
      // Permission granted but no working recogniser.
      return const ListenFailed(VoiceFailure.unavailable);
    }

    _onDeviceSession = !allowOnline;
    if (_onDeviceSession && !await supportsOnDevice()) {
      return const ListenFailed(VoiceFailure.offlineUnavailable);
    }

    final session = _session = Completer<ListenResult>();
    _words = '';
    _onWords = onWords;
    // Never leave a session hanging if the plugin goes quiet.
    _safetyTimer = Timer(
      maxDuration + const Duration(seconds: 5),
      _finishHeard,
    );
    try {
      await _engine.listen(
        onResult: (words, isFinal) {
          _words = words;
          _onWords?.call(words);
          if (isFinal) _finishHeard();
        },
        listenFor: maxDuration,
        pauseFor: pauseFor,
        onDevice: _onDeviceSession,
      );
    } on Exception catch (error) {
      _finish(ListenFailed(VoiceFailure.platformError, error.toString()));
    }
    return session.future;
  }

  void Function(String words)? _onWords;

  @override
  Future<void> stopListening() async {
    if (_session == null) return;
    try {
      await _engine.stop();
    } on Exception catch (error) {
      debugPrint('STT: stop failed ($error)');
    }
    // The plugin normally sends a final result after stop; if it does not,
    // finish with what was heard.
    _finishHeard();
  }

  @override
  Future<void> cancel() async {
    if (_session == null) return;
    _finish(const ListenCancelled());
    try {
      await _engine.cancel();
    } on Exception catch (error) {
      debugPrint('STT: cancel failed ($error)');
    }
  }

  void _onStatus(String status) {
    if (status == SpeechToText.doneStatus) _finishHeard();
  }

  void _onError(String error) {
    _finish(switch (error) {
      'error_no_match' || 'error_speech_timeout' => _wordsOrNothing(),
      'error_permission' => const ListenFailed(VoiceFailure.permissionDenied),
      'error_network' ||
      'error_network_timeout' ||
      'error_server' ||
      'error_server_disconnected' => const ListenFailed(VoiceFailure.network),
      'error_language_unavailable' || 'error_language_not_supported'
          when _onDeviceSession =>
        const ListenFailed(VoiceFailure.offlineUnavailable),
      _ => ListenFailed(VoiceFailure.platformError, error),
    });
  }

  void _finishHeard() => _finish(_wordsOrNothing());

  ListenResult _wordsOrNothing() {
    final words = _words.trim();
    return words.isEmpty ? const ListenNothingHeard() : ListenHeard(words);
  }

  void _finish(ListenResult result) {
    final session = _session;
    if (session == null) return;
    _session = null;
    _onWords = null;
    _safetyTimer?.cancel();
    _safetyTimer = null;
    session.complete(result);
  }
}

/// The real plugin. Not unit-tested (needs a phone); kept as thin as
/// possible and verified on a device.
class PluginSpeechEngine implements SpeechEngine {
  final SpeechToText _stt = SpeechToText();

  /// Answered by MainActivity.kt with Android's own
  /// `SpeechRecognizer.isOnDeviceRecognitionAvailable`.
  static const _channel = MethodChannel('curious_buddy/speech');

  @override
  Future<bool> initialize({
    required void Function(String error) onError,
    required void Function(String status) onStatus,
  }) => _stt.initialize(
    onError: (SpeechRecognitionError error) => onError(error.errorMsg),
    onStatus: onStatus,
    // Headset microphones are not needed, so no Bluetooth permission.
    options: [SpeechToText.androidNoBluetooth],
  );

  @override
  Future<bool> hasPermission() => _stt.hasPermission;

  @override
  Future<bool> isOnDeviceAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isOnDeviceAvailable') ?? false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<void> listen({
    required void Function(String words, bool isFinal) onResult,
    required Duration listenFor,
    required Duration pauseFor,
    required bool onDevice,
  }) async {
    await _stt.listen(
      onResult: (SpeechRecognitionResult result) =>
          onResult(result.recognizedWords, result.finalResult),
      listenOptions: SpeechListenOptions(
        listenFor: listenFor,
        pauseFor: pauseFor,
        onDevice: onDevice,
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      ),
    );
  }

  @override
  Future<void> stop() => _stt.stop();

  @override
  Future<void> cancel() => _stt.cancel();
}
