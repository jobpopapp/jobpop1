import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  String userEmail = '';
  String userPhone = '';
  String? profilePhotoUrl;

  @override
  void initState() {
    super.initState();
    _fetchSavedJobs();
  }

  Future<void> _fetchSavedJobs() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) {
      setState(() {
        _savedJobs = [];
        _loading = false;
      });
      return;
    }
    final response = await supabase
        .from('saved_jobs') // Table name matches job details page
        .select(
            'job_id, jobs:title, jobs:company, jobs:salary, jobs:country, jobs:deadline, jobs:description, jobs:requirements, jobs:email, jobs:company_website, jobs:application_link, jobs:contact_phone')
        .eq('user_id', user.id)
        .order('id', ascending: false);
    setState(() {
      _savedJobs = List<Map<String, dynamic>>.from(response);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: const Color(0xFFFFD23F),
        elevation: 0,
        title: Row(
          children: [
            if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(profilePhotoUrl!),
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
                  if (userEmail.isNotEmpty)
                    Text(
                      userEmail,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Color.fromARGB(255, 122, 0, 0),
                      ),
                    ),
                  if (userPhone.isNotEmpty)
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
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        title: Text(job['jobs:title'] ?? '',
                            style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(job['jobs:company'] ?? '',
                                style: GoogleFonts.montserrat()),
                            Text('Salary: ${job['jobs:salary'] ?? ''}',
                                style: GoogleFonts.montserrat(fontSize: 12)),
                            Text('Country: ${job['jobs:country'] ?? ''}',
                                style: GoogleFonts.montserrat(fontSize: 12)),
                            Text('Deadline: ${job['jobs:deadline'] ?? ''}',
                                style: GoogleFonts.montserrat(
                                    fontSize: 12, color: Colors.red)),
                          ],
                        ),
                        trailing:
                            Icon(Icons.bookmark, color: Colors.amber[800]),
                        onTap: () {
                          // Map job_description to description for detail screen
                          Navigator.pushNamed(
                            context,
                            '/job_detail',
                            arguments: {
                              'id': job['job_id'],
                              'title': job['jobs:title'],
                              'company': job['jobs:company'],
                              'salary': job['jobs:salary'],
                              'country': job['jobs:country'],
                              'deadline': job['jobs:deadline'],
                              'description': job['jobs:job_description'],
                              'requirements': job['jobs:requirements'],
                              'email': job['jobs:email'],
                              'company_website': job['jobs:company_website'],
                              'application_link': job['jobs:application_link'],
                              'contact_phone': job['jobs:contact_phone'],
                            },
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
