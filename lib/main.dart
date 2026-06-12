import 'package:flutter/material.dart';

import 'models/nexus_app_state.dart';
import 'screens/dashboard_mahasiswa.dart';
import 'screens/login_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'widgets/role_guard.dart';
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
        // TODO: Implement role-based routing / protect admin routes behind an auth+role check
        routes: {
          SplashScreen.routeName: (_) => const SplashScreen(),
          OnboardingScreen.routeName: (_) => const OnboardingScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          DashboardMahasiswa.routeName: (_) => const DashboardMahasiswa(),
          AdminDashboardScreen.routeName: (_) => const RoleGuard(
                requiredRole: UserRole.admin,
                child: AdminDashboardScreen(),
              ),
          NotificationsScreen.routeName: (_) => const NotificationsScreen(),
        },
      ),
    );
  }
}
