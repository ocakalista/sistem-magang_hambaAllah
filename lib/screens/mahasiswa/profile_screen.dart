import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/logout_button.dart';
import '../../models/nexus_app_state.dart';

class DashboardMahasiswaProfileScreen extends StatelessWidget {
  static const routeName = '/mahasiswa/profile';

  const DashboardMahasiswaProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user =
        NexusScope.of(context).currentUser ?? const <String, dynamic>{};
    final name = user['name']?.toString() ?? '-';
    final identifier = user['email_or_nim']?.toString() ?? '-';
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Padding(
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
                user['semester']?.toString() ?? '-',
              ),
              const SizedBox(height: 12),
              _buildInfoTile(
                context,
                Icons.phone_rounded,
                'Telepon',
                user['phone']?.toString() ?? '-',
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
