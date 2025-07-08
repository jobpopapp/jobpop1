import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:app_links/app_links.dart';
import 'utils/language_provider.dart';
import 'utils/manual_localization.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/job_list_screen.dart';
import 'screens/job_detail_screen.dart';
import 'screens/saved_jobs_screen.dart';
import 'screens/profile_screen.dart';
import 'dart:ui';

void main() async {
  // Keep the splash screen visible during initialization
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://snokjbcheiivdrafmtyc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNub2tqYmNoZWlpdmRyYWZtdHljIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA3Njc0MjQsImV4cCI6MjA2NjM0MzQyNH0.K6AGHXAKno8fBJwgGvWR-7eN0C8qs3OmoZPsqxfylzM',
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider()..loadLocale(),
      child: const MyApp(),
    ),
  );

  // Remove the splash screen once the app is ready
  FlutterNativeSplash.remove();
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
  }

  void _handleIncomingLinks() {
    // Handle incoming links when app is already running
    _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    }, onError: (err) {
      print('Deep link error: $err');
    });

    // Handle initial link if app was launched from a link
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    print('Received deep link: $uri');
    
    // Handle Supabase OAuth redirect
    if (uri.scheme == 'jobpopp') {
      print('Handling jobpopp deep link: $uri');
      
      try {
        // Handle auth callback specifically
        if (uri.host == 'auth-callback' || uri.path.contains('auth-callback')) {
          print('Processing auth callback from URL: $uri');
          Supabase.instance.client.auth.getSessionFromUrl(uri);
        } else if (uri.fragment.isNotEmpty || uri.queryParameters.isNotEmpty) {
          print('Processing auth session from URL: $uri');
          Supabase.instance.client.auth.getSessionFromUrl(uri);
        } else {
          print('Deep link received but no auth parameters found');
        }
      } catch (e) {
        print('Error processing deep link: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale.languageCode;
    return MaterialApp(
      title: t('appTitle', lang),
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
      home: MyHomePage(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/jobs': (context) => const JobListScreen(),
        '/job-detail': (context) => const JobDetailScreen(),
        '/saved-jobs': (context) => const SavedJobsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/job_list': (context) => const JobListScreen(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context).locale.languageCode;
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
                t('slogan', lang),
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
                      text: t('findAJobAnywhere', lang),
                      style: const TextStyle(color: Colors.white),
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
                  t('login', lang),
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
                  t('signup', lang),
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
                  Radio<String>(
                    value: 'lg',
                    groupValue: lang,
                    onChanged: (val) {
                      if (val != null) {
                        Provider.of<LanguageProvider>(context, listen: false)
                            .setLocale(val);
                      }
                    },
                    activeColor: Colors.white,
                  ),
                  Text(
                    t('luganda', lang),
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Radio<String>(
                    value: 'en',
                    groupValue: lang,
                    onChanged: (val) {
                      if (val != null) {
                        Provider.of<LanguageProvider>(context, listen: false)
                            .setLocale(val);
                      }
                    },
                    activeColor: Colors.white,
                  ),
                  Text(
                    t('english', lang),
                    style: GoogleFonts.montserrat(color: Colors.white),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                t('footerNote', lang),
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
