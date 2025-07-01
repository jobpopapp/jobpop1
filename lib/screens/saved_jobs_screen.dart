import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jobpopp/widgets/custom_app_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // Optionally handle phone-only login with SharedPreferences if needed
    }
  }

  Future<void> _fetchSavedJobs() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      debugPrint('No logged in user.');
      setState(() {
        _savedJobs = [];
        _loading = false;
      });
      return;
    }
    debugPrint('Logged in user id: ${user.id}');
    final response = await supabase
        .from('saved_jobs')
        .select(
            'job_id,jobs(title,company,salary,country,deadline,job_description,requirements,email,company_website,application_link,contact_phone)')
        .eq('user_id', user.id)
        .order('id', ascending: false);
    final jobsList = List<Map<String, dynamic>>.from(response);
    debugPrint('Fetched saved jobs: ${jobsList.length}');
    for (final job in jobsList) {
      debugPrint('Saved job: ${job.toString()}');
    }
    setState(() {
      _savedJobs = jobsList;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _savedJobs.isEmpty
              ? Center(
                  child: Text('No saved jobs yet.',
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
                    // Compose a job map with all fields needed by the detail screen
                    final detailJob = <String, dynamic>{
                      'id': job['job_id'],
                      'title': jobData['title'],
                      'company': jobData['company'],
                      'salary': jobData['salary'],
                      'country': jobData['country'],
                      'deadline': jobData['deadline'],
                      'description':
                          jobData['job_description'] ?? jobData['description'],
                      'requirements': jobData['requirements'],
                      'email': jobData['email'],
                      'company_website': jobData['company_website'],
                      'application_link': jobData['application_link'],
                      'contact_phone': jobData['contact_phone'],
                      'category': jobData['category'],
                    };
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(jobData['title'] ?? '',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(jobData['company'] ?? '',
                                style: GoogleFonts.montserrat()),
                            Text('Salary: ${jobData['salary'] ?? ''}',
                                style: GoogleFonts.montserrat(fontSize: 12)),
                            Text('Country: ${jobData['country'] ?? ''}',
                                style: GoogleFonts.montserrat(fontSize: 12)),
                            Text('Deadline: ${jobData['deadline'] ?? ''}',
                                style: GoogleFonts.montserrat(
                                    fontSize: 12, color: Colors.red)),
                          ],
                        ),
                        trailing:
                            Icon(Icons.bookmark, color: Colors.amber[800]),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/job_detail',
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved'),
        ],
      ),
    );
  }
}
