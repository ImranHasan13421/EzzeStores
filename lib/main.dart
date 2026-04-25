import 'package:ezze_stores/features/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// --- Core Database & Theme ---
import 'core/database/supabase_config.dart';
import 'core/theme/theme_provider.dart';

// --- Services (The Brains) ---
import 'features/auth/auth_service.dart';
import 'features/inventory/inventory_service.dart';
import 'features/pos_sales/pos_service.dart';
import 'features/purchases/purchase_service.dart';
import 'features/dashboard/dashboard_service.dart';

// --- Screens ---
import 'features/auth/login_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  // 1. Ensure Flutter engine is fully ready before running background tasks
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load secure environment variables (.env file)
  await dotenv.load(fileName: ".env");

  // 3. Initialize connection to Supabase
  await SupabaseConfig.initialize();

  // 4. Start the App
  runApp(const EzzeStoresApp());
}

class EzzeStoresApp extends StatelessWidget {
  const EzzeStoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider injects all our Services so any screen can access them
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => InventoryService()),
        ChangeNotifierProvider(create: (_) => PosService()),
        ChangeNotifierProvider(create: (_) => PurchaseService()),
        ChangeNotifierProvider(create: (_) => DashboardService()),
      ],
      // We wrap the app in a Consumer so it instantly repaints when the Theme changes
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'EzzeStores',
            debugShowCheckedModeBanner: false,

            // --- Theme Setup ---
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueAccent,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blueAccent,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
              ),
            ),

            // --- Routing Logic ---
            // If the user is logged in, show the Dashboard.
            // If they are logged out, force them to the Login Screen.
            home: Consumer<AuthService>(
              builder: (context, auth, child) {
                // If currentUser is NOT null, they are logged in!
                if (auth.currentUser != null) {
                  return const SplashScreen();
                }
                // Otherwise, show them the login gate.
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}