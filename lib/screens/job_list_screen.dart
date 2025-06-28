import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
        username = profile?['username'] ?? 'User';
        userEmail = profile?['email'] ?? '';
        userPhone = profile?['phone'] ?? '';
        // Prefer Google avatar if available, else use profile table
        profilePhotoUrl =
            user.userMetadata?['avatar_url'] ?? profile?['profile_photo_url'];
      });
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
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
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              items: [
                _buildDropdownMenuItem('Domestic Work',
                    'Domestic Work (Housekeeping, Nanny, Maid)'),
                _buildDropdownMenuItem('Construction & Manual Labor',
                    'Construction & Manual Labor'),
                _buildDropdownMenuItem(
                    'Security Services', 'Security Services (Guard, Bouncer)'),
                _buildDropdownMenuItem('Driving & Transport',
                    'Driving & Transport (Driver, Rider, Conductor)'),
                _buildDropdownMenuItem('Hospitality & Tourism',
                    'Hospitality & Tourism (Waiter, Chef, Hotel Staff)'),
                _buildDropdownMenuItem(
                    'Healthcare & Nursing', 'Healthcare & Nursing'),
                _buildDropdownMenuItem(
                    'Education & Teaching', 'Education & Teaching'),
                _buildDropdownMenuItem('Sales & Retail',
                    'Sales & Retail (Shop Attendant, Cashier)'),
                _buildDropdownMenuItem(
                    'Agriculture & Farming', 'Agriculture & Farming'),
                _buildDropdownMenuItem(
                    'Cleaning & Maintenance', 'Cleaning & Maintenance'),
                _buildDropdownMenuItem('IT & Technical',
                    'IT & Technical (Computer, Telecom, Engineering)'),
                _buildDropdownMenuItem(
                    'Office & Administration', 'Office & Administration'),
                _buildDropdownMenuItem('Beauty & Personal Care',
                    'Beauty & Personal Care (Salon, Barber, Spa)'),
                _buildDropdownMenuItem('Artisan & Skilled Trades',
                    'Artisan & Skilled Trades (Tailor, Carpenter, Mechanic)'),
                _buildDropdownMenuItem('Other', 'Other'),
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
