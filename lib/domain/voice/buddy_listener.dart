import 'package:flutter/foundation.dart';

import '../../data/services/key_value_store.dart';
import '../../data/services/voice/speech_recognition_service.dart';
import '../../data/services/voice/voice_failure.dart';
import 'buddy_voice.dart';

/// Buddy's ears for the whole app: one instance, owned by the app root, so
/// navigation and lifecycle changes can always stop the microphone.
///
/// * One short session per tap; never continuous, never in the background.
/// * Buddy stops talking before listening starts.
/// * "Allow online recognition" is a grown-up setting, off by default.
class BuddyListener extends ChangeNotifier {
  BuddyListener({
    required SpeechRecognitionService recognizer,
    required KeyValueStore settings,
    required BuddyVoice voice,
  }) : _recognizer = recognizer,
       _settings = settings,
       _voice = voice;

  static const allowOnlineKey = 'voice.allowOnlineRecognition';
  static const maxListen = Duration(seconds: 15);
  static const pauseFor = Duration(seconds: 3);

  final SpeechRecognitionService _recognizer;
  final KeyValueStore _settings;
  final BuddyVoice _voice;

  late final Future<void> ready = _init();

  bool get allowOnline => _allowOnline;
  bool _allowOnline = false;

  bool get isListening => _listening;
  bool _listening = false;

  /// Words recognised so far in the current session.
  String get words => _words;
  String _words = '';

  bool _disposed = false;

  Future<void> _init() async {
    try {
      _allowOnline = await _settings.read(allowOnlineKey) == 'true';
    } on Exception {
      _allowOnline = false;
    }
    _notify();
  }

  Future<void> setAllowOnline(bool allow) async {
    await ready;
    if (allow == _allowOnline) return;
    _allowOnline = allow;
    _notify();
    try {
      await _settings.write(allowOnlineKey, '$allow');
    } on Exception {
      // Applies for this session.
    }
  }

  Future<bool> isAvailable() async {
    try {
      return await _recognizer.isAvailable();
    } on Exception {
      return false;
    }
  }

  Future<bool> supportsOnDevice() async {
    try {
      return await _recognizer.supportsOnDevice();
    } on Exception {
      return false;
    }
  }

  Future<MicrophonePermission> checkPermission() async {
    try {
      return await _recognizer.checkPermission();
    } on Exception {
      return MicrophonePermission.unknown;
    }
  }

  /// Shows Android's permission prompt. Call only after the child tapped
  /// Talk and saw the explanation.
  Future<MicrophonePermission> requestPermission() async {
    try {
      return await _recognizer.requestPermission();
    } on Exception {
      return MicrophonePermission.unknown;
    }
  }

  /// One listening session. Ignored if one is already running.
  Future<ListenResult> listen() async {
    if (_listening) {
      return const ListenFailed(
        VoiceFailure.platformError,
        'already listening',
      );
    }
    await ready;
    await _voice.stop();
    _listening = true;
    _words = '';
    _notify();

    ListenResult result;
    try {
      result = await _recognizer.listen(
        maxDuration: maxListen,
        pauseFor: pauseFor,
        allowOnline: _allowOnline,
        onWords: (words) {
          _words = words;
          _notify();
        },
      );
    } on Exception catch (error) {
      result = ListenFailed(VoiceFailure.platformError, error.toString());
    }
    _listening = false;
    _notify();
    return result;
  }

  /// Finish now and keep what was heard.
  Future<void> stop() async {
    if (!_listening) return;
    await _recognizer.stopListening();
  }

  /// Finish now and throw away what was heard.
  Future<void> cancel() async {
    if (!_listening) return;
    await _recognizer.cancel();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_listening) _recognizer.cancel().ignore();
    super.dispose();
  }
}
