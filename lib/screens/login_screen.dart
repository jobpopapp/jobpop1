import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show OAuthProvider;

class LoginScreen extends StatefulWidget {
  final VoidCallback? onToggleLanguage;
  const LoginScreen({super.key, this.onToggleLanguage});

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
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null) {
        if (mounted) {
          Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst);
          Navigator.pushReplacementNamed(context, '/job_list');
        }
      }
    });
  }

  @override
  void dispose() {
    _usernameOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://jobpop.web.app/#/login',
      );
    } catch (error) {
      print('Google sign-in failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $error')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithPhone() async {
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
        _showErrorDialog('No user found with that phone or username.');
        return;
      }
      // Check password (hash and compare)
      final hashedInput =
          password; // TODO: hashPassword(password) if used in signup
      if (profile['password'] != hashedInput) {
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorDialog('Incorrect password.');
        return;
      }
      // Success: Navigate to job list
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushReplacementNamed(context, '/job_list');
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Phone login error: $e');
      _showErrorDialog('Login failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Login Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          OutlinedButton(
            onPressed: widget.onToggleLanguage,
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
            tooltip: 'Logout',
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
                Text('Login',
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
                  child: Image.asset(
                    'assets/google.png',
                    height: 40,
                    width: 250,
                  ),
                ),
                const SizedBox(height: 16),
                Text('or login with phone',
                    style: GoogleFonts.montserrat(color: Colors.grey.shade600)),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _usernameOrPhoneController,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Username or phone required'
                            : null,
                        decoration: InputDecoration(
                          labelText: 'Username / Phone *',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Password required' : null,
                        decoration: InputDecoration(
                          labelText: 'Password *',
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
                          child: Text('LOGIN',
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
                  child: Text('Forgot Password?',
                      style: GoogleFonts.montserrat(color: Colors.blue)),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Create New Account',
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
