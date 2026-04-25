import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/database/supabase_config.dart';
import 'features/inventory/inventory_service.dart';
import 'features/inventory/inventory_screen.dart';


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
        // Inject the Inventory Service here!
        ChangeNotifierProvider(create: (_) => InventoryService()),
      ],
      child: MaterialApp(
        title: 'EzzeStores',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        // Set the InventoryScreen as the home screen!
        home: const InventoryScreen(),
      ),
    );
  }
}