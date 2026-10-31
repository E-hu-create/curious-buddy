import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'purchase_service.dart';

/// Google Play Billing, through the official in_app_purchase plugin.
///
/// Not unit-tested (needs Google Play on a phone); kept as thin as possible.
/// Purchases are checked on the phone only: the app has no server.
class PlayPurchaseService implements PurchaseService {
  PlayPurchaseService({InAppPurchase? store})
    : _store = store ?? InAppPurchase.instance {
    _subscription = _store.purchaseStream.listen(
      _onUpdates,
      onError: (Object error) {
        debugPrint('Purchases: stream error ($error)');
        _events.add(PurchaseEvent.failed);
      },
    );
  }

  final InAppPurchase _store;
  final _events = StreamController<PurchaseEvent>.broadcast();
  late final StreamSubscription<List<PurchaseDetails>> _subscription;
  ProductDetails? _product;

  @override
  Stream<PurchaseEvent> get events => _events.stream;

  Future<ProductDetails?> _load() async {
    if (_product != null) return _product;
    try {
      if (!await _store.isAvailable()) return null;
      final response = await _store.queryProductDetails({fullUnlockProductId});
      return _product = response.productDetails.firstOrNull;
    } on Exception catch (error) {
      debugPrint('Purchases: could not load the product ($error)');
      return null;
    }
  }

  @override
  Future<String?> price() async => (await _load())?.price;

  @override
  Future<bool> buy() async {
    final product = await _load();
    if (product == null) return false;
    try {
      // Non-consumable: bought once, owned for good, restorable.
      return await _store.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
    } on Exception catch (error) {
      debugPrint('Purchases: could not start ($error)');
      return false;
    }
  }

  @override
  Future<bool> restore() async {
    try {
      if (!await _store.isAvailable()) return false;
      await _store.restorePurchases();
      return true;
    } on Exception catch (error) {
      debugPrint('Purchases: could not restore ($error)');
      return false;
    }
  }

  Future<void> _onUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != fullUnlockProductId) continue;
      _events.add(switch (purchase.status) {
        PurchaseStatus.purchased || PurchaseStatus.restored => .owned,
        PurchaseStatus.pending => .pending,
        PurchaseStatus.canceled => .cancelled,
        PurchaseStatus.error => .failed,
      });
      // Google refunds purchases that are not acknowledged within three
      // days, so always complete them.
      if (purchase.pendingCompletePurchase) {
        try {
          await _store.completePurchase(purchase);
        } on Exception catch (error) {
          debugPrint('Purchases: could not complete ($error)');
        }
      }
    }
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    unawaited(_events.close());
  }
}
