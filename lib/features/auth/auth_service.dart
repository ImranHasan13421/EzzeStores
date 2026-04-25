import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart' as gauth;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/database/supabase_config.dart';

class AuthService extends ChangeNotifier {
  final _db = SupabaseConfig.client;
  bool isLoading = false;

  // Check if a user is currently logged in
  User? get currentUser => _db.auth.currentUser;

  /// Google Sign In Logic
  Future<String?> signInWithGoogle() async {
    isLoading = true;
    notifyListeners();

    try {
      // 1. Read the Client ID safely from the .env file
      final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';

      if (webClientId.isEmpty) {
        return "Missing Google Client ID in .env file.";
      }

      // 2. Initialize Google Sign In with the secure key
      final gauth.GoogleSignIn googleSignIn = gauth.GoogleSignIn(
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return "Sign in aborted."; // User canceled
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        return "Missing Google Auth Tokens.";
      }

      // 3. Pass the tokens to Supabase
      await _db.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return null; // Success!
    } catch (e) {
      return "Error signing in: $e";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Sign Out Logic
  Future<void> signOut() async {
    await _db.auth.signOut();
    await gauth.GoogleSignIn().signOut();
    notifyListeners();
  }
}