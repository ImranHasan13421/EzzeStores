import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dashboard_service.dart';
import '../inventory/inventory_screen.dart';
import '../pos_sales/pos_screen.dart';
import '../purchases/purchase_screen.dart';
import '../../shared_widgets/app_drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Notice: No hardcoded background color here! The theme handles it.
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('EzzeStores Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        // Notice: We removed the hardcoded AppBar colors because main.dart handles them!
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardService>().loadDashboardData(),
          )
        ],
      ),
      body: Consumer<DashboardService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Business Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.3,
                children: [
                  _StatCard(title: 'Total Sales', value: '\$${service.totalSales.toStringAsFixed(2)}', icon: Icons.attach_money, color: Colors.green),
                  _StatCard(title: 'Supplier Dues', value: '\$${service.supplierDues.toStringAsFixed(2)}', icon: Icons.money_off, color: Colors.redAccent),
                  _StatCard(title: 'Total Items', value: service.totalItemsInInventory.toString(), icon: Icons.inventory_2, color: Colors.blue),
                  _StatCard(title: 'Low Stock Alerts', value: service.lowStockCount.toString(), icon: Icons.warning_amber_rounded, color: Colors.orange),
                ],
              ),

              const SizedBox(height: 32),
              const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              _ActionButton(
                title: 'New Sale (POS)',
                icon: Icons.point_of_sale,
                color: Colors.blueAccent,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PosScreen())),
              ),
              const SizedBox(height: 12),
              _ActionButton(
                title: 'Manage Inventory',
                icon: Icons.inventory,
                color: Colors.indigo,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryScreen())),
              ),
              const SizedBox(height: 12),
              _ActionButton(
                title: 'Restock / Purchases',
                icon: Icons.local_shipping,
                color: Colors.teal,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PurchaseScreen())),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --- REUSABLE UI WIDGETS ---

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    // We grab the current theme to know if we are in dark or light mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Use the theme's card color instead of hardcoded white!
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
                blurRadius: 10
            )
          ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const Spacer(),
          // Use theme text styles instead of hardcoded grey
          Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14)),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({required this.title, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          // Use the theme's card color here too!
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3))
        ),
        child: Row(
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color)
            ),
            const SizedBox(width: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: Theme.of(context).iconTheme.color?.withOpacity(0.5), size: 16),
          ],
        ),
      ),
    );
  }
}