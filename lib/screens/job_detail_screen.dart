import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobpopp/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  String username = 'User';
  String? userEmail;
  String? userPhone;
  String? profilePhotoUrl;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      setState(() {
        username = user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            profile?['username'] ??
            'User';
        userEmail = user.userMetadata?['email'] ?? profile?['email'] ?? '';
        userPhone = user.userMetadata?['phone'] ?? profile?['phone'] ?? '';
        profilePhotoUrl =
            user.userMetadata?['avatar_url'] ?? profile?['profile_photo_url'];
      });
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/job_list');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/saved-jobs');
    }
  }

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
              Text(job['description'] ?? '', style: GoogleFonts.montserrat())
            else if ((job['job_description'] ?? '')
                .toString()
                .trim()
                .isNotEmpty)
              Text(job['job_description'] ?? '',
                  style: GoogleFonts.montserrat())
            else
              Text('No description provided.',
                  style: GoogleFonts.montserrat(
                      fontStyle: FontStyle.italic, color: Colors.grey)),
            const SizedBox(height: 16),
            Text('Requirements',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            Text(job['requirements'] ?? '', style: GoogleFonts.montserrat()),
            const SizedBox(height: 16),
            if ((job['application_link'] ?? '').toString().isNotEmpty)
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

class JobApplyScreen extends StatefulWidget {
  final Map<String, String> job;
  const JobApplyScreen({super.key, required this.job});

  @override
  State<JobApplyScreen> createState() => _JobApplyScreenState();
}

class _JobApplyScreenState extends State<JobApplyScreen> {
  String username = 'User';
  String? userEmail;
  String? userPhone;
  String? profilePhotoUrl;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user != null) {
      final profile = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      setState(() {
        username = user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            profile?['username'] ??
            'User';
        userEmail = user.userMetadata?['email'] ?? profile?['email'] ?? '';
        userPhone = user.userMetadata?['phone'] ?? profile?['phone'] ?? '';
        profilePhotoUrl =
            user.userMetadata?['avatar_url'] ?? profile?['profile_photo_url'];
      });
    }
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/profile');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/job_list');
    } else if (index == 2) {
      Navigator.pushReplacementNamed(context, '/saved-jobs');
    }
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        username: username,
        userEmail: userEmail,
        userPhone: userPhone,
        profilePhotoUrl: profilePhotoUrl,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 4.0),
              child: Text(
                'Hiring Company:',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, height: 1.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                job['company'] ?? '',
                style: GoogleFonts.montserrat(height: 1.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                'Deadline:',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, height: 1.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                job['deadline'] ?? '',
                style: GoogleFonts.montserrat(height: 1.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                'Requirements:',
                style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold, height: 1.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                job['requirements'] ?? '',
                style: GoogleFonts.montserrat(height: 1.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                'HOW TO APPLY:',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  height: 1.2,
                ),
              ),
            ),
            if ((job['email'] ?? '').toString().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'Email:',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, height: 1.2),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final email = job['email'];
                  if (email != null) {
                    launchUrl(Uri.parse('mailto:$email'));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    job['email'] ?? '',
                    style: GoogleFonts.montserrat(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
            if ((job['company_website'] ?? '').toString().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'Website:',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, height: 1.2),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final url = job['company_website'];
                  if (url != null) {
                    launchUrl(Uri.parse(url));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    job['company_website'] ?? '',
                    style: GoogleFonts.montserrat(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
            if ((job['application_link'] ?? '').toString().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'Application Link:',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, height: 1.2),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final url = job['application_link'];
                  if (url != null) {
                    launchUrl(Uri.parse(url));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    job['application_link'] ?? '',
                    style: GoogleFonts.montserrat(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
            if ((job['contact_phone'] ?? '').toString().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'Contact Phone:',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, height: 1.2),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final phone = job['contact_phone'];
                  if (phone != null) {
                    launchUrl(Uri.parse('tel:$phone'));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    job['contact_phone'] ?? '',
                    style: GoogleFonts.montserrat(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
            ],
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
