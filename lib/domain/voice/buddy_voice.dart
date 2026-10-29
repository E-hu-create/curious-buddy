import 'package:flutter/foundation.dart';

import '../../data/services/key_value_store.dart';
import '../../data/services/voice/text_to_speech_service.dart';
import 'narrator.dart';

enum VoiceStatus { checking, available, unavailable }

/// Buddy's voice for the whole app: one instance, shared by every screen, so
/// only one line can ever play at a time.
///
/// Adds app-level rules on top of [Narrator]:
/// * The on/off setting, saved through [KeyValueStore] so it survives
///   restarts once a persistent store is used.
/// * The welcome is spoken at most once per app session.
/// * [stop] also cancels speech that is still waiting for the engine.
class BuddyVoice extends ChangeNotifier {
  BuddyVoice({
    required TextToSpeechService textToSpeech,
    required KeyValueStore settings,
  }) : _tts = textToSpeech,
       _settings = settings,
       _narrator = Narrator(textToSpeech);

  static const mutedKey = 'voice.muted';

  final TextToSpeechService _tts;
  final KeyValueStore _settings;
  final Narrator _narrator;

  /// Completes once the saved setting and the engine have been checked.
  late final Future<void> ready = _init();

  VoiceStatus get status => _status;
  VoiceStatus _status = VoiceStatus.checking;

  bool get isMuted => _muted;
  bool _muted = false;

  /// True when Buddy will actually speak if asked.
  bool get canSpeak => _status == VoiceStatus.available && !_muted;

  bool get hasWelcomed => _hasWelcomed;
  bool _hasWelcomed = false;

  /// True while a line is being spoken (drives the Stop button).
  bool get isSpeaking => _speakingLine != null;
  int? _speakingLine;
  int _lines = 0;

  bool _disposed = false;
  int _stops = 0;

  Future<void> _init() async {
    try {
      _muted = await _settings.read(mutedKey) == 'true';
    } on Exception {
      _muted = false;
    }
    bool available;
    try {
      available = await _tts.isAvailable();
    } on Exception {
      available = false;
    }
    _status = available ? VoiceStatus.available : VoiceStatus.unavailable;
    _notify();
  }

  /// Speaks [text] unless muted or unavailable. The text must already be on
  /// screen; speech only adds to it.
  Future<NarrationOutcome> say(String text) async {
    final stops = _stops;
    await ready;
    if (_disposed || stops != _stops) return NarrationOutcome.interrupted;
    if (_muted) return NarrationOutcome.muted;
    if (_status != VoiceStatus.available) return NarrationOutcome.textOnly;

    final line = _speakingLine = ++_lines;
    _notify();
    final outcome = await _narrator.narrate(text);
    // A newer line or a stop may have taken over meanwhile.
    if (_speakingLine == line) {
      _speakingLine = null;
      _notify();
    }
    return outcome;
  }

  /// Speaks the welcome the first time it is called in this app session and
  /// does nothing afterwards, however often the screen rebuilds or reopens.
  Future<NarrationOutcome> welcomeOnce(String text) async {
    if (_hasWelcomed) return NarrationOutcome.skipped;
    _hasWelcomed = true;
    return say(text);
  }

  /// Turning the voice off stops anything playing. Turning it on does not
  /// start speaking by itself.
  Future<void> setMuted(bool muted) async {
    // Wait for the saved setting to load first, or loading it would
    // overwrite this choice.
    await ready;
    if (muted == _muted) return;
    _muted = muted;
    if (muted) await stop();
    _notify();
    try {
      await _settings.write(mutedKey, '$muted');
    } on Exception {
      // Setting still applies for this session.
    }
  }

  /// Stops current speech and cancels any not yet started.
  Future<void> stop() async {
    _stops++;
    if (_speakingLine != null) {
      _speakingLine = null;
      _notify();
    }
    await _narrator.stop();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stops++;
    _narrator.stop().ignore();
    super.dispose();
  }
}
