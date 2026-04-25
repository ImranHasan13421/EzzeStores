import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pos_service.dart';
import '../scanner/barcode_scanner.dart';
import '../../shared_widgets/app_drawer.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('Checkout Cart', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Consumer<PosService>(
        builder: (context, service, child) {
          if (service.cart.isEmpty) {
            return const Center(child: Text('Scan an item to start a sale.', style: TextStyle(fontSize: 18)));
          }

          return ListView.builder(
            itemCount: service.cart.length,
            itemBuilder: (context, index) {
              final item = service.cart[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Card(
                  color: Theme.of(context).cardColor,
                  elevation: isDark ? 1 : 0.5,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left Side: Name and Price
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('\$${item.price.toStringAsFixed(2)} each',
                                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                            ],
                          ),
                        ),

                        // Middle: The Quantity Adjuster Widget
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () => service.updateQuantity(item.barcode, -1),
                              ),
                              Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () {
                                  final error = service.updateQuantity(item.barcode, 1);
                                  // Show an error if they try to buy more than we have!
                                  if (error != null && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),

                        // Right Side: Total Price and Delete Button
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${item.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.only(top: 8),
                              onPressed: () => service.removeItem(item.barcode),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                    color: isDark ? Colors.black45 : Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, -2)
                )
              ],
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
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan'),
                          onPressed: service.isProcessing ? null : () async {
                            final scannedCode = await Navigator.push(context, MaterialPageRoute(builder: (_) => const BarcodeScanner()));
                            if (scannedCode != null && context.mounted) {
                              final error = await context.read<PosService>().scanItemToCart(scannedCode);
                              if (error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: service.cart.isEmpty || service.isProcessing ? null : () async {
                            final success = await context.read<PosService>().checkout();
                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sale Complete! 🧾')));
                            }
                          },
                          child: service.isProcessing
                              ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
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