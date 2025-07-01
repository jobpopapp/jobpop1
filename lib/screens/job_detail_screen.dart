import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get job data from arguments if available
    final dynamic args = ModalRoute.of(context)?.settings.arguments;
    Map<String, dynamic> job;
    if (args != null && args is Map<String, dynamic>) {
      job = args;
    } else {
      job = {
        'title': 'Housekeeper',
        'category': 'Domestic Work',
        'country': 'Uganda',
        'salary': 'UGX 400,000',
        'deadline': '2025-07-15',
        'company': 'Kampala Homes',
        'description': 'Responsible for cleaning and maintaining the house.',
        'requirements': 'Cleaning, Organization, Honesty',
        'email': 'hr@kampalahomes.com',
        'company_website': 'https://kampalahomes.com',
        'application_link': 'https://kampalahomes.com/apply',
        'contact_phone': '+256 700 000000',
      };
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Job Details',
            style: GoogleFonts.montserrat(
                color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text(job['title'] ?? '',
                style: GoogleFonts.montserrat(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Company: ${job['company']}', style: GoogleFonts.montserrat()),
            Text('Category: ${job['category']}',
                style: GoogleFonts.montserrat()),
            Text('Country: ${job['country']}', style: GoogleFonts.montserrat()),
            Text('Salary: ${job['salary']}', style: GoogleFonts.montserrat()),
            // Deadline: bold, red if past, green if future
            Builder(
              builder: (context) {
                final deadlineStr = job['deadline'] ?? '';
                DateTime? deadline;
                try {
                  if (deadlineStr is String && deadlineStr.isNotEmpty) {
                    deadline = DateTime.tryParse(deadlineStr);
                  }
                } catch (_) {}
                final now = DateTime.now();
                final isPast = deadline != null && deadline.isBefore(now);
                return Text(
                  'Deadline: $deadlineStr',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: deadline == null
                        ? Colors.black
                        : isPast
                            ? Colors.red
                            : Colors.green,
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD23F),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Posted by: ${job['company']}',
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Job Description',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            // Show job description, fallback if missing
            if ((job['description'] ?? '').toString().trim().isNotEmpty)
              Text(job['description'], style: GoogleFonts.montserrat())
            else
              Text('No description provided.',
                  style: GoogleFonts.montserrat(
                      fontStyle: FontStyle.italic, color: Colors.grey)),
            const SizedBox(height: 16),
            Text('Requirements',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            Text(job['requirements'] ?? '', style: GoogleFonts.montserrat()),
            const SizedBox(height: 16),
            if ((job['application_link'] ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobApplyScreen(
                            job: job.map(
                                (k, v) => MapEntry(k, v?.toString() ?? ''))),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD62828),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: Text('How to Apply',
                      style: GoogleFonts.montserrat(fontSize: 18)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class JobApplyScreen extends StatelessWidget {
  final Map<String, String> job;
  const JobApplyScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('How to Apply',
            style: GoogleFonts.montserrat(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text('Hiring Company:',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            Text(job['company'] ?? '', style: GoogleFonts.montserrat()),
            const SizedBox(height: 8),
            Text('Deadline:',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            Text(job['deadline'] ?? '', style: GoogleFonts.montserrat()),
            const SizedBox(height: 8),
            Text('Requirements:',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            Text(job['requirements'] ?? '', style: GoogleFonts.montserrat()),
            const SizedBox(height: 8),
            if ((job['email'] ?? '').isNotEmpty)
              Text('Email: ${job['email']}', style: GoogleFonts.montserrat()),
            if ((job['company_website'] ?? '').isNotEmpty)
              Text('Website: ${job['company_website']}',
                  style: GoogleFonts.montserrat()),
            if ((job['application_link'] ?? '').isNotEmpty)
              Text('Application Link: ${job['application_link']}',
                  style: GoogleFonts.montserrat()),
            if ((job['contact_phone'] ?? '').isNotEmpty)
              Text('Contact Phone: ${job['contact_phone']}',
                  style: GoogleFonts.montserrat()),
          ],
        ),
      ),
    );
  }
}
