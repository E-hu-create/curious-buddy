import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/services/key_value_store.dart';
import '../../data/services/purchase/purchase_service.dart';
import '../quiz/quiz.dart';
import 'free_content.dart';

/// Where buying or restoring has got to, for the Parent Zone.
enum UnlockStatus {
  idle,
  working,
  pending,
  cancelled,
  failed,
  notFound,
  storeUnavailable,
}

/// Whether the full app is unlocked, and the one-time purchase that
/// unlocks it. Saved on the phone as [key]. Locks only apply when [locksOn]
/// (builds from the store); test builds are fully open.
class AccessController extends ChangeNotifier {
  AccessController({
    required KeyValueStore store,
    required PurchaseService purchases,
    required this.locksOn,
    this.restoreWait = const Duration(seconds: 8),
  }) : _store = store,
       _purchases = purchases {
    _subscription = _purchases.events.listen(_onEvent);
  }

  static const key = 'unlock.full';

  final KeyValueStore _store;
  final PurchaseService _purchases;
  final bool locksOn;

  /// How long to wait for the store to report an earlier purchase. When
  /// there is none, the store says nothing at all.
  final Duration restoreWait;

  late final StreamSubscription<PurchaseEvent> _subscription;
  Timer? _restoreTimer;
  bool _disposed = false;

  bool get unlocked => _unlocked;
  bool _unlocked = false;

  UnlockStatus get status => _status;
  UnlockStatus _status = UnlockStatus.idle;

  /// The price as the store shows it, once loaded; null until then or when
  /// the store cannot be reached.
  String? get price => _price;
  String? _price;

  late final Future<void> ready = _load();

  Future<void> _load() async {
    try {
      _unlocked = await _store.read(key) == 'true';
    } on Exception {
      _unlocked = false;
    }
    _notify();
  }

  bool get _open => !locksOn || _unlocked;

  bool storyLocked(String id) => !_open && !FreeContent.storyIds.contains(id);
  bool missionLocked(String id) =>
      !_open && !FreeContent.missionIds.contains(id);
  bool gameLocked(String id) => !_open && !FreeContent.gameIds.contains(id);
  bool quizLevelLocked(QuizDifficulty difficulty) =>
      !_open && !FreeContent.quizLevel(difficulty);

  Future<void> loadPrice() async {
    _price = await _purchases.price();
    _notify();
  }

  Future<void> buy() async {
    _status = UnlockStatus.working;
    _notify();
    if (!await _purchases.buy()) {
      _status = UnlockStatus.storeUnavailable;
      _notify();
    }
    // Otherwise the result arrives as an event.
  }

  Future<void> restore() async {
    _status = UnlockStatus.working;
    _notify();
    if (!await _purchases.restore()) {
      _status = UnlockStatus.storeUnavailable;
      _notify();
      return;
    }
    _restoreTimer?.cancel();
    _restoreTimer = Timer(restoreWait, () {
      if (_status == UnlockStatus.working) {
        _status = UnlockStatus.notFound;
        _notify();
      }
    });
  }

  Future<void> _onEvent(PurchaseEvent event) async {
    _restoreTimer?.cancel();
    switch (event) {
      case PurchaseEvent.owned:
        _unlocked = true;
        _status = UnlockStatus.idle;
        try {
          await _store.write(key, 'true');
        } on Exception {
          // Still unlocked for this session; Restore brings it back.
        }
      case PurchaseEvent.pending:
        _status = UnlockStatus.pending;
      case PurchaseEvent.cancelled:
        _status = UnlockStatus.cancelled;
      case PurchaseEvent.failed:
        _status = UnlockStatus.failed;
    }
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _restoreTimer?.cancel();
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
