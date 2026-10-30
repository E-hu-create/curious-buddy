import 'package:flutter/foundation.dart';

import '../../data/services/key_value_store.dart';
import '../../data/services/sound/sound_effects_service.dart';
import '../../data/services/voice/text_to_speech_service.dart';
import 'narrator.dart';

enum VoiceStatus { checking, available, unavailable }

/// Buddy's voice for the whole app: one instance, shared by every screen, so
/// only one line can ever play at a time.
///
/// Adds app-level rules on top of [Narrator]:
/// * The grown-up voice settings, saved through [KeyValueStore] so they
///   survive restarts: on/off, speaking speed, and whether Buddy reads new
///   text automatically or only when the child taps a read button.
/// * Sound effects, which never play over speech: a line's [say] `lead`
///   plays first, and Buddy speaks when it has finished.
/// * The welcome is spoken at most once per app session.
/// * [stop] also cancels speech that is still waiting for the engine.
class BuddyVoice extends ChangeNotifier {
  BuddyVoice({
    required TextToSpeechService textToSpeech,
    required KeyValueStore settings,
    SoundEffectsService? sounds,
  }) : _tts = textToSpeech,
       _sounds = sounds,
       _settings = settings,
       _narrator = Narrator(textToSpeech);

  static const mutedKey = 'voice.muted';
  static const speedKey = 'voice.speed';
  static const autoReadKey = 'voice.autoRead';
  static const soundsKey = 'sound.effects';

  final TextToSpeechService _tts;
  final SoundEffectsService? _sounds;
  final KeyValueStore _settings;
  final Narrator _narrator;

  /// Completes once the saved setting and the engine have been checked.
  late final Future<void> ready = _init();

  VoiceStatus get status => _status;
  VoiceStatus _status = VoiceStatus.checking;

  bool get isMuted => _muted;
  bool _muted = false;

  SpeechSpeed get speed => _speed;
  SpeechSpeed _speed = SpeechSpeed.normal;

  /// When false, Buddy only speaks when asked (Hear again, read buttons).
  bool get autoRead => _autoRead;
  bool _autoRead = true;

  /// Sound effects are separate from Buddy's voice.
  bool get soundsOn => _soundsOn;
  bool _soundsOn = true;

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
  int _says = 0;

  Future<void> _init() async {
    try {
      _muted = await _settings.read(mutedKey) == 'true';
      _autoRead = await _settings.read(autoReadKey) != 'false';
      _soundsOn = await _settings.read(soundsKey) != 'false';
      final speed = await _settings.read(speedKey);
      _speed = SpeechSpeed.values.firstWhere(
        (s) => s.name == speed,
        orElse: () => SpeechSpeed.normal,
      );
    } on Exception {
      // Safe defaults: voice on, normal speed, reads automatically.
    }
    await _tts.setSpeed(_speed);
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
  ///
  /// [requested] is true when the child tapped something to hear it (Hear
  /// again, a read button). Other lines are automatic narration, which a
  /// grown-up can turn off; then an automatic line silences anything still
  /// playing, so old speech never runs on over a new page.
  ///
  /// [lead] is a sound effect to play first. It plays even if Buddy's voice
  /// is off, and he starts speaking only when it has finished.
  Future<NarrationOutcome> say(
    String text, {
    bool requested = false,
    SoundEffect? lead,
  }) async {
    final stops = _stops;
    final ticket = ++_says;
    await ready;
    if (_disposed || stops != _stops) return NarrationOutcome.interrupted;
    if (lead != null && _soundsOn) {
      // Old speech ends first, so the sound never plays over it.
      if (_speakingLine != null) {
        _speakingLine = null;
        _notify();
        await _narrator.stop();
      }
      await _sounds?.play(lead);
      if (_disposed || stops != _stops || ticket != _says) {
        return NarrationOutcome.interrupted;
      }
    }
    if (_muted) return NarrationOutcome.muted;
    if (!requested && !_autoRead) {
      await stop();
      return NarrationOutcome.skipped;
    }
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

  /// Plays a small effect on its own. Skipped while Buddy is talking, so it
  /// never plays over him.
  Future<void> effect(SoundEffect effect) async {
    await ready;
    if (_disposed || !_soundsOn || isSpeaking) return;
    await _sounds?.play(effect);
  }

  Future<void> setSoundsOn(bool on) async {
    await ready;
    if (on == _soundsOn) return;
    _soundsOn = on;
    _notify();
    await _save(soundsKey, '$on');
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

  Future<void> setSpeed(SpeechSpeed speed) async {
    await ready;
    if (speed == _speed) return;
    _speed = speed;
    _notify();
    await _tts.setSpeed(speed);
    await _save(speedKey, speed.name);
  }

  Future<void> setAutoRead(bool autoRead) async {
    await ready;
    if (autoRead == _autoRead) return;
    _autoRead = autoRead;
    _notify();
    await _save(autoReadKey, '$autoRead');
  }

  Future<void> _save(String key, String value) async {
    try {
      await _settings.write(key, value);
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
