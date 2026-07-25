import 'package:flutter/material.dart';

import '../../models/admin_model.dart';
import '../../models/nexus_app_state.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'user_detail_screen.dart';
import 'admin_bottom_nav.dart';

class PenggunaScreen extends StatefulWidget {
  const PenggunaScreen({super.key});

  @override
  State<PenggunaScreen> createState() => _PenggunaScreenState();
}

class _PenggunaScreenState extends State<PenggunaScreen> {
  String _query = '';
  late Future<List<UserAccount>> _usersFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _usersFuture = ApiService.fetchUsers(
      NexusScope.of(context).authToken ?? '',
    );
  }

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
                  future: _usersFuture,
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
                        _buildUserList(
                          context,
                          _filterUsers(mahasiswa),
                          'Cari nama atau NIM mahasiswa...',
                        ),
                        _buildUserList(
                          context,
                          _filterUsers(dosen),
                          'Cari nama atau NIDN dosen...',
                        ),
                        _buildUserList(
                          context,
                          _filterUsers(mitra),
                          'Cari nama perusahaan mitra...',
                        ),
                      ],
                    );
                  },
                ),
        bottomNavigationBar: AdminBottomNav(
          selectedIndex: 2,
          onDestinationSelected:
              (index) => navigateAdminTab(
                context,
                currentIndex: 2,
                destinationIndex: index,
              ),
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

  List<UserAccount> _filterUsers(List<UserAccount> users) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return users;
    return users.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          (user.username ?? '').toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildUserList(
    BuildContext context,
    List<UserAccount> users,
    String hint,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: users.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        if (index == 0) {
          return TextField(
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon:
                  _query.isEmpty
                      ? null
                      : IconButton(
                        tooltip: 'Hapus pencarian',
                        onPressed: () => setState(() => _query = ''),
                        icon: const Icon(Icons.close_rounded),
                      ),
            ),
          );
        }
        if (users.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Center(
              child: Text(
                _query.isEmpty
                    ? 'Belum ada pengguna di kategori ini.'
                    : 'Pengguna tidak ditemukan.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
              ),
            ),
          );
        }
        final user = users[index - 1];
        return _buildUserCard(context, user);
      },
    );
  }

  Widget _buildUserCard(BuildContext context, UserAccount user) {
    final roleLabel = user.role.isNotEmpty ? user.role : 'Pengguna';
    return InkWell(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AdminUserDetailScreen(user: user),
            ),
          ),
      borderRadius: BorderRadius.circular(22),
      child: Container(
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
      ),
    );
  }
}
