import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/app_state.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/home_screen.dart';
import 'screens/presets_screen.dart';
import 'screens/info_screen.dart';
import 'screens/privacy_policy_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const FakeNotificationApp(),
    ),
  );
}

class FakeNotificationApp extends StatelessWidget {
  const FakeNotificationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fake Notification',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/permissions': (context) => const PermissionsScreen(),
        '/home': (context) => const HomeScreen(),
        '/presets': (context) => const PresetsScreen(),
        '/info': (context) => const InfoScreen(),
        '/privacy': (context) => const PrivacyPolicyScreen(),
      },
    );
  }
}
