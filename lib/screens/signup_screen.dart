import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/password_hash.dart';
import '../utils/language_provider.dart';
import '../utils/manual_localization.dart' show t;
import 'complete_profile_screen.dart';

enum SignupMode { select, phone, googleProfile, completeAuthProfile }

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  SignupMode _mode = SignupMode.select;
  String selectedCountry = 'UG';
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // For complete auth profile mode
  String? _authProfileUserId;
  String? _authProfileEmail;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value, String lang) {
    if (value == null || value.isEmpty) return t('phoneRequired', lang);
    final phonePattern = RegExp(r'^0[7][0-9]{8}');
    if (!phonePattern.hasMatch(value)) {
      return t('phoneFormat', lang);
    }
    return null;
  }

  Future<void> _signup() async {
    final lang = Provider.of<LanguageProvider>(context, listen: false)
        .locale
        .languageCode;
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(t('signupWithGoogle', lang)),
          content: Text(t('signupWithGoogleMsg', lang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t('cancel', lang)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t('continueWithGoogle', lang)),
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
      final email = _emailController.text.trim();
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
      final profileData = {
        'full_name': _fullNameController.text.trim(),
        'country': selectedCountry,
        'username': _usernameController.text.trim(),
        'phone': phone,
        'email': email,
        'password': hashedPassword,
      };
      print('--- Phone-only profile data to be saved ---');
      profileData.forEach((k, v) => print('$k: $v'));
      // Insert new profile WITHOUT id, so DB generates UUID
      final response =
          await Supabase.instance.client.from('profiles').insert(profileData);
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
      final response = await Supabase.instance.client.auth.signUp(
        email: email.isNotEmpty ? email : null,
        phone: phone.isNotEmpty ? phone : null,
        password: password,
      );
      final user = response.user;
      if (user != null && user.id.isNotEmpty) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() {
          _authProfileUserId = user.id;
          _authProfileEmail = user.email ?? email;
          _mode = SignupMode.completeAuthProfile;
        });
        return;
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
        final user = session.user;
        // Always show complete profile UI after Google OAuth
        setState(() {
          _authProfileUserId = user.id;
          _authProfileEmail = user.email;
          _mode = SignupMode.completeAuthProfile;
        });
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
        redirectTo: 'jobpopp://auth-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
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
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _buildBody(context, lang),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String lang) {
    switch (_mode) {
      case SignupMode.select:
        return _buildSelectMode(lang);
      case SignupMode.phone:
        return _buildPhoneMode(lang);
      case SignupMode.googleProfile:
        return _buildGoogleProfileMode(lang);
      case SignupMode.completeAuthProfile:
        return _buildCompleteAuthProfileMode(
            _authProfileUserId!, _authProfileEmail, lang);
    }
  }

  Widget _buildSelectMode(String lang) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Create Account',
              style: GoogleFonts.montserrat(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: OutlinedButton(
              onPressed: () async {
                setState(() {
                  _mode = SignupMode.googleProfile;
                });
                await _signUpWithGoogleAndProfile();
              },
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
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              ),
              onPressed: () {
                setState(() {
                  _mode = SignupMode.phone;
                });
              },
              child: Text('I have no email', style: GoogleFonts.montserrat()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneMode(String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Image.asset('assets/logo.png', height: 100),
            const SizedBox(height: 16),
            Text(t('createNewUser', lang),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            // Name
            Align(
                alignment: Alignment.centerLeft,
                child: Text(t('pleaseFillFullName', lang),
                    style: TextStyle(color: Colors.red))),
            const SizedBox(height: 4),
            TextFormField(
              controller: _fullNameController,
              validator: (v) =>
                  v == null || v.isEmpty ? t('fullNameRequired', lang) : null,
              decoration: InputDecoration(
                labelText: t('fullName', lang) + ' *',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            // Country
            Align(
                alignment: Alignment.centerLeft,
                child: Text(t('pleaseSelectCountry', lang),
                    style: TextStyle(color: Colors.red))),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: selectedCountry,
              decoration: InputDecoration(
                labelText: t('country', lang) + ' *',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: [
                DropdownMenuItem(value: 'UG', child: Text(t('uganda', lang))),
                DropdownMenuItem(value: 'KE', child: Text(t('kenya', lang))),
                DropdownMenuItem(value: 'TZ', child: Text(t('tanzania', lang))),
              ],
              onChanged: (value) {
                setState(() {
                  selectedCountry = value ?? 'UG';
                });
              },
            ),
            const SizedBox(height: 16),
            // Username
            Align(
                alignment: Alignment.centerLeft,
                child: Text(t('pleaseEnterUsername', lang),
                    style: TextStyle(color: Colors.red))),
            const SizedBox(height: 4),
            TextFormField(
              controller: _usernameController,
              validator: (v) =>
                  v == null || v.isEmpty ? t('usernameRequired', lang) : null,
              decoration: InputDecoration(
                labelText: t('username', lang) + ' *',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            // Phone
            Align(
                alignment: Alignment.centerLeft,
                child: Text(t('pleaseEnterPhone', lang),
                    style: TextStyle(color: Colors.red))),
            const SizedBox(height: 4),
            TextFormField(
              controller: _phoneController,
              validator: (v) => _validatePhone(v, lang),
              decoration: InputDecoration(
                labelText: t('phone', lang) + ' *',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            // Password
            Align(
                alignment: Alignment.centerLeft,
                child: Text(t('pleaseEnterPassword', lang),
                    style: TextStyle(color: Colors.red))),
            const SizedBox(height: 4),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              validator: (v) =>
                  v == null || v.isEmpty ? t('passwordRequired', lang) : null,
              decoration: InputDecoration(
                labelText: t('password', lang) + ' *',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 28),
            // Login Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _signup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(t('login', lang),
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            // Signup as company
            TextButton(
              onPressed: () {},
              child: Text(
                t('signupAsCompany', lang),
                style: TextStyle(color: Colors.blue),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleProfileMode(String lang) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: Color(0xFFFFD23F)),
          const SizedBox(height: 16),
          Text(t('signingUpWithGoogle', lang),
              style: GoogleFonts.montserrat(
                  color: Colors.black, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCompleteAuthProfileMode(
      String userId, String? email, String lang) {
    return CompleteProfileScreen(userId: userId, email: email);
  }
}



// NOTE: Make sure your Supabase RLS policy for the profiles table allows authenticated users to insert/upsert their own profile. Example policy:
// CREATE POLICY "Allow user insert" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
// Enable RLS: ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
