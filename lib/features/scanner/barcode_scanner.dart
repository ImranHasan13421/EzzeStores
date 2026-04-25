import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  // The controller gives us access to the flashlight and camera switching
  MobileScannerController cameraController = MobileScannerController();

  // A safety flag so we only capture the code ONCE per scan
  bool _isScanned = false;

  @override
  void dispose() {
    // Always dispose controllers to save battery and memory!
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          // Flashlight Toggle Button
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController, // <-- CHANGED: Now listening to the whole controller
              builder: (context, state, child) {
                // <-- CHANGED: We now access torchState from the main state object
                if (state.torchState == TorchState.on) {
                  return const Icon(Icons.flash_on, color: Colors.yellow);
                }
                return const Icon(Icons.flash_off, color: Colors.grey);
              },
            ),
            onPressed: () => cameraController.toggleTorch(),
          ),
          // Switch Camera Button (Front/Back)
          IconButton(
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      // The actual camera viewfinder
      body: MobileScanner(
        controller: cameraController,
        onDetect: (capture) {
          // If we already scanned something, ignore the rest
          if (_isScanned) return;

          final List<Barcode> barcodes = capture.barcodes;

          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              _isScanned = true; // Lock it down

              final String scannedCode = barcode.rawValue!;

              // Vibrate or beep here if you want extra feedback!

              // Close the camera screen and send the code back to the app
              Navigator.pop(context, scannedCode);
              break;
            }
          }
        },
      ),
    );
  }
}