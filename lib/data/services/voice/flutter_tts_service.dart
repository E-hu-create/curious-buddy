import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'text_to_speech_service.dart';
import 'voice_failure.dart';

/// [TextToSpeechService] backed by the device's built-in speech engine
/// (Google/Samsung TTS on Android) via `flutter_tts`. No network APIs, no
/// keys, no microphone.
///
/// The plugin's own `speak()` future cannot be trusted to finish: on Android
/// it never completes after an engine error. So each request is tracked here
/// and resolved by the plugin's completion/error callbacks, by [stop], or by
/// a timeout, whichever comes first.
class FlutterTtsService implements TextToSpeechService {
  FlutterTtsService({
    FlutterTts? tts,
    this.languages = const ['en-US', 'en-GB', 'en-AU', 'en-CA', 'en-IN'],
    this.speechRate = 0.5,
    this.pitch = 1.15,
    Duration setupTimeout = const Duration(seconds: 8),
    Duration Function(String text)? timeoutFor,
  }) : _tts = tts ?? FlutterTts(),
       _setupTimeout = setupTimeout,
       _timeoutFor = timeoutFor ?? _defaultTimeout;

  /// Tried in order; the first one installed on the device is used.
  final List<String> languages;

  /// Android scale: 0.5 is the engine's normal speed.
  final double speechRate;
  final double pitch;

  final FlutterTts _tts;
  final Duration _setupTimeout;
  final Duration Function(String text) _timeoutFor;

  Future<bool>? _availability;
  Completer<SpeakResult>? _current;
  Timer? _timeout;

  /// The language in use, once [isAvailable] has found one.
  String? get language => _language;
  String? _language;

  static Duration _defaultTimeout(String text) =>
      Duration(seconds: 6) + Duration(milliseconds: 120 * text.length);

  /// Checked once per app session and cached.
  @override
  Future<bool> isAvailable() => _availability ??= _setUp().timeout(
    _setupTimeout,
    onTimeout: () {
      debugPrint('TTS: engine did not respond during setup');
      return false;
    },
  );

  Future<bool> _setUp() async {
    try {
      _tts
        ..setCompletionHandler(() => _finish(const SpeakCompleted()))
        ..setErrorHandler(
          (message) => _finish(
            SpeakFailed(VoiceFailure.platformError, message?.toString()),
          ),
        );
      await _tts.awaitSpeakCompletion(false);
      for (final language in languages) {
        if (await _tts.isLanguageAvailable(language) == true) {
          await _tts.setLanguage(language);
          await _tts.setSpeechRate(speechRate);
          await _tts.setPitch(pitch);
          await _tts.setVolume(1.0);
          _language = language;
          return true;
        }
      }
      debugPrint('TTS: no English voice installed');
      return false;
    } on Exception catch (error) {
      // MissingPluginException (no engine/plugin) and PlatformException.
      debugPrint('TTS: unavailable ($error)');
      return false;
    }
  }

  @override
  Future<SpeakResult> speak(String text) async {
    if (!await isAvailable()) {
      return const SpeakFailed(VoiceFailure.unavailable);
    }
    _finish(const SpeakInterrupted());

    final request = Completer<SpeakResult>();
    _current = request;
    _timeout = Timer(_timeoutFor(text), () {
      _finish(const SpeakFailed(VoiceFailure.platformError, 'timed out'));
      unawaited(_stopEngine());
    });
    unawaited(_start(text, request));
    return request.future;
  }

  Future<void> _start(String text, Completer<SpeakResult> request) async {
    try {
      final result = await _tts.speak(text);
      if (result != 1) {
        _finish(
          SpeakFailed(VoiceFailure.platformError, 'speak returned $result'),
          only: request,
        );
      }
    } on Exception catch (error) {
      _finish(
        SpeakFailed(VoiceFailure.platformError, error.toString()),
        only: request,
      );
    }
  }

  @override
  Future<void> stop() async {
    _finish(const SpeakInterrupted());
    await _stopEngine();
  }

  Future<void> _stopEngine() async {
    try {
      await _tts.stop();
    } on Exception catch (error) {
      debugPrint('TTS: stop failed ($error)');
    }
  }

  /// Resolves the current request once. With [only], resolves it only if it
  /// is still that request, so a late result cannot end a newer one.
  void _finish(SpeakResult result, {Completer<SpeakResult>? only}) {
    final current = _current;
    if (current == null || (only != null && !identical(current, only))) {
      return;
    }
    _current = null;
    _timeout?.cancel();
    _timeout = null;
    current.complete(result);
  }
}
