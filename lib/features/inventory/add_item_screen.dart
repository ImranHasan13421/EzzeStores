import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'inventory_service.dart';
import 'item_model.dart';
import '../scanner/barcode_scanner.dart'; // Import your scanner!

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to read the text typed by the user
  final _barcodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController(text: '0'); // Default to 0
  final _minStockController = TextEditingController(text: '5'); // Default to 5

  bool _isSaving = false;

  @override
  void dispose() {
    _barcodeController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    // 1. Validate the form (checks if required fields are filled)
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // 2. Build the Model from the text fields
      final newItem = ItemModel(
        barcode: _barcodeController.text.trim(),
        name: _nameController.text.trim(),
        sellingPrice: double.parse(_priceController.text.trim()),
        currentStock: int.parse(_stockController.text.trim()),
        minStockLevel: int.parse(_minStockController.text.trim()),
      );

      // 3. Ask the Service to save it to Supabase
      await context.read<InventoryService>().addItem(newItem);

      // 4. Show success and go back to the previous screen
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // BARCODE ROW (Text Field + Scanner Button)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _barcodeController,
                    decoration: const InputDecoration(
                      labelText: 'Barcode',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  icon: const Icon(Icons.qr_code_scanner),
                  iconSize: 32,
                  onPressed: () async {
                    // Open the scanner!
                    final scannedCode = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BarcodeScanner()),
                    );

                    // If the user scanned something, put it in the text field
                    if (scannedCode != null) {
                      _barcodeController.text = scannedCode;
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ITEM NAME
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Item Name', border: OutlineInputBorder()),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // SELLING PRICE
            TextFormField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Selling Price (\$)', border: OutlineInputBorder()),
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // STOCK LEVELS (Row)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Initial Stock', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _minStockController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Min Stock Alert', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // SAVE BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: _isSaving ? null : _saveItem,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Item', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}