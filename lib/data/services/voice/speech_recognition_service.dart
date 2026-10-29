import 'voice_failure.dart';

enum MicrophonePermission { unknown, granted, denied }

sealed class ListenResult {
  const ListenResult();
}

final class ListenHeard extends ListenResult {
  const ListenHeard(this.transcript);

  /// Recognised text only. Raw audio is never returned or stored.
  final String transcript;
}

final class ListenNothingHeard extends ListenResult {
  const ListenNothingHeard();
}

/// Listening was cancelled; any words heard are discarded.
final class ListenCancelled extends ListenResult {
  const ListenCancelled();
}

final class ListenFailed extends ListenResult {
  const ListenFailed(this.reason, [this.detail]);

  final VoiceFailure reason;
  final String? detail;
}

/// Optional tap-to-talk speech input.
///
/// Rules every implementation must follow:
/// * Never prompt for permission at app launch; only [requestPermission]
///   may prompt, and only after an explicit tap and an explanation.
/// * Never listen continuously or in the background: one [listen] call is
///   one short session that the child started.
/// * Never persist or upload audio from the app. Only the transcript leaves
///   this service.
/// * With `allowOnline: false`, never fall back to a recogniser that may
///   send audio off the device; fail with [VoiceFailure.offlineUnavailable].
abstract interface class SpeechRecognitionService {
  /// Whether this platform can do speech input at all. Must not prompt.
  Future<bool> isAvailable();

  /// Whether speech can be recognised without the network. Must not prompt.
  Future<bool> supportsOnDevice();

  /// Reads the current permission state without prompting.
  Future<MicrophonePermission> checkPermission();

  /// Shows the system permission prompt if Android allows it.
  Future<MicrophonePermission> requestPermission();

  /// Listens until speech ends, [pauseFor] of silence, [maxDuration], or
  /// [stopListening]/[cancel]. [onWords] receives words as they are
  /// recognised. Must not throw for expected failures.
  Future<ListenResult> listen({
    Duration maxDuration,
    Duration pauseFor,
    bool allowOnline,
    void Function(String words)? onWords,
  });

  /// Ends listening and returns what was heard so far. Safe when idle.
  Future<void> stopListening();

  /// Ends listening and discards what was heard. Safe when idle.
  Future<void> cancel();
}

/// Used where speech input is not supported (and in early tests). Never
/// touches the microphone.
class UnavailableSpeechRecognitionService implements SpeechRecognitionService {
  const UnavailableSpeechRecognitionService();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<bool> supportsOnDevice() async => false;

  @override
  Future<MicrophonePermission> checkPermission() async =>
      MicrophonePermission.unknown;

  @override
  Future<MicrophonePermission> requestPermission() async =>
      MicrophonePermission.unknown;

  @override
  Future<ListenResult> listen({
    Duration maxDuration = const Duration(seconds: 15),
    Duration pauseFor = const Duration(seconds: 3),
    bool allowOnline = false,
    void Function(String words)? onWords,
  }) async => const ListenFailed(VoiceFailure.unavailable);

  @override
  Future<void> stopListening() async {}

  @override
  Future<void> cancel() async {}
}
