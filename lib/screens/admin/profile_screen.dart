import 'package:flutter/material.dart';

import '../../models/admin_model.dart';
import '../../models/nexus_app_state.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool _isLoading = true;
  String? _error;
  AdminProfile? _profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    final token = NexusScope.of(context).authToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _error = 'Token tidak tersedia. Silakan login ulang.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await ApiService.fetchAdminProfile(token);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profil Admin',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Gagal memuat profil admin',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Text(
            _error!,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadProfile,
            child: const Text('Muat Ulang'),
          ),
        ],
      );
    }

    final profile = _profile!;
    return SingleChildScrollView(
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
                  backgroundColor: AppColors.primary.withValues(alpha: 0.16),
                  child: const Icon(
                    Icons.admin_panel_settings,
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
                        profile.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.role,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.email,
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
          const SizedBox(height: 20),
          _buildInfoTile(
            context,
            Icons.person_outline_rounded,
            'Username',
            profile.username,
          ),
          const SizedBox(height: 12),
          _buildInfoTile(context, Icons.email_rounded, 'Email', profile.email),
          const SizedBox(height: 12),
          _buildInfoTile(context, Icons.badge_rounded, 'Role', profile.role),
          const SizedBox(height: 12),
          _buildInfoTile(
            context,
            Icons.perm_identity_rounded,
            'Admin ID',
            profile.id,
          ),
          if (profile.phone != null && profile.phone!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoTile(
              context,
              Icons.phone_rounded,
              'Telepon',
              profile.phone!,
            ),
          ],
          if (profile.createdAt != null) ...[
            const SizedBox(height: 12),
            _buildInfoTile(
              context,
              Icons.calendar_today_rounded,
              'Dibuat pada',
              _formatDate(profile.createdAt!),
            ),
          ],
          if (profile.updatedAt != null) ...[
            const SizedBox(height: 12),
            _buildInfoTile(
              context,
              Icons.update_rounded,
              'Terakhir diperbarui',
              _formatDate(profile.updatedAt!),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            'Data profil ini ditarik langsung dari database administrators backend.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
          ),
          const SizedBox(height: 20),
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
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
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
