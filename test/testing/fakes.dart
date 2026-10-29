import 'package:curious_buddy/data/services/key_value_store.dart';
import 'package:curious_buddy/data/services/voice/speech_recognition_service.dart';
import 'package:curious_buddy/data/services/voice/text_to_speech_service.dart';

/// Records calls and returns scripted results.
class FakeTextToSpeechService implements TextToSpeechService {
  bool available = true;
  SpeakResult nextResult = const SpeakCompleted();
  Exception? throwOnSpeak;

  final List<String> spoken = [];
  int stopCalls = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<SpeakResult> speak(String text) async {
    final error = throwOnSpeak;
    if (error != null) throw error;
    spoken.add(text);
    return nextResult;
  }

  @override
  Future<void> stop() async => stopCalls++;
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
