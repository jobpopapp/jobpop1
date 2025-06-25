import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onToggleLanguage;
  const ProfileScreen({super.key, this.onToggleLanguage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Profile',
            style: GoogleFonts.montserrat(
                color: Colors.black, fontWeight: FontWeight.bold)),
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User Profile',
                style: GoogleFonts.montserrat(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('Name', style: GoogleFonts.montserrat()),
              subtitle: Text('John Doe', style: GoogleFonts.montserrat()),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text('Phone', style: GoogleFonts.montserrat()),
              subtitle:
                  Text('+256 700 000000', style: GoogleFonts.montserrat()),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title:
                  Text('Preferred Language', style: GoogleFonts.montserrat()),
              subtitle: Text('English', style: GoogleFonts.montserrat()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD62828),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Logout', style: GoogleFonts.montserrat()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
