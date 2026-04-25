import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Replace these with your actual Supabase URL and Anon Key
  // You can find these in Supabase -> Project Settings -> API
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';

  /// Initializes the Supabase connection. Must be called in main.dart.
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  /// A global shortcut to easily access the database anywhere in your Services.
  static final client = Supabase.instance.client;
}