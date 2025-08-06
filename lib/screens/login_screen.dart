import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/language_provider.dart';
import '../utils/manual_localization.dart' show t;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/password_hash.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Auth state change is now handled globally in main.dart
  }

  @override
  void dispose() {
    _usernameOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode;
    setState(() => _isLoading = true);
    try {
      // Use a conditional check for the platform
      if (kIsWeb) {
        // For web, use the default authentication flow
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
        );
      } else {
        // For mobile, use the deep link redirect
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'jobpopp://auth-callback',
          authScreenLaunchMode: LaunchMode.externalApplication,
        );
      }
    } catch (error) {
      print('Google sign-in failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(t('signInWithGoogle', lang) + ' failed: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithPhone() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFD23F)),
      ),
    );
    try {
      final input = _usernameOrPhoneController.text.trim();
      final password = _passwordController.text.trim();
      // Try to find user by phone or username
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .or('phone.eq.$input,username.eq.$input')
          .maybeSingle();
      if (profile == null) {
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorDialog(t('noUserFound', lang));
        return;
      }
      // Check password (hash and compare)
      final hashedInput = hashPassword(password); // Use the same hash as signup
      if (profile['password'] != hashedInput) {
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorDialog(t('incorrectPassword', lang));
        return;
      }
      // Save phone to SharedPreferences for phone-only login
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone_login', profile['phone'] ?? input);
      // Success: Set Supabase session manually for phone-only users (if needed)
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushReplacementNamed(context, '/job_list');
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Phone login error: $e');
      _showErrorDialog("${t('loginFailed', lang)}: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    final lang = Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Text(t('loginFailed', lang)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('ok', lang)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context, rootNavigator: true)
          .popUntil((route) => route.isFirst);
      Navigator.pushReplacementNamed(
          context, '/'); // Assuming '/' is your main home route
    }
  }

  Future<void> _confirmAndLogout() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t('confirmLogout', lang)),
        content: Text(t('areYouSureLogout', lang)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(t('cancel', lang)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(t('logoutButton', lang)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale.languageCode;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          OutlinedButton(
            onPressed: () {
              final provider =
                  Provider.of<LanguageProvider>(context, listen: false);
              final current = provider.locale.languageCode;
              provider.setLocale(current == 'en' ? 'lg' : 'en');
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.black),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('EN | LG',
                style: GoogleFonts.montserrat(color: Colors.black)),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _confirmAndLogout,
            tooltip: t('logout', lang),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', height: 100),
                const SizedBox(height: 24),
                Text(t('login', lang),
                    style: GoogleFonts.montserrat(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.transparent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/google.png',
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(width: 12),
                      Text(t('signInWithGoogle', lang),
                          style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(t('loginWithPhone', lang),
                    style: GoogleFonts.montserrat(color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameOrPhoneController,
                        validator: (v) => v == null || v.isEmpty
                            ? t('usernameOrPhoneRequired', lang)
                            : null,
                        decoration: InputDecoration(
                          labelText: t('usernameOrPhone', lang),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (v) => v == null || v.isEmpty
                            ? t('passwordRequired', lang)
                            : null,
                        decoration: InputDecoration(
                          labelText: t('password', lang),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signInWithPhone,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(t('login', lang),
                              style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(t('forgotPassword', lang),
                      style: GoogleFonts.montserrat(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(t('createNewAccount', lang),
                      style: GoogleFonts.montserrat(color: Colors.blue)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
