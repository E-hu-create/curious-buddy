import 'package:flutter/foundation.dart';

import '../../data/repositories/progress_repository.dart';
import 'wardrobe.dart';

/// What Buddy is wearing, for the whole app: one instance, owned by the app
/// root, so every Buddy on every screen matches. Saved with the child's
/// progress on the device, so Delete all progress clears it.
class BuddyWardrobe extends ChangeNotifier {
  BuddyWardrobe({required ProgressRepository progressRepository})
    : _progress = progressRepository;

  final ProgressRepository _progress;
  bool _disposed = false;

  BuddyLook get look => _look;
  BuddyLook _look = BuddyLook.none;

  /// Reads the saved look. Safe to call again (e.g. after a reset). If
  /// storage fails, Buddy simply wears nothing.
  Future<void> load() async {
    try {
      final saved = await _progress.load();
      _look = BuddyLook.fromSaved(saved.buddyLook);
    } on Exception {
      _look = BuddyLook.none;
    }
    _notify();
  }

  Future<void> wear(WardrobeItem item) => _set(_look.wearing(item));

  Future<void> takeOff(WardrobeSlot slot) => _set(_look.without(slot));

  Future<void> _set(BuddyLook look) async {
    if (look == _look) return;
    _look = look;
    _notify();
    try {
      final saved = await _progress.load();
      await _progress.save(saved.copyWith(buddyLook: look.toSaved()));
    } on Exception {
      // Buddy still wears it for this session.
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
