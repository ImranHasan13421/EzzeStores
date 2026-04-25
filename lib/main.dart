import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/database/supabase_config.dart';

void main() async {
  // Ensures Flutter engine is fully ready before running background tasks
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to your Supabase project
  await SupabaseConfig.initialize();

  runApp(const EzzeStoresApp());
}

class EzzeStoresApp extends StatelessWidget {
  const EzzeStoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // We will inject our PosService and InventoryService here soon!
        // For now, this is just a placeholder so the app runs without crashing.
        Provider(create: (_) => 'Placeholder'),
      ],
      child: MaterialApp(
        title: 'EzzeStores',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        // A temporary screen to prove it works
        home: const Scaffold(
          body: Center(
            child: Text(
              'EzzeStores Foundation Ready! 🚀\nDatabase Connected.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}