import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedJobsScreen extends StatelessWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Saved Jobs',
            style: GoogleFonts.montserrat(
                color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 3,
          itemBuilder: (context, index) {
            final isExpired = index == 2;
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Job Title $index',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                        if (isExpired)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Expired',
                                style: GoogleFonts.montserrat(
                                    color: Colors.white)),
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Salary: UGX 1,000,000',
                        style: GoogleFonts.montserrat()),
                    Text('Country: Uganda', style: GoogleFonts.montserrat()),
                    Text('Deadline: 2025-07-01',
                        style: GoogleFonts.montserrat()),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
