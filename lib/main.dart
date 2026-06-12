import 'package:flutter/material.dart';

import 'models/nexus_app_state.dart';
import 'screens/dashboard_mahasiswa.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const NexusApp());
}

class NexusApp extends StatefulWidget {
  const NexusApp({super.key});

  @override
  State<NexusApp> createState() => _NexusAppState();
}

class _NexusAppState extends State<NexusApp> {
  final NexusAppState _appState = NexusAppState();

  @override
  Widget build(BuildContext context) {
    return NexusScope(
      notifier: _appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Nexus',
        theme: AppTheme.lightTheme,
        initialRoute: SplashScreen.routeName,
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          OnboardingScreen.routeName: (_) => const OnboardingScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          DashboardMahasiswa.routeName: (_) => const DashboardMahasiswa(),
        },
      ),
    );
  }
}
