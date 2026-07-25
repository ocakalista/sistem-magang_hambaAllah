import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/logout_button.dart';
import '../../models/nexus_app_state.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/dosen_bottom_nav.dart';
import '../notification_settings_screen.dart';
import '../notifications_screen.dart';
import 'dosen_dashboard_screen.dart';
import 'students_screen.dart';

class DosenProfileScreen extends StatelessWidget {
  static const routeName = '/dosen/profile';

  const DosenProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = NexusScope.of(context);
    final user =
        state.currentUser ?? const <String, dynamic>{};
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
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
                        Icons.person,
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
                            state.currentDisplayName,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Dosen',
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
                Icons.email_rounded,
                'Email / NIDN',
                state.currentUserValue(const [
                      'email_or_nim',
                      'nidn',
                      'email',
                    ]) ??
                    '-',
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                context,
                Icons.phone_rounded,
                'Telepon',
                state.currentUserValue(const [
                      'phone',
                      'no_telp',
                      'telepon',
                    ]) ??
                    '-',
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                context,
                Icons.badge_rounded,
                'Role',
                user['role']?.toString() ?? 'dosen',
              ),
              const SizedBox(height: 24),
              Text(
                'Akun & preferensi',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      NotificationSettingsScreen.routeName,
                    ),
              ),
              const SizedBox(height: 12),
              const LogoutButton(),
              const SizedBox(height: 24),
              Text(
                'Profil Dosen ini akan dikembangkan lebih lanjut untuk menampilkan data bimbingan dan jumlah mahasiswa.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DosenBottomNav(
        selectedIndex: 3,
        onDestinationSelected: (index) => _handleNavigation(context, index),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 3) return;
    if (index == 0) {
      var dashboardFound = false;
      Navigator.of(context).popUntil((route) {
        if (route.settings.name == DosenDashboardScreen.routeName) {
          dashboardFound = true;
          return true;
        }
        return route.isFirst;
      });
      if (!dashboardFound && context.mounted) {
        Navigator.pushReplacement(
          context,
          nexusTabRoute(const DosenDashboardScreen()),
        );
      }
      return;
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        nexusTabRoute(const StudentsScreen()),
      );
      return;
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        nexusTabRoute(const NotificationsScreen()),
      );
    }
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

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String label, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap:
          onTap ??
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fitur ini belum tersedia di backend.'),
            ),
          ),
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
