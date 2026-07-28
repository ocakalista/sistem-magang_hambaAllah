import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';

import '../../theme/app_theme.dart';
import '../../widgets/logout_button.dart';
import '../../models/nexus_app_state.dart';
import '../../widgets/bottom_nav.dart';
import '../notification_settings_screen.dart';
import '../notifications_screen.dart';
import 'application_history_screen.dart';
import 'dashboard_mahasiswa.dart';
import 'edit_profile_screen.dart';

class DashboardMahasiswaProfileScreen extends StatelessWidget {
  static const routeName = '/mahasiswa/profile';

  const DashboardMahasiswaProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        NexusScope.of(context).currentUser ?? const <String, dynamic>{};
    final name = _profileValue(user, const ['name', 'nama_lengkap', 'nama']);
    final identifier = _profileValue(user, const [
      'email_or_nim',
      'nim',
      'email',
    ]);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          TextButton.icon(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditMahasiswaProfileScreen(),
                  ),
                ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit'),
          ),
          const SizedBox(width: 8),
        ],
      ),
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
                            name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mahasiswa',
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
                'Email / NIM',
                identifier,
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                context,
                Icons.school_rounded,
                'Semester',
                _profileValue(user, const ['semester']),
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                context,
                Icons.phone_rounded,
                'Telepon',
                _profileValue(user, const ['phone', 'no_telp', 'telepon']),
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
                Icons.settings_outlined,
                'Pengaturan',
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
                'Profil ini akan dikembangkan lebih lanjut untuk Mahasiswa.',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NexusBottomNavigationBar(
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
        if (route.settings.name == DashboardMahasiswa.routeName) {
          dashboardFound = true;
          return true;
        }
        return route.isFirst;
      });
      if (!dashboardFound && context.mounted) {
        Navigator.pushReplacementNamed(context, DashboardMahasiswa.routeName);
      }
      return;
    }
    if (index == 1) {
      Navigator.pushReplacement(
        context,
        nexusTabRoute(const ApplicationHistoryScreen()),
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

  String _profileValue(Map<String, dynamic> user, List<String> keys) {
    final nestedProfiles = [
      user,
      if (user['data'] is Map) (user['data'] as Map).cast<String, dynamic>(),
      if (user['mahasiswa'] is Map)
        (user['mahasiswa'] as Map).cast<String, dynamic>(),
      if (user['profile'] is Map)
        (user['profile'] as Map).cast<String, dynamic>(),
    ];
    for (final profile in nestedProfiles) {
      for (final key in keys) {
        final value = profile[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }
    return '-';
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String label, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
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
