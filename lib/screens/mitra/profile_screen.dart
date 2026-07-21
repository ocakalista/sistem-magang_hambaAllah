import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/app_theme.dart';
import '../../widgets/mitra_bottom_nav.dart';
import '../../models/mitra_provider.dart';
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
        child: Consumer<MitraProvider>(
          builder: (context, mitraProvider, _) {
            final info = mitraProvider.info;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.16,
                          ),
                          child: const Icon(
                            Icons.business,
                            color: AppColors.primary,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info.companyName,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'User ID: ${info.idUser}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.neutral),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoTile(
                    context,
                    Icons.business_outlined,
                    'Nama Perusahaan',
                    info.companyName,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoTile(
                    context,
                    Icons.person_outline_rounded,
                    'ID User',
                    info.idUser,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Akun & preferensi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    Icons.lock_outline_rounded,
                    'Ubah Kata Sandi',
                  ),
                  const SizedBox(height: 12),
                  _buildActionTile(
                    context,
                    Icons.settings_outlined,
                    'Pengaturan Notifikasi',
                  ),
                ],
              ),
            );
          },
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

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, IconData icon, String label) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.secondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.neutral),
          ],
        ),
      ),
    );
  }
}
