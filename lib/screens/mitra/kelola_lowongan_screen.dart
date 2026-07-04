import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/nexus_app_state.dart';
import '../../models/mitra_provider.dart';
import '../../models/mitra_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mitra_bottom_nav.dart';
import '../mitra/mitra_dashboard_screen.dart';
import '../mitra/profile_screen.dart';
import '../../screens/notifications_screen.dart';

class MitraKelolaLowonganScreen extends StatefulWidget {
  static const routeName = '/mitra/kelola-lowongan';

  const MitraKelolaLowonganScreen({super.key});

  @override
  State<MitraKelolaLowonganScreen> createState() =>
      _MitraKelolaLowonganScreenState();
}

class _MitraKelolaLowonganScreenState extends State<MitraKelolaLowonganScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      final appState = NexusScope.of(context);
      final mitraProvider = Provider.of<MitraProvider>(context, listen: false);
      mitraProvider.loadLowongan(appState.authToken);
    }
  }

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
          child: Consumer<MitraProvider>(
            builder: (context, mitraProvider, _) {
              if (mitraProvider.isLoadingLowongan) {
                return const Center(child: CircularProgressIndicator());
              }

              if (mitraProvider.lowonganError != null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Gagal memuat lowongan',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      mitraProvider.lowonganError!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () {
                        final appState = NexusScope.of(context);
                        mitraProvider.loadLowongan(appState.authToken);
                      },
                      child: const Text('Muat Ulang'),
                    ),
                  ],
                );
              }

              if (mitraProvider.lowonganList.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Belum ada lowongan tersedia.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Silakan ajukan lowongan baru dari dashboard atau tunggu persetujuan admin.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                  ],
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 20),
                itemCount: mitraProvider.lowonganList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final lowongan = mitraProvider.lowonganList[index];
                  return _buildLowonganCard(context, lowongan);
                },
              );
            },
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

  Widget _buildLowonganCard(BuildContext context, LowonganMitra lowongan) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  lowongan.position,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Chip(
                label: Text(lowongan.approvalStatus.name.toUpperCase()),
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            lowongan.category,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                lowongan.tags
                    .map(
                      (tag) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          tag,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.neutral),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  lowongan.location,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.group_outlined, size: 16),
              const SizedBox(width: 6),
              Text(
                '${lowongan.quota} kuota',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            lowongan.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Deadline: ${lowongan.deadline.day.toString().padLeft(2, '0')}/${lowongan.deadline.month.toString().padLeft(2, '0')}/${lowongan.deadline.year}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fitur detail belum tersedia.'),
                    ),
                  );
                },
                child: const Text('Lihat Detail'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
