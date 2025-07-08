import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobpopp/widgets/custom_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/manual_localization.dart';
import '../utils/language_provider.dart';

class SavedJobsScreen extends StatefulWidget {
  const SavedJobsScreen({Key? key}) : super(key: key);

  @override
  State<SavedJobsScreen> createState() => _SavedJobsScreenState();
}

class _SavedJobsScreenState extends State<SavedJobsScreen> {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> _savedJobs = [];
  bool _loading = true;
  String username = 'User';
  String? userEmail;
  String? userPhone;
  String? profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    _fetchSavedJobs();
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
        // Prefer Google Auth metadata if available, else fallback to profiles table
        username = user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            profile?['username'] ??
            'User';
        userEmail = user.userMetadata?['email'] ?? profile?['email'] ?? '';
        userPhone = user.userMetadata?['phone'] ?? profile?['phone'] ?? '';
        profilePhotoUrl =
            user.userMetadata?['avatar_url'] ?? profile?['profile_photo_url'];
      });
    } else {
      // Phone-only login: get id/username/phone from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final phone = prefs.getString('phone_login');
      if (phone != null && phone.isNotEmpty) {
        final profile = await supabase
            .from('profiles')
            .select()
            .eq('phone', phone)
            .maybeSingle();
        setState(() {
          username = profile?['username'] ?? 'User';
          userEmail = profile?['email'] ?? '';
          userPhone = profile?['phone'] ?? '';
          profilePhotoUrl = profile?['profile_photo_url'];
        });
      }
    }
  }

  Future<void> _fetchSavedJobs() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    
    String? userId;
    String? userPhone;
    
    if (user != null) {
      // Google Auth user
      userId = user.id;
      debugPrint('Logged in user id: ${user.id}');
    } else {
      // Phone-only login: get phone from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      userPhone = prefs.getString('phone_login');
      if (userPhone == null || userPhone.isEmpty) {
        debugPrint('No logged in user.');
        setState(() {
          _savedJobs = [];
          _loading = false;
        });
        return;
      }
      debugPrint('Phone-only user: $userPhone');
    }
    
    try {
      List<Map<String, dynamic>> response;
      
      if (userId != null) {
        // Query by user_id for Google Auth users
        response = List<Map<String, dynamic>>.from(await supabase
            .from('saved_jobs')
            .select(
                'job_id,jobs(title,company,salary,country,deadline,job_description,requirements,email,company_website,application_link,contact_phone)')
            .eq('user_id', userId)
            .order('id', ascending: false));
      } else {
        // Query by phone for phone-only users
        response = List<Map<String, dynamic>>.from(await supabase
            .from('saved_jobs')
            .select(
                'job_id,jobs(title,company,salary,country,deadline,job_description,requirements,email,company_website,application_link,contact_phone)')
            .eq('user_phone', userPhone!)
            .order('id', ascending: false));
      }
      
      debugPrint('Fetched saved jobs: ${response.length}');
      for (final job in response) {
        debugPrint('Saved job: ${job.toString()}');
      }
      setState(() {
        _savedJobs = response;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error fetching saved jobs: $e');
      setState(() {
        _savedJobs = [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale.languageCode;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        username: username,
        userEmail: userEmail,
        userPhone: userPhone,
        profilePhotoUrl: profilePhotoUrl,
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Add logout logic if needed
            },
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: t('logout', lang),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _savedJobs.isEmpty
              ? Center(
                  child: Text(t('noSavedJobs', lang),
                      style: GoogleFonts.montserrat(fontSize: 16)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _savedJobs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = _savedJobs[index];
                    final jobData = job['jobs'] ?? {};
                    // Compose a job map with all fields needed by the detail screen, fallback to empty string if null
                    final detailJob = <String, dynamic>{
                      'id': job['job_id'] ?? '',
                      'title': jobData['title'] ?? '',
                      'company': jobData['company'] ?? '',
                      'salary': jobData['salary'] ?? '',
                      'country': jobData['country'] ?? '',
                      'deadline': jobData['deadline'] ?? '',
                      'description': jobData['job_description'] ??
                          jobData['description'] ??
                          '',
                      'requirements': jobData['requirements'] ?? '',
                      'email': jobData['email'] ?? '',
                      'company_website': jobData['company_website'] ?? '',
                      'application_link': jobData['application_link'] ?? '',
                      'contact_phone': jobData['contact_phone'] ?? '',
                      'category': jobData['category'] ?? '',
                    };
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(detailJob['title'],
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(detailJob['company'],
                                style: GoogleFonts.montserrat()),
                            Text(t('salary', lang) + ': ${detailJob['salary']}',
                                style: GoogleFonts.montserrat(fontSize: 12)),
                            Text(
                                t('country', lang) +
                                    ': ${detailJob['country']}',
                                style: GoogleFonts.montserrat(fontSize: 12)),
                            Text(
                                t('deadline', lang) +
                                    ': ${detailJob['deadline']}',
                                style: GoogleFonts.montserrat(
                                    fontSize: 12, color: Colors.red)),
                          ],
                        ),
                        trailing:
                            Icon(Icons.bookmark, color: Colors.amber[800]),
                        onTap: () {
                          debugPrint('Navigating to job detail with:');
                          debugPrint(detailJob.toString());
                          Navigator.pushNamed(
                            context,
                            '/job-detail', // Use the same route as JobListScreen
                            arguments: detailJob,
                          );
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
