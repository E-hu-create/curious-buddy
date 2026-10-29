import 'voice_failure.dart';

enum MicrophonePermission { unknown, granted, denied, permanentlyDenied }

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

final class ListenFailed extends ListenResult {
  const ListenFailed(this.reason, [this.detail]);

  final VoiceFailure reason;
  final String? detail;
}

/// Optional push-to-talk speech input.
///
/// Rules every implementation must follow:
/// * Never prompt for permission at app launch; only [requestPermission]
///   may prompt, and only in response to an explicit child or parent action.
/// * Never persist or upload audio. Only the transcript leaves this service.
/// * Release the microphone when [listen] completes or [stopListening] is
///   called.
abstract interface class SpeechRecognitionService {
  Future<bool> isAvailable();

  /// Reads the current permission state without prompting.
  Future<MicrophonePermission> checkPermission();

  /// Shows the system permission prompt if allowed to.
  Future<MicrophonePermission> requestPermission();

  /// Listens until speech ends, [maxDuration] elapses or [stopListening]
  /// is called. Must not throw for expected failures.
  Future<ListenResult> listen({Duration maxDuration});

  /// Must be safe to call when not listening.
  Future<void> stopListening();
}

/// Default until a real engine is approved. Never touches the microphone.
class UnavailableSpeechRecognitionService implements SpeechRecognitionService {
  const UnavailableSpeechRecognitionService();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<MicrophonePermission> checkPermission() async =>
      MicrophonePermission.unknown;

  @override
  Future<MicrophonePermission> requestPermission() async =>
      MicrophonePermission.unknown;

  @override
  Future<ListenResult> listen({
    Duration maxDuration = const Duration(seconds: 10),
  }) async => const ListenFailed(VoiceFailure.unavailable);

  @override
  Future<void> stopListening() async {}
}
