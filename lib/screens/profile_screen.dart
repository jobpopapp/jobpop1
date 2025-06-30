import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
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
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Already on profile
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/job_list');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/saved-jobs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD23F),
        elevation: 0,
        title: Row(
          children: [
            if (widget.profilePhotoUrl != null &&
                widget.profilePhotoUrl!.isNotEmpty)
              CircleAvatar(
                radius: 22,
                backgroundImage: NetworkImage(widget.profilePhotoUrl!),
                backgroundColor: Colors.grey[200],
              )
            else
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.white),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username ?? 'User',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (widget.userEmail != null && widget.userEmail!.isNotEmpty)
                    Text(
                      widget.userEmail!,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 122, 0, 0),
                      ),
                    ),
                  if (widget.userPhone != null && widget.userPhone!.isNotEmpty)
                    Text(
                      widget.userPhone!,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 105, 0, 0),
                      ),
                    ),
                ],
              ),
            ),
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text('Name', style: GoogleFonts.montserrat()),
              subtitle:
                  Text(widget.username ?? '-', style: GoogleFonts.montserrat()),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text('Phone', style: GoogleFonts.montserrat()),
              subtitle: Text(widget.userPhone ?? '-',
                  style: GoogleFonts.montserrat()),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title:
                  Text('Preferred Language', style: GoogleFonts.montserrat()),
              subtitle: Text(widget.preferredLanguage ?? 'English',
                  style: GoogleFonts.montserrat()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onLogout,
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
        ],
      ),
    );
  }
}
