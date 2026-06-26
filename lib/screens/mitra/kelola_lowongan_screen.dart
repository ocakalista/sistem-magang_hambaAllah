import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/mitra_bottom_nav.dart';
import '../mitra/mitra_dashboard_screen.dart';
import '../mitra/profile_screen.dart';
import '../../screens/notifications_screen.dart';

class MitraKelolaLowonganScreen extends StatelessWidget {
  static const routeName = '/mitra/kelola-lowongan';

  const MitraKelolaLowonganScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          'Kelola Lowongan',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TODO: Kelola semua Lowongan Mitra di sini.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.neutral),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daftar Lowongan akan ditampilkan di sini setelah integrasi backend.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sementara ini, gunakan dashboard untuk menambah lowongan dan melihat ringkasan stat.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: MitraBottomNavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(
                context,
                MitraDashboardScreen.routeName,
              );
              break;
            case 1:
              break;
            case 2:
              Navigator.pushReplacementNamed(
                context,
                NotificationsScreen.routeName,
              );
              break;
            case 3:
              Navigator.pushReplacementNamed(
                context,
                MitraProfileScreen.routeName,
              );
              break;
          }
        },
      ),
    );
  }
}
