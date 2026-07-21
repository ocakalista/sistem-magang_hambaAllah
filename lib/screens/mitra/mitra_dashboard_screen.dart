import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/mitra_provider.dart';
import '../../models/mitra_model.dart';
import '../../screens/mitra/kelola_lowongan_screen.dart';
import '../../screens/mitra/pendaftar_detail_screen.dart';
import '../../screens/mitra/profile_screen.dart';
import '../../screens/mitra/tambah_lowongan_screen.dart';
import '../../screens/notifications_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mitra_bottom_nav.dart';
import '../../models/nexus_app_state.dart';

class MitraDashboardScreen extends StatefulWidget {
  static const routeName = '/mitra/dashboard';

  const MitraDashboardScreen({super.key});

  @override
  State<MitraDashboardScreen> createState() => _MitraDashboardScreenState();
}

class _MitraDashboardScreenState extends State<MitraDashboardScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final appState = NexusScope.of(context);
      final mitraProvider = Provider.of<MitraProvider>(context, listen: false);
      // INJEKSI: Memanggil API saat Dashboard Mitra terbuka
      mitraProvider.loadLowongan(appState.authToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<MitraProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Nexus',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed:
                () =>
                    Navigator.pushNamed(context, NotificationsScreen.routeName),
            icon: const Icon(Icons.notifications_none_rounded),
            color: Colors.black87,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MITRA DASHBOARD',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 1.8,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Halo, ${state.info.companyName}', // Menggunakan nama perusahaan dari state
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 24),
              _buildPrimaryStatCard(context, state),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildSmallStatCard(
                      context,
                      'Pendaftar Baru',
                      state.stats.pendaftarBaru.toString(),
                      '+${state.stats.pendaftarGrowthPercent.toInt()}% dari kemarin',
                      AppColors.primary,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildSmallStatCard(
                      context,
                      'Diterima',
                      state.stats.diterima.toString(),
                      '${state.stats.approvalRate.toInt()}% Approval Rate',
                      AppColors.primary,
                      AppColors.neutral,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pendaftar Terbaru',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Menangani jika data pendaftar terbaru kosong
              if (state.pendaftarTerbaru.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: Text(
                    'Belum ada pendaftar terbaru.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.pendaftarTerbaru.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final pendaftar = state.pendaftarTerbaru[index];
                    return _buildApplicantCard(context, pendaftar);
                  },
                ),
              const SizedBox(height: 24),
              _buildInsightCard(context, state.insight),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, TambahLowonganScreen.routeName);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: MitraBottomNavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) => _handleNav(context, index),
      ),
    );
  }

  Widget _buildPrimaryStatCard(BuildContext context, MitraProvider state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Lowongan',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.neutral,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                // INJEKSI: Menampilkan loading indicator kecil jika data API sedang diambil
                state.isLoadingLowongan
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(
                      state.stats.totalLowongan.toString(),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontSize: 42, fontWeight: FontWeight.w800),
                    ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.work_outline_rounded,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    Color valueColor,
    Color subtitleColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.neutral,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: valueColor,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: subtitleColor),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(BuildContext context, PendaftarTerbaru applicant) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PendaftarDetailScreen(applicant: applicant),
          ),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.03 * 255).round()),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primary.withValues(alpha: 0.16),
              foregroundImage:
                  applicant.avatarUrl != null
                      ? NetworkImage(applicant.avatarUrl!)
                      : null,
              child:
                  applicant.avatarUrl == null
                      ? const Icon(Icons.person, color: AppColors.primary)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    applicant.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    applicant.position,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.neutral,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _relativeTime(applicant.appliedAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: applicant.status.mitraBadgeColor,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                applicant.status.mitraBadgeLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: applicant.status.mitraBadgeTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, InsightMingguan insight) {
    final progress =
        insight.capacityTotal > 0
            ? insight.capacityUsed / insight.capacityTotal
            : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Insight Mingguan',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            insight.insightText,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: AppColors.background,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KAPASITAS KUOTA',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.neutral,
                  letterSpacing: 1.6,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${insight.capacityUsed.toInt()}/${insight.capacityTotal.toInt()} TERISI',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.neutral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    }
    return '${diff.inDays} hari yang lalu';
  }

  void _handleNav(BuildContext context, int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacementNamed(
          context,
          MitraKelolaLowonganScreen.routeName,
        );
        break;
      case 2:
        Navigator.pushReplacementNamed(context, NotificationsScreen.routeName);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, MitraProfileScreen.routeName);
        break;
    }
  }
}
