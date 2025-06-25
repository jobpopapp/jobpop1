import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider;

class LoginScreen extends StatelessWidget {
  final VoidCallback? onToggleLanguage;
  const LoginScreen({super.key, this.onToggleLanguage});

  Future<void> _signInWithGoogle(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo:
            'io.supabase.flutterdemo://login-callback', // Set this in your Supabase redirect URLs
      );
    } catch (error) {
      print('Google sign-in failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          OutlinedButton(
            onPressed: onToggleLanguage,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('EN | LG',
                style: GoogleFonts.montserrat(color: Colors.black)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 48),
            Image.asset('assets/logo.png', height: 150),
            const SizedBox(height: 32),
            Text('LOGIN',
                style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            const SizedBox(height: 32),

            // Primary Option: Google Login
            SizedBox(
              width: double.infinity,
              child: SizedBox(
                width: 200, // Match the width of the image
                child: OutlinedButton.icon(
                  icon: Image.asset(
                    'assets/google.png',
                    height: 36,
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  label: const SizedBox.shrink(), // No text label
                  onPressed: () => _signInWithGoogle(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: BorderSide(color: Colors.transparent, width: 2),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Text('or login with phone',
                style: GoogleFonts.montserrat(color: Colors.grey.shade600)),
            const SizedBox(height: 24),

            // Secondary Option: Phone/Username Login
            TextField(
              decoration: InputDecoration(
                labelText: 'Username / Phone *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {},
                child: Text('LOGIN',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),

            const SizedBox(height: 12),
            TextButton(
              onPressed: () {},
              child: Text('Forgot Password?',
                  style: GoogleFonts.montserrat(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Create New Account',
                  style: GoogleFonts.montserrat(color: Colors.blue)),
            ),

            const SizedBox(height: 40),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.home, size: 30, color: Colors.black),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
