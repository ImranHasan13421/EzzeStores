import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/database/supabase_config.dart';
import 'features/inventory/inventory_service.dart';
import 'features/inventory/inventory_screen.dart';
import 'features/pos_sales/pos_service.dart';
import 'features/purchases/purchase_service.dart';
import 'features/dashboard/dashboard_service.dart';
import 'features/dashboard/dashboard_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the environment variables FIRST
  await dotenv.load(fileName: ".env");

  // Then initialize Supabase
  await SupabaseConfig.initialize();

  runApp(const EzzeStoresApp());
}

class EzzeStoresApp extends StatelessWidget {
  const EzzeStoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => InventoryService()),
        ChangeNotifierProvider(create: (_) => PosService()),
        ChangeNotifierProvider(create: (_) => PurchaseService()),
        ChangeNotifierProvider(create: (_) => DashboardService()), // <-- Add this!
      ],
      child: MaterialApp(
        title: 'EzzeStores',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        // Change the home screen to the Dashboard!
        home: const DashboardScreen(),
      ),
    );
  }
}