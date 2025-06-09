// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Screens (HEPSİ ESKİ GİBİ)
import 'theme/app_colors.dart';
import 'screens/sign_up_screen.dart';
import 'screens/sign_up_screen_2.dart';
import 'screens/sign_in_screen.dart';
import 'screens/home_screen.dart';
import 'screens/account_screen.dart';
import 'screens/account_verification_screen.dart';
import 'screens/timeline_screen.dart';
import 'screens/notification_detail_screen.dart';

// 🔵 YENİ: push servisini ekledik
import 'core/services/push_notification_service.dart';

import 'models/analysis_notification.dart';


// ───────────────────────────────────────────────────────────────
//  yalnızca bildirim tıklamasında sayfa açmak için gereken key
final GlobalKey<NavigatorState> globalNavKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.instance
      .getToken()
      .then((t) => debugPrint('RAGOS TOKEN ⇒ $t'));

  // 🔵 push servisini başlat
  await PushNotificationService.init();

  runApp(const RagosApp());
}

class RagosApp extends StatelessWidget {
  const RagosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return MaterialApp(
          navigatorKey: globalNavKey,           // ◀️ TEK YENİ SATIR
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
            '/sign_in'   : (_) => const SignInScreen(),
            '/sign_up'   : (_) => const SignUpScreen(),
            '/sign_up_2' : (_) => const SignUpScreen2(),
            '/verify'    : (_) => const AccountVerificationScreen(),
            '/home'      : (_) => const HomeScreen(),
            '/account'   : (_) => const AccountScreen(),
            '/config'    : (_) => const ConfigScreen(),
            '/timeline'  : (_) => const TimelineScreen(),
            '/notification_detail': (context) {
              final notif = ModalRoute.of(context)!.settings.arguments
                  as AnalysisNotification;             // güvenli cast
              return NotificationDetailScreen(notification: notif);
            },
          },
        );
      },
    );
  }
}

/// Placeholder for Config screen (ESKİ HÂLİYLE)
class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Config'),
          backgroundColor: Colors.black,
        ),
        body: const Center(
          child: Text('Config Screen', style: TextStyle(color: Colors.white)),
        ),
      );
}
