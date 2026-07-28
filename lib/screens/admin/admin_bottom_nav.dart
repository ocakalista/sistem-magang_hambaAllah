import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import 'admin_dashboard_screen.dart';
import 'lowongan_screen.dart';
import 'pengguna_screen.dart';
import 'profile_screen.dart';

void navigateAdminTab(
  BuildContext context, {
  required int currentIndex,
  required int destinationIndex,
}) {
  if (currentIndex == destinationIndex) return;
  final Widget page = switch (destinationIndex) {
    0 => const AdminDashboardScreen(),
    1 => const LowonganScreen(),
    2 => const PenggunaScreen(),
    _ => const AdminProfileScreen(),
  };
  Navigator.of(
    context,
  ).pushAndRemoveUntil(nexusTabRoute(page), (route) => route.isFirst);
}

class AdminBottomNav extends StatelessWidget {
  const AdminBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.primary.withValues(alpha: 0.12),
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: tr('Home'),
        ),
        NavigationDestination(
          icon: Icon(Icons.work_outline_rounded),
          selectedIcon: Icon(Icons.work_rounded),
          label: tr('Lowongan'),
        ),
        NavigationDestination(
          icon: Icon(Icons.group_outlined),
          selectedIcon: Icon(Icons.group_rounded),
          label: tr('Pengguna'),
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded),
          selectedIcon: Icon(Icons.person_rounded),
          label: tr('Profil'),
        ),
      ],
    );
  }
}
