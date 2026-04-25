import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'inventory_service.dart';
import 'add_item_screen.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        centerTitle: true,
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
                leading: const CircleAvatar(child: Icon(Icons.inventory_2)),
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
                        color: needsRestock ? Colors.red : Colors.green,
                      ),
                    ),
                    if (needsRestock)
                      const Text('Low Stock!', style: TextStyle(color: Colors.red, fontSize: 10)),
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
          // Navigate to the new form!
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddItemScreen()),
          );
        },
      ),
    );
  }
}