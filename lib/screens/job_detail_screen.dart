import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:jobpopp/widgets/custom_app_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/manual_localization.dart' show t;
import '../utils/language_provider.dart';

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
    final lang = Provider.of<LanguageProvider>(context).locale.languageCode;
    // Get job data from arguments if available
    final dynamic args = ModalRoute.of(context)?.settings.arguments;
    Map<String, dynamic> job;
    if (args != null && args is Map<String, dynamic>) {
      job = args;
    } else {
      job = {
        'title': t('defaultJobTitle', lang),
        'category': t('defaultCategory', lang),
        'country': t('uganda', lang),
        'salary': 'UGX 400,000',
        'deadline': '2025-07-15',
        'company': t('defaultCompany', lang),
        'description': t('defaultDescription', lang),
        'requirements': t('defaultRequirements', lang),
        'email': '',
        'company_website': '',
        'application_link': '',
        'contact_phone': '',
        'whatsapp': '',
      };
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        username: username,
        userEmail: userEmail,
        userPhone: userPhone,
        profilePhotoUrl: profilePhotoUrl,
        backgroundColor: const Color(0xFFFFD23F), // Yellow background
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: BookmarkButton(job: job),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.black),
              tooltip: 'Logout',
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                }
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text(job['title'] ?? '',
                style: GoogleFonts.montserrat(
                    fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 8),
            Text(t('company', lang) + ': ${job['company']}',
                style: GoogleFonts.montserrat(color: Colors.blue)),
            Text(t('category', lang) + ': ${job['categories']?['name'] ?? ''}',
                style: GoogleFonts.montserrat(color: Colors.blue)),
            Text(t('country', lang) + ': ${job['country']}',
                style: GoogleFonts.montserrat(color: Colors.blue)),
            Text(t('salary', lang) + ': ${job['salary']}',
                style: GoogleFonts.montserrat(color: Colors.blue)),
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

                // Status logic
                String statusText;
                Color statusBg;
                Color statusTextColor = Colors.white;
                if (deadline == null) {
                  statusText = t('', lang) + t('unknown', lang);
                  statusBg = Colors.grey;
                } else if (isPast) {
                  statusText = t('', lang) + t('Expired', lang);
                  statusBg = Colors.red;
                } else {
                  statusText = t('', lang) + t('Active', lang);
                  statusBg = Colors.green;
                }

                // Deadline text color logic
                Color deadlineTextColor;
                if (deadline == null) {
                  deadlineTextColor = Colors.black;
                } else if (isPast) {
                  deadlineTextColor = Colors.red;
                } else {
                  deadlineTextColor = Colors.green;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('deadline', lang) + ': $deadlineStr',
                      style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold,
                        color: deadlineTextColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusText,
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w500,
                              color: statusTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 16),
            Text(t('jobDescription', lang),
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            // Show job description, fallback if missing
            if ((job['description'] ?? '').toString().trim().isNotEmpty)
              Text(job['description'] ?? '', style: GoogleFonts.montserrat(color: Colors.blue))
            else if ((job['job_description'] ?? '')
                .toString()
                .trim()
                .isNotEmpty)
              Text(job['job_description'] ?? '',
                  style: GoogleFonts.montserrat(color: Colors.blue))
            else
              Text(t('noDescriptionProvided', lang),
                  style: GoogleFonts.montserrat(
                      fontStyle: FontStyle.italic, color: Colors.grey)),
            const SizedBox(height: 16),
            Text(t('requirements', lang),
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
            Text(job['requirements'] ?? '', style: GoogleFonts.montserrat(color: Colors.blue)),
            const SizedBox(height: 16),
            if (((job['email'] ?? '').toString().isNotEmpty) ||
                ((job['contact_phone'] ?? '').toString().isNotEmpty) ||
                ((job['whatsapp'] ?? '').toString().isNotEmpty) ||
                ((job['application_link'] ?? '').toString().isNotEmpty))
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
                  child: Text(t('howToApply', lang),
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
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.person), label: t('profile', lang)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.search), label: t('jobs', lang)),
          BottomNavigationBarItem(
              icon: const Icon(Icons.bookmark), label: t('saved', lang)),
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
  String? userPhone;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      // Google Auth user
      userId = user.id;
    } else {
      // Phone-only user
      final prefs = await SharedPreferences.getInstance();
      userPhone = prefs.getString('phone_login');
    }
    _checkIfBookmarked();
  }

  Future<void> _checkIfBookmarked() async {
    if ((userId == null && userPhone == null) || widget.job['id'] == null)
      return;
    setState(() => loading = true);

    final query = supabase.from('saved_jobs').select('id');

    if (userId != null) {
      // Query by user_id for Google Auth users
      query.eq('user_id', userId!);
    } else {
      // Query by user_phone for phone-only users
      query.eq('user_phone', userPhone!);
    }

    final res = await query.eq('job_id', widget.job['id']).maybeSingle();

    setState(() {
      isBookmarked = res != null;
      loading = false;
    });
  }

  Future<void> _toggleBookmark() async {
    if ((userId == null && userPhone == null) || widget.job['id'] == null)
      return;
    setState(() => loading = true);

    if (isBookmarked) {
      // Remove bookmark
      final deleteQuery = supabase.from('saved_jobs').delete();

      if (userId != null) {
        deleteQuery.eq('user_id', userId!);
      } else {
        deleteQuery.eq('user_phone', userPhone!);
      }

      await deleteQuery.eq('job_id', widget.job['id']);

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
      final insertData = <String, dynamic>{
        'job_id': widget.job['id'],
      };

      if (userId != null) {
        insertData['user_id'] = userId!;
      } else {
        insertData['user_phone'] = userPhone!;
      }

      await supabase.from('saved_jobs').insert(insertData);

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
                style: GoogleFonts.montserrat(height: 1.2, color: Colors.blue),
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
                style: GoogleFonts.montserrat(height: 1.2, color: Colors.blue),
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
                style: GoogleFonts.montserrat(height: 1.2, color: Colors.blue),
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
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    child: Text(
                      job['email'] ?? '',
                      style: GoogleFonts.montserrat(
                        color: Colors.blue,
                        decoration: TextDecoration.none,
                        height: 1.2,
                      ),
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
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    child: Text(
                      job['company_website'] ?? '',
                      style: GoogleFonts.montserrat(
                        color: Colors.blue,
                        decoration: TextDecoration.none,
                        height: 1.2,
                      ),
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
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    child: Text(
                      job['application_link'] ?? '',
                      style: GoogleFonts.montserrat(
                        color: Colors.blue,
                        decoration: TextDecoration.none,
                        height: 1.2,
                      ),
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
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    child: Text(
                      job['contact_phone'] ?? '',
                      style: GoogleFonts.montserrat(
                        color: Colors.blue,
                        decoration: TextDecoration.none,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if ((job['whatsapp'] ?? '').toString().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'WhatsApp:',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, height: 1.2),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final whatsapp = job['whatsapp'];
                  if (whatsapp != null) {
                    launchUrl(Uri.parse('https://wa.me/$whatsapp'));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    child: Text(
                      job['whatsapp'] ?? '',
                      style: GoogleFonts.montserrat(
                        color: Colors.blue,
                        decoration: TextDecoration.none,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if ((job['whatsapp'] ?? '').toString().isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'WhatsApp:',
                  style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold, height: 1.2),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final whatsapp = job['whatsapp'];
                  if (whatsapp != null) {
                    launchUrl(Uri.parse('https://wa.me/$whatsapp'));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.blue, width: 1),
                      ),
                    ),
                    child: Text(
                      job['whatsapp'] ?? '',
                      style: GoogleFonts.montserrat(
                        color: Colors.blue,
                        decoration: TextDecoration.none,
                        height: 1.2,
                      ),
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
