/// The one thing for sale: every story, mission, quiz level and game,
/// unlocked for good. A one-time purchase, never a subscription.
const fullUnlockProductId = 'full_unlock';

/// What the store reports about the full unlock.
enum PurchaseEvent {
  /// Bought now, or found when restoring.
  owned,

  /// Waiting for payment, for example cash paid later at a shop.
  pending,

  /// The grown-up closed the payment sheet.
  cancelled,

  /// Something went wrong in the store.
  failed,
}

/// Talks to the app store. Only a grown-up reaches it, from the Parent Zone.
abstract interface class PurchaseService {
  /// Updates from the store, including purchases that finish after the app
  /// was closed (so start listening as early as possible).
  Stream<PurchaseEvent> get events;

  /// The price in the buyer's currency, as the store shows it, or null when
  /// the store cannot be reached.
  Future<String?> price();

  /// Opens the store's payment sheet. False when it could not be opened.
  Future<bool> buy();

  /// Asks the store for an earlier purchase. Found purchases arrive on
  /// [events]; when there is none, nothing arrives. False when the store
  /// cannot be reached.
  Future<bool> restore();

  void dispose();
}

/// For builds that are not from the store (testing on a phone): there is
/// nothing to buy, and nothing is locked anyway.
class NoStorePurchaseService implements PurchaseService {
  const NoStorePurchaseService();

  @override
  Stream<PurchaseEvent> get events => const Stream.empty();

  @override
  Future<String?> price() async => null;

  @override
  Future<bool> buy() async => false;

  @override
  Future<bool> restore() async => false;

  @override
  void dispose() {}
}
