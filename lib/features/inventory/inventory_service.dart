import 'package:flutter/material.dart';
import '../../core/database/supabase_config.dart';
import 'item_model.dart';


class InventoryService extends ChangeNotifier {
  final _db = SupabaseConfig.client;

  List<ItemModel> items = [];
  bool isLoading = false;

  InventoryService() {
    // Automatically load items when the service starts
    fetchItems();
  }

  Future<void> fetchItems() async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _db
          .from('EzzeStores_items')
          .select()
          .order('name', ascending: true);

      items = response.map((data) => ItemModel.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching items: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(ItemModel newItem) async {
    try {
      // Insert to Supabase using the toJson() method
      await _db.from('EzzeStores_items').insert(newItem.toJson());

      // Refresh the local list
      await fetchItems();
    } catch (e) {
      print('Error adding item: $e');
      rethrow; // Pass error to UI so we can show a SnackBar
    }
  }
}