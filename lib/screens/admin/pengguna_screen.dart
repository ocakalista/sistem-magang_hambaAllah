import 'package:flutter/material.dart';

import '../../models/admin_model.dart';
import '../../models/nexus_app_state.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class PenggunaScreen extends StatelessWidget {
  const PenggunaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final token = NexusScope.of(context).authToken;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Pengguna'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.neutral,
            tabs: [
              Tab(text: 'Mahasiswa'),
              Tab(text: 'Dosen'),
              Tab(text: 'Mitra'),
            ],
          ),
        ),
        body:
            token == null
                ? Center(
                  child: Text(
                    'Token admin tidak tersedia. Silakan login ulang.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.neutral),
                    textAlign: TextAlign.center,
                  ),
                )
                : FutureBuilder<List<UserAccount>>(
                  future: ApiService.fetchUsers(token),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Center(
                          child: Text(
                            'Gagal memuat pengguna: ${snapshot.error}',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.neutral),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    final users = snapshot.data ?? <UserAccount>[];
                    final mahasiswa =
                        users.where((user) => _isMahasiswa(user.role)).toList();
                    final dosen =
                        users.where((user) => _isDosen(user.role)).toList();
                    final mitra =
                        users.where((user) => _isMitra(user.role)).toList();

                    return TabBarView(
                      children: [
                        _buildUserList(context, mahasiswa),
                        _buildUserList(context, dosen),
                        _buildUserList(context, mitra),
                      ],
                    );
                  },
                ),
      ),
    );
  }

  bool _isMahasiswa(String role) {
    final normalized = role.toLowerCase();
    return normalized == 'mahasiswa' || normalized == 'student';
  }

  bool _isDosen(String role) {
    final normalized = role.toLowerCase();
    return normalized == 'dosen' ||
        normalized == 'lecturer' ||
        normalized == 'teacher';
  }

  bool _isMitra(String role) {
    final normalized = role.toLowerCase();
    return normalized == 'mitra' || normalized == 'partner';
  }

  Widget _buildUserList(BuildContext context, List<UserAccount> users) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          'Belum ada pengguna di kategori ini.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(context, user);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserAccount user) {
    final roleLabel = user.role.isNotEmpty ? user.role : 'Pengguna';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  user.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  roleLabel.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
          ),
          if (user.phone != null && user.phone!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Telp: ${user.phone}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
            ),
          ],
          if (user.username != null && user.username!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Username: ${user.username}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
            ),
          ],
        ],
      ),
    );
  }
}
