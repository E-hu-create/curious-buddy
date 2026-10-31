import 'voice_failure.dart';

/// How fast Buddy talks, relative to the engine's normal speed.
enum SpeechSpeed {
  slowest(0.7),
  slower(0.85),
  normal(1),
  faster(1.15),
  fastest(1.3);

  const SpeechSpeed(this.factor);

  final double factor;
}

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

  /// Changes the speaking speed for later lines. Must not throw.
  Future<void> setSpeed(SpeechSpeed speed);
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

  @override
  Future<void> setSpeed(SpeechSpeed speed) async {}
}
