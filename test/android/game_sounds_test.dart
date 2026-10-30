import 'dart:io';

import 'package:curious_buddy/domain/games/sound_game.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const raw = 'android/app/src/main/res/raw';
  final activity = File(
    'android/app/src/main/kotlin/io/github/e_hu_create/curiousbuddy/'
    'MainActivity.kt',
  ).readAsStringSync();
  final credits = File('docs/SOUNDS.md').readAsStringSync();

  for (final sound in GameSound.values) {
    test('${sound.name} has a short clip, loaded and credited', () {
      final clip = File('$raw/snd_${sound.name}.wav');
      expect(clip.existsSync(), isTrue);
      // About 4 seconds of 22 kHz mono, at most: clips stay small.
      expect(clip.lengthSync(), lessThan(180 * 1024));
      expect(clip.readAsBytesSync().sublist(0, 4), 'RIFF'.codeUnits);

      expect(activity, contains('R.raw.snd_${sound.name}'));
      expect(credits, contains('`snd_${sound.name}`'));
    });
  }
}
