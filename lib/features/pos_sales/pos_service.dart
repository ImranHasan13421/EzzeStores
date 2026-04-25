import 'package:flutter/material.dart';
import '../../core/database/supabase_config.dart';
import 'sale_model.dart';

class PosService extends ChangeNotifier {
  final _db = SupabaseConfig.client;

  List<CartItem> cart = [];
  bool isProcessing = false;

  // Automatically calculates the cart total
  double get cartTotal => cart.fold(0, (sum, item) => sum + item.totalPrice);

  /// 1. Scan an item and add it to the cart
  Future<String?> scanItemToCart(String scannedBarcode) async {
    // Check if it's already in the cart
    final existingIndex = cart.indexWhere((item) => item.barcode == scannedBarcode);

    if (existingIndex >= 0) {
      // It's in the cart. Check if we have enough stock to add another one.
      if (cart[existingIndex].quantity < cart[existingIndex].maxStock) {
        cart[existingIndex].quantity++;
        notifyListeners();
        return null; // Success
      } else {
        return "Not enough stock!";
      }
    }

    // It's not in the cart. Let's fetch it from Supabase.
    try {
      final response = await _db
          .from('EzzeStores_items')
          .select()
          .eq('barcode', scannedBarcode)
          .maybeSingle(); // Gets one item or null

      if (response == null) return "Item not found in inventory!";
      if (response['current_stock'] <= 0) return "Item is out of stock!";

      // Add to cart
      cart.add(CartItem(
        barcode: response['barcode'],
        name: response['name'],
        price: (response['selling_price'] as num).toDouble(),
        maxStock: response['current_stock'],
      ));

      notifyListeners();
      return null; // Success
    } catch (e) {
      return "Error fetching item: $e";
    }
  }

  /// 2. Remove item from cart
  void removeItem(String barcode) {
    cart.removeWhere((item) => item.barcode == barcode);
    notifyListeners();
  }

  /// 3. Process Checkout
  Future<bool> checkout() async {
    if (cart.isEmpty) return false;

    isProcessing = true;
    notifyListeners();

    try {
      // Generate a simple random receipt number (e.g., INV-16823901)
      final receiptNo = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      // 1. Create the Sale record
      final saleResponse = await _db.from('EzzeStores_sales').insert({
        'receipt_number': receiptNo,
        'total_amount': cartTotal,
      }).select('id').single();

      final saleId = saleResponse['id'];

      // 2. Loop through the cart to save sale items AND update stock
      for (var item in cart) {
        // Insert into sale_items table
        await _db.from('EzzeStores_sale_items').insert({
          'sale_id': saleId,
          'item_barcode': item.barcode,
          'quantity_sold': item.quantity,
          'price_at_sale': item.price,
        });

        // Decrement stock in items table
        await _db.from('EzzeStores_items')
            .update({'current_stock': item.maxStock - item.quantity})
            .eq('barcode', item.barcode);
      }

      // 3. Clear cart after successful checkout
      cart.clear();
      return true;

    } catch (e) {
      print('Checkout Error: $e');
      return false;
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }
}