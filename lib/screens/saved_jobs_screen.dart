import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({Key? key}) : super(key: key);

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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFD23F),
        elevation: 0,
        title: Text('Saved Jobs',
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold, color: Colors.black)),
      ),
      body: savedJobs.isEmpty
          ? Center(
              child: Text('No saved jobs yet.',
                  style: GoogleFonts.montserrat(fontSize: 16)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: savedJobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
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
    );
  }
}
