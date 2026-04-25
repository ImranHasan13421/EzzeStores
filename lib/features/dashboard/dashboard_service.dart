import 'package:flutter/material.dart';
import '../../core/database/supabase_config.dart';

class DashboardService extends ChangeNotifier {
  final _db = SupabaseConfig.client;

  bool isLoading = true;

  double totalSales = 0.0;
  double supplierDues = 0.0;
  int lowStockCount = 0;
  int totalItemsInInventory = 0;

  DashboardService() {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. Calculate Total Sales
      final salesData = await _db.from('EzzeStores_sales').select('total_amount');
      totalSales = salesData.fold(0.0, (sum, item) => sum + (item['total_amount'] as num).toDouble());

      // 2. Calculate Supplier Dues (What you owe)
      final purchaseData = await _db.from('EzzeStores_purchases').select('amount_due');
      supplierDues = purchaseData.fold(0.0, (sum, item) => sum + (item['amount_due'] as num).toDouble());

      // 3. Calculate Inventory Metrics
      final inventoryData = await _db.from('EzzeStores_items').select('current_stock, min_stock_level');
      totalItemsInInventory = inventoryData.length;

      // Count how many items are below their minimum stock level
      lowStockCount = inventoryData.where((item) {
        final stock = item['current_stock'] as int;
        final minStock = item['min_stock_level'] as int;
        return stock <= minStock;
      }).length;

    } catch (e) {
      print('Error loading dashboard: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}