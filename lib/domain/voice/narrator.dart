import '../../data/services/voice/text_to_speech_service.dart';

enum NarrationOutcome {
  spoken,
  interrupted,

  /// Voice was unavailable or failed. The UI must already show the text on
  /// screen, so the child loses nothing; it should not show an error.
  textOnly,

  /// The user has turned Buddy's voice off.
  muted,

  /// Nothing was spoken because it was not needed (e.g. the welcome was
  /// already given this session).
  skipped,

  nothingToReplay,
}

/// Buddy's spoken narration on top of [TextToSpeechService].
///
/// Owns the playback policy so screens do not each reinvent it:
/// * Starting new narration interrupts whatever is playing.
/// * [stop] cancels narration even if it has not reached the engine yet, so
///   a stopped line can never start speaking late.
/// * The last line can be replayed on request ("say that again").
/// * Any failure degrades to on-screen text; narration never blocks progress.
class Narrator {
  Narrator(this._tts);

  final TextToSpeechService _tts;
  String? _lastText;

  /// Bumped by every [narrate] and [stop]; a narration that sees a newer
  /// value after an await has been superseded and must not speak.
  int _generation = 0;

  String? get lastText => _lastText;

  Future<NarrationOutcome> narrate(String text) async {
    _lastText = text;
    final generation = ++_generation;
    try {
      await _tts.stop();
      if (generation != _generation) return NarrationOutcome.interrupted;
      if (!await _tts.isAvailable()) return NarrationOutcome.textOnly;
      if (generation != _generation) return NarrationOutcome.interrupted;
      return switch (await _tts.speak(text)) {
        SpeakCompleted() => NarrationOutcome.spoken,
        SpeakInterrupted() => NarrationOutcome.interrupted,
        SpeakFailed() => NarrationOutcome.textOnly,
      };
    } on Exception {
      // Contract says implementations should not throw, but a plugin bug
      // must never crash a child's session.
      return NarrationOutcome.textOnly;
    }
  }

  Future<NarrationOutcome> replay() async {
    final text = _lastText;
    if (text == null) return NarrationOutcome.nothingToReplay;
    return narrate(text);
  }

  Future<void> stop() async {
    _generation++;
    try {
      await _tts.stop();
    } on Exception {
      // Stopping is best-effort.
    }
  }
}
