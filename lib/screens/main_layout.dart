import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'job_list_screen.dart';
import 'profile_screen.dart';

class JobPopMainLayout extends StatefulWidget {
  const JobPopMainLayout({super.key});

  @override
  State<JobPopMainLayout> createState() => _JobPopMainLayoutState();
}

class _JobPopMainLayoutState extends State<JobPopMainLayout> {
  int selectedIndex = 1;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }
    final profiles = await Supabase.instance.client
        .from('profiles')
        .select()
        .or('email.eq.${user.email},phone.eq.${user.phone}')
        .maybeSingle();
    setState(() {
      userProfile = profiles;
      isLoading = false;
    });
  }

  List<Widget> get pages => [
        const ProfileScreen(),
        const JobListScreen(),
        const Center(child: Text('Logging out...')),
      ];

  void onItemTapped(int index) {
    if (index == 2) {
      showLogoutConfirmation();
    } else {
      setState(() {
        selectedIndex = index;
      });
    }
  }

  Future<void> showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD62828),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await handleLogout();
    }
  }

  Future<void> handleLogout() async {
    setState(() {
      selectedIndex = 2;
    });
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      // Use pushReplacementNamed for mobile, and pop to root for web
      // This ensures correct navigation for all platforms
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  void handleNotificationTap() {
    debugPrint('Notifications tapped');
    // TODO: Show notification overlay or navigate to notification screen
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final avatar =
        userProfile?['avatar_url'] ?? userProfile?['profile_photo_url'] ?? '';
    final name =
        userProfile?['full_name'] ?? userProfile?['username'] ?? 'User';
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.yellow[100],
        title: Row(
          children: [
            if (avatar != null && avatar.isNotEmpty)
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(avatar),
                backgroundColor: Colors.grey[200],
              )
            else
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.white),
              ),
            const SizedBox(width: 12),
            Text(
              name,
              style: GoogleFonts.montserrat(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: handleNotificationTap,
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.logout),
            label: 'Logout',
          ),
        ],
      ),
    );
  }
}
