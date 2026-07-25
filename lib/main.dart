import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/mitra_provider.dart';
import 'models/nexus_app_state.dart';
import 'screens/mahasiswa/dashboard_mahasiswa.dart';
import 'screens/mahasiswa/all_internships_screen.dart';
import 'screens/login_screen.dart';
import 'screens/mahasiswa/profile_screen.dart';
import 'screens/mitra/kelola_lowongan_screen.dart';
import 'screens/mitra/mitra_dashboard_screen.dart';
import 'screens/mitra/profile_screen.dart';
import 'screens/mitra/tambah_lowongan_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/dosen/dosen_dashboard_screen.dart';
import 'screens/dosen/profile_screen.dart';
import 'screens/dosen/weekly_report_detail_screen.dart';
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
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MitraProvider())],
      child: NexusScope(
        notifier: _appState,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Nexus',
          theme: AppTheme.lightTheme,
          initialRoute: SplashScreen.routeName,
          // TODO: Enhance role-based routing to protect all role-specific routes behind auth+role checks
          // - Admin routes: /admin (requires UserRole.admin)
          // - Dosen routes: /dosen (requires UserRole.dosen), /dosen/weekly-report-detail
          // - Student routes: /dashboard (requires UserRole.student)
          // - Mitra routes: /mitra/dashboard, /mitra/kelola-lowongan, /mitra/tambah-lowongan, /mitra/profile (requires UserRole.mitra)
          // Currently protected via RoleGuard wrapper, but consider moving to onGenerateRoute for centralized control
          routes: {
            SplashScreen.routeName: (_) => const SplashScreen(),
            OnboardingScreen.routeName: (_) => const OnboardingScreen(),
            LoginScreen.routeName: (_) => const LoginScreen(),
            DashboardMahasiswa.routeName: (_) => const DashboardMahasiswa(),
            AllInternshipsScreen.routeName:
                (_) => const RoleGuard(
                  requiredRole: UserRole.student,
                  child: AllInternshipsScreen(),
                ),
            AdminDashboardScreen.routeName:
                (_) => const RoleGuard(
                  requiredRole: UserRole.admin,
                  child: AdminDashboardScreen(),
                ),
            DosenDashboardScreen.routeName:
                (_) => const RoleGuard(
                  requiredRole: UserRole.dosen,
                  child: DosenDashboardScreen(),
                ),
            WeeklyReportDetailScreen.routeName:
                (_) => Builder(
                  builder: (context) {
                    final args =
                        ModalRoute.of(context)?.settings.arguments
                            as Map<String, dynamic>?;
                    if (args == null) {
                      return const Scaffold(
                        body: Center(child: Text('Invalid report data')),
                      );
                    }
                    return WeeklyReportDetailScreen(
                      report: args['report'],
                      student: args['student'],
                    );
                  },
                ),
            NotificationsScreen.routeName: (_) => const NotificationsScreen(),
            NotificationSettingsScreen.routeName:
                (_) => const NotificationSettingsScreen(),
            DashboardMahasiswaProfileScreen.routeName:
                (_) => const DashboardMahasiswaProfileScreen(),
            DosenProfileScreen.routeName: (_) => const DosenProfileScreen(),
            MitraDashboardScreen.routeName:
                (_) => const RoleGuard(
                  requiredRole: UserRole.mitra,
                  child: MitraDashboardScreen(),
                ),
            MitraKelolaLowonganScreen.routeName:
                (_) => const RoleGuard(
                  requiredRole: UserRole.mitra,
                  child: MitraKelolaLowonganScreen(),
                ),
            TambahLowonganScreen.routeName:
                (_) => const RoleGuard(
                  requiredRole: UserRole.mitra,
                  child: TambahLowonganScreen(),
                ),
            MitraProfileScreen.routeName:
                (_) => const RoleGuard(
                  requiredRole: UserRole.mitra,
                  child: MitraProfileScreen(),
                ),
          },
        ),
      ),
    );
  }
}
