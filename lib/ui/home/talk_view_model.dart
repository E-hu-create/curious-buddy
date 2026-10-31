import 'package:flutter/foundation.dart';

import '../../data/services/voice/speech_recognition_service.dart';
import '../../data/services/voice/voice_failure.dart';
import '../../domain/voice/buddy_listener.dart';

/// What the screen should do after the child taps "Talk to Buddy".
enum TalkStep {
  /// Permission already granted: start listening.
  ready,

  /// Show the child-friendly explanation; only if they say OK, ask Android.
  needsPermission,

  /// Talking is not possible here; a notice explains and typing still works.
  unavailable,
}

/// Tap-to-talk flow for Home. When the child finishes speaking, the words go
/// straight to Buddy through [onHeard], with the same safety filter as typed
/// questions. Cancel discards them.
class TalkViewModel extends ChangeNotifier {
  TalkViewModel({
    required BuddyListener listener,
    required void Function(String words) onHeard,
  }) : _listener = listener,
       _onHeard = onHeard {
    _listener.addListener(_notify);
  }

  static const unavailableNotice =
      "Talking isn't available on this phone. You can type to Buddy instead!";
  static const deniedNotice =
      "That's okay! You can type to Buddy instead. "
      "A grown-up can turn on the microphone for Curious Buddy in the phone's "
      'Settings.';
  static const nothingHeardNotice =
      "I didn't catch that. Tap Talk to try again, or type it!";
  static const offlineUnavailableNotice =
      "This phone can't listen without the internet. "
      'A grown-up can allow online listening in the Parent Zone. '
      'You can type instead!';
  static const networkNotice =
      "Buddy couldn't hear you because the internet isn't working. "
      'Try again later, or type it!';
  static const errorNotice =
      "Oops, Buddy couldn't hear that. Try again, or type it!";

  final BuddyListener _listener;
  final void Function(String words) _onHeard;
  bool _disposed = false;
  bool _busy = false;

  bool get isListening => _listener.isListening;

  /// Words heard so far while listening.
  String get liveWords => _listener.words;

  /// A short message for the child about the last talk attempt.
  String? get notice => _notice;
  String? _notice;

  Future<TalkStep> prepare() async {
    _setNotice(null);
    if (!await _listener.isAvailable()) {
      _setNotice(unavailableNotice);
      return TalkStep.unavailable;
    }
    final permission = await _listener.checkPermission();
    return permission == MicrophonePermission.granted
        ? TalkStep.ready
        : TalkStep.needsPermission;
  }

  /// After the child agreed to the explanation: ask Android, then listen.
  Future<void> requestPermissionAndListen() async {
    final permission = await _listener.requestPermission();
    if (permission != MicrophonePermission.granted) {
      _setNotice(deniedNotice);
      return;
    }
    await listen();
  }

  Future<void> listen() async {
    if (_busy || _listener.isListening) return;
    _busy = true;
    _setNotice(null);
    final result = await _listener.listen();
    _busy = false;
    switch (result) {
      case ListenHeard(:final transcript):
        _onHeard(transcript);
      case ListenNothingHeard():
        _setNotice(nothingHeardNotice);
      case ListenCancelled():
        _setNotice(null);
      case ListenFailed(:final reason):
        _setNotice(switch (reason) {
          VoiceFailure.permissionDenied => deniedNotice,
          VoiceFailure.offlineUnavailable => offlineUnavailableNotice,
          VoiceFailure.network => networkNotice,
          VoiceFailure.unavailable => unavailableNotice,
          _ => errorNotice,
        });
    }
  }

  /// "Done": stop now and keep the words.
  Future<void> finish() => _listener.stop();

  /// "Cancel": stop now and discard the words.
  Future<void> cancel() => _listener.cancel();

  void clearNotice() => _setNotice(null);

  void _setNotice(String? notice) {
    _notice = notice;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _listener.removeListener(_notify);
    super.dispose();
  }
}
