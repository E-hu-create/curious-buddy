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
    FlutterTts Function() createTts = FlutterTts.new,
    this.languages = const ['en-GB', 'en-US', 'en-AU', 'en-CA', 'en-IN'],
    this.speechRate = 0.43,
    this.pitch = 1.0,
    Duration setupTimeout = const Duration(seconds: 8),
    Duration Function(String text)? timeoutFor,
  }) : _createTts = createTts,
       _setupTimeout = setupTimeout,
       _timeoutFor = timeoutFor ?? _defaultTimeout;

  /// Tried in order; the first one installed on the device is used.
  final List<String> languages;

  /// Android scale: 0.5 is the engine's normal speed. A little slower than
  /// that, at a natural pitch, sounds calm and clear rather than cartoonish.
  final double speechRate;
  final double pitch;

  /// Google's engine usually has clearer voices than a phone maker's. Used
  /// when installed; otherwise the phone's own engine stays.
  static const preferredEngine = 'com.google.android.tts';

  static const _qualityRank = {
    'very high': 4,
    'high': 3,
    'normal': 2,
    'low': 1,
    'very low': 0,
  };

  final FlutterTts Function() _createTts;

  /// Created on first use, not in the constructor: `FlutterTts()` registers
  /// a platform channel handler, which crashes if it runs before the Flutter
  /// binding exists (e.g. when dependencies are built at the top of main).
  late final FlutterTts _tts = _createTts();

  final Duration _setupTimeout;
  final Duration Function(String text) _timeoutFor;

  Future<bool>? _availability;
  SpeechSpeed _speed = SpeechSpeed.normal;
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
      await _preferClearEngine();
      for (final language in languages) {
        if (await _tts.isLanguageAvailable(language) == true) {
          await _tts.setLanguage(language);
          await _pickClearVoice(language);
          await _tts.setSpeechRate(speechRate * _speed.factor);
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

  Future<void> _preferClearEngine() async {
    try {
      final engines = await _tts.getEngines;
      if (engines is! List || !engines.contains(preferredEngine)) return;
      await _tts.setEngine(preferredEngine).timeout(const Duration(seconds: 3));
    } on Exception catch (error) {
      debugPrint('TTS: keeping the default engine ($error)');
    }
  }

  /// The best voice for [language] that works offline, because Buddy must
  /// never need the internet to speak. If none is listed, the engine's
  /// default stays.
  Future<void> _pickClearVoice(String language) async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return;
      String tag(Object? locale) =>
          locale.toString().replaceAll('_', '-').toLowerCase();
      final offline = [
        for (final voice in voices.whereType<Map<Object?, Object?>>())
          if (tag(voice['locale']) == language.toLowerCase() &&
              voice['network_required'] != '1' &&
              !voice['name'].toString().contains('network'))
            voice,
      ];
      if (offline.isEmpty) return;
      int rank(Map<Object?, Object?> v) => _qualityRank[v['quality']] ?? 2;
      offline.sort((a, b) {
        final byQuality = rank(b).compareTo(rank(a));
        return byQuality != 0
            ? byQuality
            : a['name'].toString().compareTo(b['name'].toString());
      });
      final best = offline.first;
      debugPrint('TTS: voice ${best['name']} (${best['quality']})');
      await _tts.setVoice({
        'name': best['name'].toString(),
        'locale': best['locale'].toString(),
      });
    } on Exception catch (error) {
      debugPrint('TTS: keeping the default voice ($error)');
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

  @override
  Future<void> setSpeed(SpeechSpeed speed) async {
    _speed = speed;
    // Before setup, the speed is applied when the engine is set up.
    if (_availability == null || !await isAvailable()) return;
    try {
      await _tts.setSpeechRate(speechRate * speed.factor);
    } on Exception catch (error) {
      debugPrint('TTS: could not change speed ($error)');
    }
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
