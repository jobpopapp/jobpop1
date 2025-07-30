import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/manual_localization.dart';
import '../utils/language_provider.dart';

class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key});

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final supabase = Supabase.instance.client;
  String username = '';
  String? userEmail;
  String? userPhone;
  String? profilePhotoUrl;
  int newJobsCount = 3; // Replace with actual logic if needed
  int _selectedIndex = 1;
  List<Map<String, dynamic>> jobs = [];
  bool isLoading = true;
  String _selectedLocation = 'Abroad';
  String? _selectedCategory = 'All Jobs';

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    fetchJobs();
  }

  Future<void> fetchUserProfile() async {
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

  Future<void> _confirmAndLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _logout();
    }
  }

  Future<void> _logout() async {
    await supabase.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('phone_login');
    if (mounted) {
      Navigator.of(context, rootNavigator: true)
          .popUntil((route) => route.isFirst);
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  Future<void> fetchJobs() async {
    setState(() {
      isLoading = true;
    });
    debugPrint('fetchJobs() called');
    try {
      debugPrint('Fetching jobs...');
      debugPrint('Selected location: $_selectedLocation');
      debugPrint('Selected category: $_selectedCategory');
      var query = supabase.from('jobs').select();
      bool filterAbroadClientSide = false;

      // Apply filters before ordering
      if (_selectedLocation == 'Uganda') {
        debugPrint('Applying filter: country ilike %uganda%');
        query = query.ilike('country', '%uganda%');
      } else if (_selectedLocation == 'Abroad') {
        debugPrint('Applying filter: country not.ilike %uganda%');
        query = query.not('country', 'ilike', '%uganda%');
      }
      if (_selectedCategory != null &&
          _selectedCategory != 'All Jobs' &&
          _selectedCategory!.isNotEmpty) {
        debugPrint('Applying filter: category == $_selectedCategory');
        query = query.eq('category', _selectedCategory!);
      }
      // Now order by deadline (do not reassign to query, just chain)
      final response = await query.order('deadline', ascending: true);
      debugPrint('Supabase response: ${response.runtimeType} $response');
      List<Map<String, dynamic>> result =
          List<Map<String, dynamic>>.from(response);
      if (filterAbroadClientSide) {
        debugPrint(
            'Filtering out jobs with country == Uganda (client-side abroad filter)');
        result = result
            .where((job) =>
                (job['country'] ?? '').toString().trim().toLowerCase() !=
                'uganda')
            .toList();
      }
      setState(() {
        jobs = result;
        isLoading = false;
      });
    } catch (e, st) {
      debugPrint('Error fetching jobs: $e');
      debugPrint(st.toString());
      setState(() {
        jobs = [];
        isLoading = false;
      });
    }
    debugPrint('fetchJobs() completed');
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale.languageCode;
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
                    username.isNotEmpty ? username : t('profile', lang),
                    style: GoogleFonts.montserrat(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (userEmail != null && userEmail!.isNotEmpty)
                    Text(
                      userEmail!,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 122, 0, 0),
                      ),
                    ),
                  if (userPhone != null && userPhone!.isNotEmpty)
                    Text(
                      userPhone!,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: const Color.fromARGB(255, 105, 0, 0),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _confirmAndLogout,
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: t('logout', lang),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t('findAJobAnywhere', lang),
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: InputDecoration(
                labelText: t('chooseLocation', lang),
                labelStyle: GoogleFonts.montserrat(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: GoogleFonts.montserrat(
                color: Colors.black,
                fontSize: 16,
              ),
              items: [
                DropdownMenuItem(
                    value: 'Uganda', child: Text(t('uganda', lang))),
                DropdownMenuItem(
                    value: 'Abroad', child: Text(t('abroad', lang))),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value ?? 'Abroad';
                });
              },
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t('pleaseSelectJobCategory', lang),
                style: const TextStyle(color: Color(0xFFD62828)),
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: t('jobCategory', lang),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: [
                DropdownMenuItem(
                    value: 'All Jobs',
                    child: Text(t('allJobs', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Domestic Work',
                    child: Text(t('domesticWork', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Construction & Manual Labor',
                    child: Text(t('constructionManualLabor', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Security Services',
                    child: Text(t('securityServices', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Driving & Transport',
                    child: Text(t('drivingTransport', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Hospitality & Tourism',
                    child: Text(t('hospitalityTourism', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Healthcare & Nursing',
                    child: Text(t('healthcareNursing', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Education & Teaching',
                    child: Text(t('educationTeaching', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Sales & Retail',
                    child: Text(t('salesRetail', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Agriculture & Farming',
                    child: Text(t('agricultureFarming', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Cleaning & Maintenance',
                    child: Text(t('cleaningMaintenance', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'IT & Technical',
                    child: Text(t('itTechnical', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Office & Administration',
                    child: Text(t('officeAdministration', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Beauty & Personal Care',
                    child: Text(t('beautyPersonalCare', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Artisan & Skilled Trades',
                    child: Text(t('artisanSkilledTrades', lang),
                        style: const TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Other',
                    child: Text(t('other', lang),
                        style: const TextStyle(fontSize: 12))),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  fetchJobs();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(t('search', lang),
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : jobs.isEmpty
                      ? Center(
                          child: Text(t('noJobsFound', lang),
                              style: GoogleFonts.montserrat()))
                      : ListView.separated(
                          padding: const EdgeInsets.only(top: 0),
                          itemCount: jobs.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final job = jobs[index];
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
                                    Text(
                                        t('category', lang) +
                                            ': ${job['category'] ?? ''}',
                                        style: GoogleFonts.montserrat(
                                            fontSize: 12)),
                                    Text(
                                        t('salary', lang) +
                                            ': ${job['salary'] ?? ''}',
                                        style: GoogleFonts.montserrat(
                                            fontSize: 12)),
                                    Text(
                                        t('country', lang) +
                                            ': ${job['country'] ?? ''}',
                                        style: GoogleFonts.montserrat(
                                            fontSize: 12)),
                                    if ((job['city'] ?? '')
                                        .toString()
                                        .isNotEmpty)
                                      Text(t('city', lang) + ': ${job['city']}',
                                          style: GoogleFonts.montserrat(
                                              fontSize: 12)),
                                    // Deadline: bold, red if past, green if future
                                    Builder(
                                      builder: (context) {
                                        final deadlineStr =
                                            job['deadline'] ?? '';
                                        DateTime? deadline;
                                        try {
                                          if (deadlineStr is String &&
                                              deadlineStr.isNotEmpty) {
                                            deadline =
                                                DateTime.tryParse(deadlineStr);
                                          }
                                        } catch (_) {}
                                        final now = DateTime.now();
                                        final isPast = deadline != null &&
                                            deadline.isBefore(now);
                                        return Text(
                                          t('deadline', lang) +
                                              ': $deadlineStr',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: deadline == null
                                                ? Colors.black
                                                : isPast
                                                    ? const Color.fromARGB(
                                                        255, 187, 27, 16)
                                                    : const Color.fromARGB(
                                                        255, 41, 145, 44),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                // Removed bookmark icon from job list
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/job-detail',
                                    arguments: job,
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
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
            Navigator.pushReplacementNamed(context, '/saved-jobs');
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

  // Helper for dropdown items with bottom border
  DropdownMenuItem<String> _buildDropdownMenuItem(String value, String label) {
    return DropdownMenuItem(
      value: value,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 0.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(label, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}
