import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/password_hash.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback? onToggleLanguage;
  const SignupScreen({super.key, this.onToggleLanguage});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String selectedCountry = 'UG';
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Hold latest signup form values for use in onAuthStateChange
  String? _pendingFullName;
  String? _pendingUsername;
  String? _pendingCountry;
  String? _pendingPhone;
  String? _pendingEmail;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone required';
    final phonePattern = RegExp(r'^0[7][0-9]{8}');
    if (!phonePattern.hasMatch(value)) {
      return 'Enter phone in 07XXXXXXXX format';
    }
    return null;
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    // Store latest values for use in onAuthStateChange
    _pendingFullName = _fullNameController.text.trim();
    _pendingUsername = _usernameController.text.trim();
    _pendingCountry = selectedCountry;
    _pendingPhone = _phoneController.text.trim();
    _pendingEmail = _emailController.text.trim();
    final email = _pendingEmail!;
    if (email.isNotEmpty) {
      // Show Google signup confirmation dialog
      final proceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Sign up with Google'),
          content: const Text(
              'You entered an email. Please sign up with Google to continue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continue with Google'),
            ),
          ],
        ),
      );
      if (proceed == true) {
        await _signUpWithGoogleAndProfile();
      }
      return;
    }
    // No email, proceed with phone-only profile logic
    await _signupPhoneOnlyProfile();
  }

  Future<void> _signupPhoneOnlyProfile() async {
    setState(() => _isLoading = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD23F))), // Yellow
    );
    try {
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();
      final fullName = _fullNameController.text.trim();
      final country = selectedCountry;
      // Check if user exists
      final existing = await Supabase.instance.client
          .from('profiles')
          .select('id')
          .eq('phone', phone)
          .maybeSingle();
      if (existing != null) {
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorDialog('A user with this phone number already exists.');
        return;
      }
      // Hash password before storing
      final hashedPassword = hashPassword(password);
      // Insert new profile WITHOUT id, so DB generates UUID
      final response = await Supabase.instance.client.from('profiles').insert({
        'full_name': fullName,
        'country': country,
        'username': username,
        'phone': phone,
        'password': hashedPassword,
      });
      print('Inserted profile: $response');
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushReplacementNamed(context, '/job_list');
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Phone-only signup error: $e');
      _showErrorDialog('Failed to signup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _signupWithPasswordAndProfile() async {
    setState(() => _isLoading = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFFFD23F)),
            SizedBox(height: 16),
            Text('Creating Account...',
                style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
    try {
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();
      final username = _usernameController.text.trim();
      final fullName = _fullNameController.text.trim();
      final country = selectedCountry;
      final response = await Supabase.instance.client.auth.signUp(
        email: email.isNotEmpty ? email : null,
        phone: phone.isNotEmpty ? phone : null,
        password: password,
      );
      final user = response.user;
      if (user != null && user.id.isNotEmpty) {
        final hashedPassword = hashPassword(password);
        final profileData = {
          'id': user.id,
          'full_name': fullName,
          'country': country,
          'username': username,
          'phone': phone,
          'email': user.email ?? email,
          'password': hashedPassword,
        };
        print('--- Profile data to be saved for auth user ---');
        profileData.forEach((k, v) => print('$k: $v'));
        await Supabase.instance.client.from('profiles').insert(profileData);
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.pushReplacementNamed(context, '/job_list');
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        _showErrorDialog('Signup failed. User ID not returned.');
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Signup error: $e');
      _showErrorDialog('Failed to signup: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Add this to listen for auth state changes and handle Google profile upsert after redirect
  @override
  void initState() {
    super.initState();
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedIn && session != null) {
        await Future.delayed(
            const Duration(seconds: 2)); // Wait for user to be available
        final user = session.user;
        // Check if profile exists
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        if (profile == null) {
          // Use pending values if available, else fallback to controllers
          final username = _pendingUsername ?? _usernameController.text.trim();
          final fullName = _pendingFullName ?? _fullNameController.text.trim();
          final country = _pendingCountry ?? selectedCountry;
          final phone = _pendingPhone ?? _phoneController.text.trim();
          final email = _pendingEmail ?? _emailController.text.trim();
          try {
            await Supabase.instance.client.from('profiles').upsert({
              'id': user.id,
              'full_name': fullName,
              'country': country,
              'username': username,
              'phone': phone,
              'email': email,
            });
          } catch (e) {
            print('Profile upsert error after Google sign-in: $e');
            _showErrorDialog('Failed to save profile after Google sign-in: $e');
            return;
          }
        }
        if (mounted) {
          Navigator.of(context, rootNavigator: true)
              .popUntil((route) => route.isFirst);
          Navigator.pushReplacementNamed(context, '/job_list');
        }
      }
    });
  }

  Future<void> _signUpWithGoogleAndProfile() async {
    setState(() => _isLoading = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFFD23F))), // Yellow
    );
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'https://jobpop.web.app/#/signup',
      );
      // Do not upsert profile here! It will be handled in onAuthStateChange after redirect.
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Google signup error: $e');
      _showErrorDialog('Failed to signup with Google: $e');
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
            Text('Signup Failed'),
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('assets/logo.png', height: 100),
                const SizedBox(height: 16),
                Text('Create New User',
                    style: GoogleFonts.montserrat(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _fullNameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Full name required' : null,
                  decoration: InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedCountry,
                  decoration: InputDecoration(
                    labelText: 'Country *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'UG', child: Text('Uganda')),
                    DropdownMenuItem(value: 'KE', child: Text('Kenya')),
                    DropdownMenuItem(value: 'TZ', child: Text('Tanzania')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCountry = value ?? 'UG';
                    });
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Username required' : null,
                  decoration: InputDecoration(
                    labelText: 'Username *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email (Optional)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  validator: _validatePhone,
                  decoration: InputDecoration(
                    labelText: 'Phone *',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Password min 6 chars' : null,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: _isLoading ? null : _signup,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('CREATE ACCOUNT',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {},
                  child: Text('Signup as a Company Instead',
                      style: GoogleFonts.montserrat(
                          color: const Color(0xFF007BFF))),
                ),
                const SizedBox(height: 24),
                IconButton(
                  icon: const Icon(Icons.home, size: 30, color: Colors.black),
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompleteProfileScreen extends StatelessWidget {
  final String userId;
  final String? email;

  const CompleteProfileScreen({Key? key, required this.userId, this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Your Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Please complete your profile information.',
              style: GoogleFonts.montserrat(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Add fields for profile completion as needed
            ElevatedButton(
              onPressed: () async {
                // Handle profile completion submission
                // Navigate to the main app screen or show a success message
              },
              child: Text('Submit', style: GoogleFonts.montserrat()),
            ),
          ],
        ),
      ),
    );
  }
}

// NOTE: Make sure your Supabase RLS policy for the profiles table allows authenticated users to insert/upsert their own profile. Example policy:
// CREATE POLICY "Allow user insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
// Enable RLS: ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
