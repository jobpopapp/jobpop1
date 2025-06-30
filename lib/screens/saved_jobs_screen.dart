import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({Key? key}) : super(key: key);

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with real saved jobs from Supabase
    final List<Map<String, String>> savedJobs = [
      {
        'title': 'Housekeeper',
        'company': 'Kampala Homes',
        'salary': 'UGX 400,000',
        'country': 'Uganda',
        'deadline': '2025-07-15',
      },
      {
        'title': 'Driver',
        'company': 'Safe Transport',
        'salary': 'UGX 600,000',
        'country': 'Uganda',
        'deadline': '2025-07-20',
      },
    ];

    // Mock user info for AppBar (replace with real user data if available)
    final String username = 'User';
    final String? userEmail = '';
    final String? userPhone = '';
    final String? profilePhotoUrl = null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: const Color(0xFFFFD23F),
        elevation: 0,
        title: Row(
          children: [
            if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(profilePhotoUrl),
                  backgroundColor: Colors.grey[200],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, color: Colors.white),
                ),
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username.isNotEmpty ? username : 'User',
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (userEmail != null && userEmail.isNotEmpty)
                    Text(
                      userEmail,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Color.fromARGB(255, 122, 0, 0),
                      ),
                    ),
                  if (userPhone != null && userPhone.isNotEmpty)
                    Text(
                      userPhone,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Color.fromARGB(255, 105, 0, 0),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add logout logic if needed
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: savedJobs.isEmpty
          ? Center(
              child: Text('No saved jobs yet.',
                  style: GoogleFonts.montserrat(fontSize: 16)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: savedJobs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = savedJobs[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(job['title'] ?? '',
                        style: GoogleFonts.montserrat(
                            fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job['company'] ?? '',
                            style: GoogleFonts.montserrat()),
                        Text('Salary: ${job['salary']}',
                            style: GoogleFonts.montserrat(fontSize: 12)),
                        Text('Country: ${job['country']}',
                            style: GoogleFonts.montserrat(fontSize: 12)),
                        Text('Deadline: ${job['deadline']}',
                            style: GoogleFonts.montserrat(
                                fontSize: 12, color: Colors.red)),
                      ],
                    ),
                    trailing: Icon(Icons.bookmark, color: Colors.amber[800]),
                    onTap: () {
                      // TODO: Navigate to job detail
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/profile');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/job_list');
          } else if (index == 2) {
            // Already on saved jobs
          }
        },
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
