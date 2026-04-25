import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pos_service.dart';
import '../scanner/barcode_scanner.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Cart')),
      body: Consumer<PosService>(
        builder: (context, service, child) {
          if (service.cart.isEmpty) {
            return const Center(child: Text('Scan an item to start a sale.', style: TextStyle(fontSize: 18)));
          }

          return ListView.builder(
            itemCount: service.cart.length,
            itemBuilder: (context, index) {
              final item = service.cart[index];
              return ListTile(
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Qty: ${item.quantity}  |  \$${item.price.toStringAsFixed(2)} each'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => service.removeItem(item.barcode),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<PosService>(
        builder: (context, service, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total:', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text('\$${service.cartTotal.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // SCAN BUTTON
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan'),
                          onPressed: service.isProcessing ? null : () async {
                            final scannedCode = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const BarcodeScanner()),
                            );

                            if (scannedCode != null && context.mounted) {
                              final error = await context.read<PosService>().scanItemToCart(scannedCode);
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // CHECKOUT BUTTON
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: service.cart.isEmpty || service.isProcessing ? null : () async {
                            final success = await context.read<PosService>().checkout();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale Complete! 🧾')));
                            }
                          },
                          child: service.isProcessing
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}