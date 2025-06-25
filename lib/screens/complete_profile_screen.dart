import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String userId;
  final String? email;
  const CompleteProfileScreen({super.key, required this.userId, this.email});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  String selectedCountry = 'UG';
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.from('profiles').insert({
        'id': widget.userId,
        'full_name': _fullNameController.text.trim(),
        'country': selectedCountry,
        'username': _usernameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': widget.email,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile completed!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Profile save error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile save error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complete Profile', style: GoogleFonts.montserrat()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Please complete your profile',
                  style: GoogleFonts.montserrat(fontSize: 18)),
              const SizedBox(height: 24),
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
                controller: _phoneController,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Phone required' : null,
                decoration: InputDecoration(
                  labelText: 'Phone *',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('Save Profile',
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
