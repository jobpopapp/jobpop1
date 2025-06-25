import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/job_list_screen.dart';
import 'screens/job_detail_screen.dart';
import 'screens/saved_jobs_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://snokjbcheiivdrafmtyc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNub2tqYmNoZWlpdmRyYWZtdHljIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3Njc0MjQsImV4cCI6MjA2NjM0MzQyNH0.K6AGHXAKno8fBJwgGvWR-7eN0C8qs3OmoZPsqxfylzM',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Pop',
      theme: ThemeData(
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: const Color(0xFFD62828), // Red
          onPrimary: Colors.white,
          secondary: const Color(0xFFFFD23F), // Yellow
          onSecondary: Colors.black,
          background: Colors.white,
          onBackground: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.montserratTextTheme(),
        fontFamily: GoogleFonts.montserrat().fontFamily,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFFD62828),
            foregroundColor: Colors.white,
            textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const MyHomePage(title: 'Job Pop'),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/jobs': (context) => const JobListScreen(),
        '/job-detail': (context) => const JobDetailScreen(),
        '/saved-jobs': (context) => const SavedJobsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/job_list': (context) =>
            const JobListScreen(), // Added for phone-only signup
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset(
                'assets/logo.png',
                width: 250,
                height: 250,
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 4),
              Text(
                'MAKING IT EASY',
                style: GoogleFonts.montserrat(
                  color: Colors.white54,
                  fontSize: 12,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'Find a job',
                      style: const TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: ' or Hire',
                      style: const TextStyle(color: Color(0xFFD62828)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD23F),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 64, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'LOGIN',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: Text(
                  'Create new user account ?',
                  style: GoogleFonts.montserrat(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Add navigation if needed
                },
                child: Text(
                  'Create new company account ?',
                  style: GoogleFonts.montserrat(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (_) {},
                    side: const BorderSide(color: Colors.white),
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                  ),
                  Text(
                    'Luganda',
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Checkbox(
                    value: true,
                    onChanged: (_) {},
                    side: const BorderSide(color: Colors.white),
                    checkColor: Colors.black,
                    activeColor: Colors.white,
                  ),
                  Text(
                    'English',
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                'All Jobs listed are from verified companies\nApp is Regulated by the Government of Uganda',
                style: GoogleFonts.montserrat(
                  color: const Color(0xFFFFD23F),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
