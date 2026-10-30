import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Short sounds for good moments. [length] is how long each one plays, so
/// Buddy can wait for it before speaking.
enum SoundEffect {
  pop(Duration(milliseconds: 80)),
  correct(Duration(milliseconds: 500)),
  gentle(Duration(milliseconds: 460)),
  cheer(Duration(milliseconds: 870));

  const SoundEffect(this.length);

  final Duration length;
}

/// Plays sound effects. Must never throw: a child should not notice if a
/// sound cannot play. Completes when the sound has finished.
abstract interface class SoundEffectsService {
  Future<void> play(SoundEffect effect);

  /// Plays a recorded clip by name, replacing any clip still playing.
  Future<void> playClip(String name);

  Future<void> stopClip();
}

/// Plays the bundled sounds through Android's SoundPool (see MainActivity).
/// No package: only the app's own native channel.
class PlatformSoundEffectsService implements SoundEffectsService {
  static const _channel = MethodChannel('curious_buddy/sounds');

  @override
  Future<void> play(SoundEffect effect) async {
    try {
      await _channel.invokeMethod<void>('play', effect.name);
    } on PlatformException catch (error) {
      debugPrint('Sounds: could not play ${effect.name} ($error)');
      return;
    } on MissingPluginException {
      return;
    }
    await Future<void>.delayed(effect.length);
  }

  @override
  Future<void> playClip(String name) => _send('playClip', name);

  @override
  Future<void> stopClip() => _send('stopClip');

  Future<void> _send(String method, [String? name]) async {
    try {
      await _channel.invokeMethod<void>(method, name);
    } on PlatformException catch (error) {
      debugPrint('Sounds: could not $method ($error)');
    } on MissingPluginException {
      return;
    }
  }
}
