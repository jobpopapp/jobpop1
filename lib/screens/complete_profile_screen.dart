import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/language_provider.dart';
import '../utils/manual_localization.dart' show t;

class CompleteProfileScreen extends StatefulWidget {
  final String userId;
  final String? email;

  const CompleteProfileScreen({Key? key, required this.userId, this.email})
      : super(key: key);

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController(text: 'UG');
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
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

  Future<void> _submitProfile(String lang) async {
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
      final profileData = {
        'id': widget.userId,
        'full_name': _fullNameController.text.trim(),
        'country': _countryController.text.trim(),
        'username': _usernameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': widget.email ?? '',
      };
      print('--- Complete profile data to be saved ---');
      profileData.forEach((k, v) => print('$k: $v'));
      await Supabase.instance.client.from('profiles').upsert(profileData);
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        Navigator.pushReplacementNamed(context, '/job_list');
      }
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Profile completion error: $e');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(t('error', lang)),
            ],
          ),
          content: Text(t('failedToCompleteProfile', lang) + ': $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t('ok', lang)),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(t('completeYourProfile', lang)),
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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t('pleaseCompleteProfile', lang),
                style: GoogleFonts.montserrat(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _fullNameController,
                validator: (v) =>
                    v == null || v.isEmpty ? t('fullNameRequired', lang) : null,
                decoration: InputDecoration(
                  labelText: t('fullName', lang) + ' *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _countryController.text.isNotEmpty
                    ? _countryController.text
                    : 'UG',
                decoration: InputDecoration(
                  labelText: t('country', lang) + ' *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: [
                  DropdownMenuItem(value: 'UG', child: Text(t('uganda', lang))),
                  DropdownMenuItem(value: 'KE', child: Text(t('kenya', lang))),
                  DropdownMenuItem(
                      value: 'TZ', child: Text(t('tanzania', lang))),
                ],
                onChanged: (value) {
                  setState(() {
                    _countryController.text = value ?? 'UG';
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                validator: (v) =>
                    v == null || v.isEmpty ? t('usernameRequired', lang) : null,
                decoration: InputDecoration(
                  labelText: t('username', lang) + ' *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                validator: (v) => _validatePhone(v, lang),
                decoration: InputDecoration(
                  labelText: t('phone', lang) + ' *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _submitProfile(lang),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(t('submit', lang),
                      style: GoogleFonts.montserrat(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}