import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/mitra_bottom_nav.dart';
import '../../screens/mitra/mitra_dashboard_screen.dart';
import '../../screens/mitra/kelola_lowongan_screen.dart';
import '../../screens/notifications_screen.dart';

class MitraProfileScreen extends StatelessWidget {
  static const routeName = '/mitra/profile';

  const MitraProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            'TODO: Profile Mitra akan dikembangkan di sini.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.neutral),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      bottomNavigationBar: MitraBottomNavigationBar(
        selectedIndex: 3,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(
                context,
                MitraDashboardScreen.routeName,
              );
              break;
            case 1:
              Navigator.pushReplacementNamed(
                context,
                MitraKelolaLowonganScreen.routeName,
              );
              break;
            case 2:
              Navigator.pushReplacementNamed(
                context,
                NotificationsScreen.routeName,
              );
              break;
            case 3:
              break;
          }
        },
      ),
    );
  }
}
