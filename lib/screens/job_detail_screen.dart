import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobpopp/widgets/custom_app_bar.dart';

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

    // You may want to get user info from a provider or pass as arguments for real apps
    // For demo, use placeholders:
    final String username = 'User';
    final String? userEmail = null;
    final String? userPhone = null;
    final String? profilePhotoUrl = null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        username: username,
        userEmail: userEmail,
        userPhone: userPhone,
        profilePhotoUrl: profilePhotoUrl,
        actions: [
          BookmarkButton(job: job),
        ],
        backgroundColor: Colors.white,
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
            else if ((job['job_description'] ?? '')
                .toString()
                .trim()
                .isNotEmpty)
              Text(job['job_description'], style: GoogleFonts.montserrat())
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
                                    (k, v) => MapEntry(k, v?.toString() ?? ''))
                                as Map<String, String>),
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

// Bookmark button widget with Supabase integration
class BookmarkButton extends StatefulWidget {
  final Map<String, dynamic> job;
  const BookmarkButton({Key? key, required this.job}) : super(key: key);

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool isBookmarked = false;
  bool loading = false;
  String? userId;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    userId = supabase.auth.currentUser?.id;
    _checkIfBookmarked();
  }

  Future<void> _checkIfBookmarked() async {
    if (userId == null || widget.job['id'] == null) return;
    setState(() => loading = true);
    final res = await supabase
        .from('saved_jobs')
        .select('id')
        .eq('user_id', userId ?? '')
        .eq('job_id', widget.job['id'])
        .maybeSingle();
    setState(() {
      isBookmarked = res != null;
      loading = false;
    });
  }

  Future<void> _toggleBookmark() async {
    if (userId == null || widget.job['id'] == null) return;
    setState(() => loading = true);
    if (isBookmarked) {
      // Remove bookmark
      await supabase
          .from('saved_jobs')
          .delete()
          .eq('user_id', userId ?? '')
          .eq('job_id', widget.job['id']);
      setState(() {
        isBookmarked = false;
        loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Job removed from saved'),
              duration: Duration(seconds: 1)),
        );
      }
    } else {
      // Add bookmark
      await supabase.from('saved_jobs').insert({
        'user_id': userId ?? '',
        'job_id': widget.job['id'],
      });
      setState(() {
        isBookmarked = true;
        loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Job saved!'), duration: Duration(seconds: 1)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: loading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2))
          : Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: Colors.black,
            ),
      tooltip: isBookmarked ? 'Remove from saved' : 'Save job',
      onPressed: loading ? null : _toggleBookmark,
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
      appBar: CustomAppBar(
        username: 'User',
        userEmail: null,
        userPhone: null,
        profilePhotoUrl: null,
        backgroundColor: Colors.white,
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
