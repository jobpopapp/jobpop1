import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class JobDetailScreen extends StatelessWidget {
  const JobDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            Text('Job Title',
                style: GoogleFonts.montserrat(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Category: Education', style: GoogleFonts.montserrat()),
            Text('Country: Uganda', style: GoogleFonts.montserrat()),
            Text('Salary: UGX 1,000,000', style: GoogleFonts.montserrat()),
            Text('Deadline: 2025-07-01', style: GoogleFonts.montserrat()),
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
                  child: Text('Posted by: Agency Name',
                      style:
                          GoogleFonts.montserrat(fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('Foreign Employer',
                      style: GoogleFonts.montserrat(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
                'Full job description goes here. This is a placeholder for the job details.',
                style: GoogleFonts.montserrat()),
            const SizedBox(height: 24),
            Text('Contact Info:',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.email, color: Colors.black),
                const SizedBox(width: 8),
                Text('hr@company.com', style: GoogleFonts.montserrat()),
              ],
            ),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.black),
                const SizedBox(width: 8),
                Text('+256 700 000000', style: GoogleFonts.montserrat()),
              ],
            ),
            Row(
              children: [
                Icon(Icons.message,
                    color: Colors.green), // WhatsApp placeholder
                const SizedBox(width: 8),
                Text('+256 700 000000', style: GoogleFonts.montserrat()),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD62828),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text('Apply', style: GoogleFonts.montserrat(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
