import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        titleSpacing: 16,
        backgroundColor: const Color(0xFFFFD23F), // Yellowish
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
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Find a job anywhere',
                style: GoogleFonts.montserrat(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Choose location',
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
              items: const [
                DropdownMenuItem(value: 'Uganda', child: Text('Uganda')),
                DropdownMenuItem(value: 'Abroad', child: Text('Abroad')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Please select a job category',
                style: TextStyle(color: Color(0xFFD62828)),
              ),
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Job Category *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'Domestic Work',
                    child: Text('Domestic Work (Housekeeping, Nanny, Maid)',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Construction & Manual Labor',
                    child: Text('Construction & Manual Labor',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Security Services',
                    child: Text('Security Services (Guard, Bouncer)',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Driving & Transport',
                    child: Text(
                        'Driving & Transport (Driver, Rider, Conductor)',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Hospitality & Tourism',
                    child: Text(
                        'Hospitality & Tourism (Waiter, Chef, Hotel Staff)',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Healthcare & Nursing',
                    child: Text('Healthcare & Nursing',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Education & Teaching',
                    child: Text('Education & Teaching',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Sales & Retail',
                    child: Text('Sales & Retail (Shop Attendant, Cashier)',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Agriculture & Farming',
                    child: Text('Agriculture & Farming',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Cleaning & Maintenance',
                    child: Text('Cleaning & Maintenance',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'IT & Technical',
                    child: Text(
                        'IT & Technical (Computer, Telecom, Engineering)',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Office & Administration',
                    child: Text('Office & Administration',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Beauty & Personal Care',
                    child: Text('Beauty & Personal Care (Salon, Barber, Spa)',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Artisan & Skilled Trades',
                    child: Text(
                        'Artisan & Skilled Trades (Tailor, Carpenter, Mechanic)',
                        style: TextStyle(fontSize: 12))),
                DropdownMenuItem(
                    value: 'Other',
                    child: Text('Other', style: TextStyle(fontSize: 12))),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Trigger job search
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('SEARCH',
                    style: GoogleFonts.montserrat(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: (index) {
          // Handle navigation between tabs
        },
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Jobs'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_none),
                if (newJobsCount > 0)
                  Positioned(
                    right: 0,
                    top: 1,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD62828),
                      ),
                      child: Text(
                        '$newJobsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Alerts',
          ),
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
