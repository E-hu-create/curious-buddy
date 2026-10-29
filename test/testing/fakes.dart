import 'dart:async';

import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/voice/speech_recognition_service.dart';
import 'package:curious_buddy/data/services/voice/text_to_speech_service.dart';
import 'package:curious_buddy/data/services/voice/voice_failure.dart';

/// Records calls and returns scripted results.
///
/// With [holdSpeech], each line keeps "playing" until [stop] interrupts it or
/// [finishSpeaking] ends it, so tests can act while Buddy is mid-sentence.
class FakeTextToSpeechService implements TextToSpeechService {
  bool available = true;
  SpeakResult nextResult = const SpeakCompleted();
  Exception? throwOnSpeak;
  bool holdSpeech = false;

  final List<String> spoken = [];
  int stopCalls = 0;
  SpeechSpeed speed = SpeechSpeed.normal;
  Completer<SpeakResult>? _playing;

  bool get isSpeaking => _playing != null;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<SpeakResult> speak(String text) async {
    final error = throwOnSpeak;
    if (error != null) throw error;
    spoken.add(text);
    if (!holdSpeech) return nextResult;
    final playing = _playing = Completer<SpeakResult>();
    return playing.future;
  }

  void finishSpeaking() => _end(const SpeakCompleted());

  @override
  Future<void> setSpeed(SpeechSpeed speed) async => this.speed = speed;

  @override
  Future<void> stop() async {
    stopCalls++;
    _end(const SpeakInterrupted());
  }

  void _end(SpeakResult result) {
    final playing = _playing;
    _playing = null;
    playing?.complete(result);
  }
}

/// Store whose writes fail, to simulate a full or broken disk.
class ReadOnlyKeyValueStore extends InMemoryKeyValueStore {
  @override
  Future<void> write(String key, String value) async =>
      throw const FileSystemLikeException();
}

/// Scriptable recogniser. Counts every call so tests can assert the
/// microphone is never touched unless the child asked.
///
/// With [holdListening], a session stays open until [hear] / [finish] /
/// [stopListening] / [cancel], so tests can act while Buddy is listening.
class FakeSpeechRecognitionService implements SpeechRecognitionService {
  bool available = true;
  bool onDevice = true;
  MicrophonePermission permission = MicrophonePermission.unknown;
  bool grantOnRequest = true;
  ListenResult nextResult = const ListenHeard('Why is the sky blue?');
  bool holdListening = false;

  int totalCalls = 0;
  int permissionRequests = 0;
  int listenCalls = 0;
  int cancelCalls = 0;
  int stopCalls = 0;
  bool? lastAllowOnline;

  Completer<ListenResult>? _session;
  void Function(String words)? _onWords;
  String _words = '';

  bool get isListening => _session != null;

  @override
  Future<bool> isAvailable() async {
    totalCalls++;
    return available;
  }

  @override
  Future<bool> supportsOnDevice() async {
    totalCalls++;
    return onDevice;
  }

  @override
  Future<MicrophonePermission> checkPermission() async {
    totalCalls++;
    return permission;
  }

  @override
  Future<MicrophonePermission> requestPermission() async {
    totalCalls++;
    permissionRequests++;
    permission = grantOnRequest
        ? MicrophonePermission.granted
        : MicrophonePermission.denied;
    return permission;
  }

  @override
  Future<ListenResult> listen({
    Duration maxDuration = const Duration(seconds: 15),
    Duration pauseFor = const Duration(seconds: 3),
    bool allowOnline = false,
    void Function(String words)? onWords,
  }) async {
    totalCalls++;
    listenCalls++;
    lastAllowOnline = allowOnline;
    if (!allowOnline && !onDevice) {
      return const ListenFailed(VoiceFailure.offlineUnavailable);
    }
    if (!holdListening) return nextResult;
    _onWords = onWords;
    _words = '';
    return (_session = Completer<ListenResult>()).future;
  }

  /// Simulates partial words arriving while listening.
  void hear(String words) {
    _words = words;
    _onWords?.call(words);
  }

  /// Ends the held session with [result] (default: what was heard).
  void finish([ListenResult? result]) => _end(
    result ??
        (_words.isEmpty ? const ListenNothingHeard() : ListenHeard(_words)),
  );

  @override
  Future<void> stopListening() async {
    totalCalls++;
    stopCalls++;
    finish();
  }

  @override
  Future<void> cancel() async {
    totalCalls++;
    cancelCalls++;
    _end(const ListenCancelled());
  }

  void _end(ListenResult result) {
    final session = _session;
    _session = null;
    _onWords = null;
    session?.complete(result);
  }
}

/// Store whose reads fail, to simulate a storage error.
class FailingKeyValueStore implements KeyValueStore {
  final InMemoryKeyValueStore _inner = InMemoryKeyValueStore();
  int writes = 0;

  @override
  Future<String?> read(String key) async =>
      throw const FileSystemLikeException();

  @override
  Future<void> write(String key, String value) async {
    writes++;
    await _inner.write(key, value);
  }

  @override
  Future<void> delete(String key) => _inner.delete(key);
}

class FileSystemLikeException implements Exception {
  const FileSystemLikeException();
}
