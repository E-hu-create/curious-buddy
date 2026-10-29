import 'dart:async';

import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/voice/speech_recognition_service.dart';
import 'package:curious_buddy/data/services/voice/text_to_speech_service.dart';

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

/// Counts every call so tests can assert the microphone is never touched.
class FakeSpeechRecognitionService implements SpeechRecognitionService {
  int totalCalls = 0;
  int permissionRequests = 0;

  @override
  Future<bool> isAvailable() async {
    totalCalls++;
    return true;
  }

  @override
  Future<MicrophonePermission> checkPermission() async {
    totalCalls++;
    return MicrophonePermission.unknown;
  }

  @override
  Future<MicrophonePermission> requestPermission() async {
    totalCalls++;
    permissionRequests++;
    return MicrophonePermission.granted;
  }

  @override
  Future<ListenResult> listen({
    Duration maxDuration = const Duration(seconds: 10),
  }) async {
    totalCalls++;
    return const ListenNothingHeard();
  }

  @override
  Future<void> stopListening() async => totalCalls++;
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
