import 'dart:async';

import 'package:curious_buddy/data/services/voice/recorded_voice_service.dart';
import 'package:curious_buddy/data/services/voice/text_to_speech_service.dart';
import 'package:curious_buddy/domain/voice/voice_clips.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../testing/fakes.dart';

class FakeClipPlayer implements ClipPlayer {
  final played = <String>[];
  final speeds = <double>[];
  int stops = 0;
  bool fail = false;
  Completer<bool>? hold;

  @override
  Future<bool> play(String clip, {required double speed}) async {
    if (fail) throw PlatformException(code: 'voice');
    played.add(clip);
    speeds.add(speed);
    return hold?.future ?? true;
  }

  @override
  Future<void> stop() async {
    stops++;
    hold?.complete(false);
    hold = null;
  }
}

void main() {
  late FakeClipPlayer player;
  late FakeTextToSpeechService fallback;

  setUp(() {
    player = FakeClipPlayer();
    fallback = FakeTextToSpeechService();
  });

  RecordedVoiceService build(Iterable<String> recorded) => RecordedVoiceService(
    fallback: fallback,
    player: player,
    loadIndex: () async => {for (final s in recorded) VoiceClips.name(s)},
  );

  group('sentences', () {
    test('splits sentences and keeps titles and quotes whole', () {
      expect(VoiceClips.sentences('Hello there. How are you? Fine!'), [
        'Hello there.',
        'How are you?',
        'Fine!',
      ]);
      expect(VoiceClips.sentences('Dr. Ravi took the key.'), [
        'Dr. Ravi took the key.',
      ]);
      expect(VoiceClips.sentences('"Wow!" said Tessa. "Look!"'), [
        '"Wow!" said Tessa.',
        '"Look!"',
      ]);
      expect(VoiceClips.sentences('A T. rex ate well.'), [
        'A T. rex ate well.',
      ]);
    });

    test('names are stable, and differ between sentences', () {
      expect(VoiceClips.name('Hello.'), VoiceClips.name('Hello.'));
      expect(VoiceClips.name('Hello.'), isNot(VoiceClips.name('Hello!')));
      expect(VoiceClips.name('Hello.'), hasLength(16));
    });
  });

  test('plays each recorded sentence in order', () async {
    final service = build(['One here.', 'Two here.']);

    expect(await service.speak('One here. Two here.'), isA<SpeakCompleted>());

    expect(player.played, [
      VoiceClips.name('One here.'),
      VoiceClips.name('Two here.'),
    ]);
    expect(fallback.spoken, isEmpty);
  });

  test('a line with any unrecorded sentence uses the phone voice', () async {
    final service = build(['One here.']);

    await service.speak('One here. Not recorded.');

    expect(player.played, isEmpty);
    expect(fallback.spoken, ['One here. Not recorded.']);
  });

  test('a clip that cannot play falls back to the phone voice', () async {
    player.fail = true;
    final service = build(['One here.']);

    await service.speak('One here.');

    expect(fallback.spoken, ['One here.']);
  });

  test('stop ends the line and plays no more sentences', () async {
    final service = build(['One here.', 'Two here.']);
    player.hold = Completer<bool>();

    final line = service.speak('One here. Two here.');
    await pumpEventQueue();
    await service.stop();

    expect(await line, isA<SpeakInterrupted>());
    expect(player.played, hasLength(1));
  });

  test('the speed slider reaches the clips and the phone voice', () async {
    final service = build(['One here.']);

    await service.setSpeed(SpeechSpeed.slowest);
    await service.speak('One here.');

    expect(player.speeds, [SpeechSpeed.slowest.factor]);
    expect(fallback.speed, SpeechSpeed.slowest);
  });

  test('with no recordings at all, the phone voice still works', () async {
    final service = RecordedVoiceService(
      fallback: fallback,
      player: player,
      loadIndex: () async => throw Exception('no index'),
    );

    expect(await service.isAvailable(), isTrue);
    await service.speak('Hello there.');

    expect(fallback.spoken, ['Hello there.']);
  });
}
