import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  final String? username;
  final String? userEmail;
  final String? userPhone;
  final String? profilePhotoUrl;
  final String? preferredLanguage;
  final VoidCallback? onToggleLanguage;
  final VoidCallback? onLogout;

  const ProfileScreen({
    super.key,
    this.username,
    this.userEmail,
    this.userPhone,
    this.profilePhotoUrl,
    this.preferredLanguage,
    this.onToggleLanguage,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty)
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(profilePhotoUrl!),
                  backgroundColor: Colors.grey[200],
                )
              else
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username ?? 'User',
                      style: GoogleFonts.montserrat(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    if (userEmail != null && userEmail!.isNotEmpty)
                      Text(
                        userEmail!,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    if (userPhone != null && userPhone!.isNotEmpty)
                      Text(
                        userPhone!,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
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
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('Name', style: GoogleFonts.montserrat()),
            subtitle: Text(username ?? '-', style: GoogleFonts.montserrat()),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: Text('Phone', style: GoogleFonts.montserrat()),
            subtitle: Text(userPhone ?? '-', style: GoogleFonts.montserrat()),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text('Preferred Language', style: GoogleFonts.montserrat()),
            subtitle: Text(preferredLanguage ?? 'English',
                style: GoogleFonts.montserrat()),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLogout,
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
    );
  }
}
