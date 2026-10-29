import 'voice_failure.dart';

sealed class SpeakResult {
  const SpeakResult();
}

final class SpeakCompleted extends SpeakResult {
  const SpeakCompleted();
}

/// Playback was stopped early, by [TextToSpeechService.stop] or by the
/// platform (e.g. an incoming call or audio focus loss).
final class SpeakInterrupted extends SpeakResult {
  const SpeakInterrupted();
}

final class SpeakFailed extends SpeakResult {
  const SpeakFailed(this.reason, [this.detail]);

  final VoiceFailure reason;
  final String? detail;
}

/// Speech output. Implementations wrap a platform engine and must not leak
/// plugin types through this interface.
abstract interface class TextToSpeechService {
  Future<bool> isAvailable();

  /// Speaks [text] and completes when playback ends. Must not throw for
  /// expected failures; return [SpeakFailed] instead.
  Future<SpeakResult> speak(String text);

  /// Stops any current playback. Must be safe to call when idle.
  Future<void> stop();
}

/// Default until a real engine is approved. Never pretends to speak.
class UnavailableTextToSpeechService implements TextToSpeechService {
  const UnavailableTextToSpeechService();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<SpeakResult> speak(String text) async =>
      const SpeakFailed(VoiceFailure.unavailable);

  @override
  Future<void> stop() async {}
}
