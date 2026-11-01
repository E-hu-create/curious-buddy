import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../domain/voice/voice_clips.dart';
import 'text_to_speech_service.dart';

/// Plays one recorded clip. Answers true when it finished, false when it was
/// stopped. Throws when it cannot play.
abstract interface class ClipPlayer {
  Future<bool> play(String clip, {required double speed});
  Future<void> stop();
}

/// The Android player in MainActivity.kt.
class PlatformClipPlayer implements ClipPlayer {
  const PlatformClipPlayer();

  static const _channel = MethodChannel('curious_buddy/voice');

  @override
  Future<bool> play(String clip, {required double speed}) async =>
      await _channel.invokeMethod<bool>('play', {
        'asset': 'assets/voice/$clip.m4a',
        'speed': speed,
      }) ??
      false;

  @override
  Future<void> stop() => _channel.invokeMethod<void>('stop');
}

/// Buddy's recorded voice. Reviewed lines were recorded once, sentence by
/// sentence, and ship inside the app, so they play offline. A line with any
/// sentence not recorded (such as a Story Maker story, whose names change)
/// uses [fallback], the phone's own voice, for the whole line.
class RecordedVoiceService implements TextToSpeechService {
  RecordedVoiceService({
    required this.fallback,
    ClipPlayer player = const PlatformClipPlayer(),
    Future<Set<String>> Function()? loadIndex,
  }) : _player = player,
       _loadIndex = loadIndex ?? _bundledIndex;

  final TextToSpeechService fallback;
  final ClipPlayer _player;
  final Future<Set<String>> Function() _loadIndex;

  late final Future<Set<String>> _index = _safeIndex();
  SpeechSpeed _speed = SpeechSpeed.normal;

  /// Bumped by each [speak] and [stop], so a stopped line plays no more
  /// sentences.
  int _generation = 0;

  static Future<Set<String>> _bundledIndex() async {
    final text = await rootBundle.loadString('assets/voice/index.txt');
    return text.split('\n').map((l) => l.trim()).toSet()..remove('');
  }

  Future<Set<String>> _safeIndex() async {
    try {
      return await _loadIndex();
    } on Exception catch (error) {
      debugPrint('Voice: no recordings ($error)');
      return const {};
    } on FlutterError catch (error) {
      debugPrint('Voice: no recordings ($error)');
      return const {};
    }
  }

  @override
  Future<bool> isAvailable() async =>
      (await _index).isNotEmpty || await fallback.isAvailable();

  @override
  Future<SpeakResult> speak(String text) async {
    final generation = ++_generation;
    final index = await _index;
    final clips = [
      for (final sentence in VoiceClips.sentences(text))
        VoiceClips.name(sentence),
    ];
    if (clips.isEmpty || !clips.every(index.contains)) {
      final missing = clips.where((c) => !index.contains(c)).length;
      debugPrint(
        'Voice: phone voice, $missing of ${clips.length} not recorded',
      );
      return fallback.speak(text);
    }
    debugPrint('Voice: recorded, ${clips.length} sentences');
    for (final clip in clips) {
      if (generation != _generation) return const SpeakInterrupted();
      try {
        final finished = await _player.play(clip, speed: _speed.factor);
        if (!finished) return const SpeakInterrupted();
      } on Exception catch (error) {
        debugPrint('Voice: could not play $clip ($error)');
        if (generation != _generation) return const SpeakInterrupted();
        return fallback.speak(text);
      }
    }
    return generation == _generation
        ? const SpeakCompleted()
        : const SpeakInterrupted();
  }

  @override
  Future<void> stop() async {
    _generation++;
    try {
      await _player.stop();
    } on Exception catch (error) {
      debugPrint('Voice: could not stop ($error)');
    }
    await fallback.stop();
  }

  @override
  Future<void> setSpeed(SpeechSpeed speed) async {
    _speed = speed;
    await fallback.setSpeed(speed);
  }
}
