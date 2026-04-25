import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_service.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.storefront, size: 100, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                const Text('Ezze Softwares', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const Text('Manage your retail business effortlessly.', textAlign: TextAlign.center),
                const SizedBox(height: 48),

                Consumer<AuthService>(
                  builder: (context, auth, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          // Button syncs with theme!
                          backgroundColor: Theme.of(context).cardColor,
                          foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                          elevation: 2,
                        ),
                        icon: auth.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Image.network('https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg', height: 24),
                        label: const Text('Sign in with Google', style: TextStyle(fontSize: 16)),
                        onPressed: auth.isLoading ? null : () async {
                          final error = await auth.signInWithGoogle();
                          if (error != null && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.redAccent));
                          } else if (context.mounted) {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}