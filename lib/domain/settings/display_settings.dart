import 'package:flutter/foundation.dart';

import '../../data/services/key_value_store.dart';

/// Grown-up display settings for the whole app, saved on the device.
///
/// [reduceMotion] adds to the phone's own "remove animations" setting: if
/// either is on, Buddy stays still instead of waving and bouncing.
class DisplaySettings extends ChangeNotifier {
  DisplaySettings({required KeyValueStore settings}) : _settings = settings;

  static const reduceMotionKey = 'display.reduceMotion';

  final KeyValueStore _settings;
  bool _disposed = false;

  late final Future<void> ready = _init();

  bool get reduceMotion => _reduceMotion;
  bool _reduceMotion = false;

  Future<void> _init() async {
    try {
      _reduceMotion = await _settings.read(reduceMotionKey) == 'true';
    } on Exception {
      _reduceMotion = false;
    }
    _notify();
  }

  Future<void> setReduceMotion(bool reduce) async {
    await ready;
    if (reduce == _reduceMotion) return;
    _reduceMotion = reduce;
    _notify();
    try {
      await _settings.write(reduceMotionKey, '$reduce');
    } on Exception {
      // Applies for this session.
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
