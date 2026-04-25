import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Add this

class SupabaseConfig {
  /// Initializes the Supabase connection using secure environment variables.
  static Future<void> initialize() async {
    // Read the values safely from the .env file
    final String url = dotenv.env['SUPABASE_URL'] ?? '';
    final String anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('Missing Supabase URL or Anon Key in .env file');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
  }

  static final client = Supabase.instance.client;
}