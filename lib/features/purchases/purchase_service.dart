import 'package:flutter/material.dart';
import '../../core/database/supabase_config.dart';
import 'purchase_model.dart';

class PurchaseService extends ChangeNotifier {
  final _db = SupabaseConfig.client;

  bool isProcessing = false;
  Map<String, dynamic>? scannedItemDetails;

  /// 1. Scan item to verify it exists in inventory before buying
  Future<String?> lookupItem(String barcode) async {
    isProcessing = true;
    notifyListeners();

    try {
      final response = await _db
          .from('EzzeStores_items')
          .select()
          .eq('barcode', barcode)
          .maybeSingle();

      if (response == null) {
        scannedItemDetails = null;
        return "Item not found! Add it to Inventory first.";
      }

      scannedItemDetails = response;
      return null; // Success!
    } catch (e) {
      return "Error: $e";
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  /// 2. Record the purchase and increase stock
  Future<bool> recordPurchase(PurchaseModel purchase, int currentStock) async {
    isProcessing = true;
    notifyListeners();

    try {
      // Step A: Insert the bill into purchases table
      await _db.from('EzzeStores_purchases').insert(purchase.toJson());

      // Step B: Increase the stock in the items table
      final newStockLevel = currentStock + purchase.quantityBought;
      await _db.from('EzzeStores_items')
          .update({'current_stock': newStockLevel})
          .eq('barcode', purchase.itemBarcode);

      // Clear the scanned item so the screen resets
      scannedItemDetails = null;
      return true;
    } catch (e) {
      print('Purchase Error: $e');
      return false;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  // Clear the screen if the user cancels
  void clearScannedItem() {
    scannedItemDetails = null;
    notifyListeners();
  }
}