import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'inventory_service.dart';
import 'add_item_screen.dart';
import '../../shared_widgets/app_drawer.dart'; // <-- Added Drawer Import

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), // <-- Added Drawer
      appBar: AppBar(
        title: const Text('Inventory', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<InventoryService>(
        builder: (context, service, child) {
          if (service.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (service.items.isEmpty) {
            return const Center(child: Text('No items in inventory. Add some!'));
          }

          return ListView.builder(
            itemCount: service.items.length,
            itemBuilder: (context, index) {
              final item = service.items[index];
              final needsRestock = item.currentStock <= item.minStockLevel;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.inventory_2, color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Barcode: ${item.barcode} | Price: \$${item.sellingPrice.toStringAsFixed(2)}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Stock: ${item.currentStock}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // Semantic colors like red/green work in both themes
                        color: needsRestock ? Colors.redAccent : Colors.green,
                      ),
                    ),
                    if (needsRestock)
                      const Text('Low Stock!', style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
      ),
    );
  }
}