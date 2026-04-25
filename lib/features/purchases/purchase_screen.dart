import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'purchase_service.dart';
import 'purchase_model.dart';
import '../scanner/barcode_scanner.dart';
import '../inventory/inventory_service.dart'; // To refresh the list after buying!

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  final _costController = TextEditingController();
  final _paidController = TextEditingController(text: '0'); // Default to 0 paid

  @override
  void dispose() {
    _qtyController.dispose();
    _costController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restock Items')),
      body: Consumer<PurchaseService>(
        builder: (context, service, child) {

          // STATE 1: No item scanned yet
          if (service.scannedItemDetails == null) {
            return Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
                icon: const Icon(Icons.qr_code_scanner, size: 30),
                label: const Text('Scan Item to Restock', style: TextStyle(fontSize: 20)),
                onPressed: service.isProcessing ? null : () async {
                  final barcode = await Navigator.push(context, MaterialPageRoute(builder: (_) => const BarcodeScanner()));
                  if (barcode != null && context.mounted) {
                    final error = await service.lookupItem(barcode);
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                    }
                  }
                },
              ),
            );
          }

          // STATE 2: Item scanned, show the purchase form
          final item = service.scannedItemDetails!;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Display what we are restocking
                ListTile(
                  tileColor: Colors.blue.withOpacity(0.1),
                  leading: const Icon(Icons.inventory, color: Colors.blue),
                  title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('Current Stock: ${item['current_stock']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.grey),
                    onPressed: service.clearScannedItem,
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Quantity Bought', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Cost Bill (\$)', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _paidController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount Paid Upfront (\$)', border: OutlineInputBorder()),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
                  onPressed: service.isProcessing ? null : () async {
                    if (!_formKey.currentState!.validate()) return;

                    final purchase = PurchaseModel(
                      itemBarcode: item['barcode'],
                      quantityBought: int.parse(_qtyController.text),
                      totalCost: double.parse(_costController.text),
                      amountPaid: double.parse(_paidController.text),
                    );

                    final success = await service.recordPurchase(purchase, item['current_stock']);

                    if (success && context.mounted) {
                      // Refresh the inventory list in the background so it shows the new stock!
                      context.read<InventoryService>().fetchItems();

                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Restock Successful! 📦')));
                      Navigator.pop(context); // Go back to inventory
                    }
                  },
                  child: service.isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Purchase & Update Stock', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}