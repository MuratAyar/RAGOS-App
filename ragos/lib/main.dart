// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Screens
import 'theme/app_colors.dart';
import 'screens/sign_up_screen.dart';
import 'screens/sign_up_screen_2.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'screens/account_screen.dart';
import 'screens/account_verification_screen.dart'; // <-- ADD THIS IMPORT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const RagosApp());
}

class RagosApp extends StatelessWidget {
  const RagosApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return MaterialApp(
          title: 'RAGOS',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            useMaterial3: true,
          ),
          initialRoute: user == null ? '/sign_up' : '/home',
          routes: {
            '/sign_in' : (_) => const SignInScreen(),
            '/sign_up' : (_) => const SignUpScreen(),
            '/sign_up_2' : (_) => const SignUpScreen2(),
            '/verify' : (_) => const AccountVerificationScreen(),
            '/home' : (_) => const HomeScreen(),
            '/account' : (_) => const AccountScreen(),
            '/config' : (_) => const ConfigScreen(),
            '/report' : (_) => const ReportScreen(),
          },
        );
      },
    );
  }
}

/// Placeholder for Config screen
class ConfigScreen extends StatelessWidget {
  const ConfigScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Config'),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Config Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

/// Placeholder for Report screen
class ReportScreen extends StatelessWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Report'),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          'Report Screen',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
