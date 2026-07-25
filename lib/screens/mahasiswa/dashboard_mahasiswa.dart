import 'package:flutter/material.dart';

import '../../models/application_model.dart';
import '../../models/nexus_app_state.dart';
import '../../services/api_service.dart'; // INJEKSI 1: Import ApiService
import 'application_status_screen.dart';
import 'application_history_screen.dart';
import 'internship_detail_screen.dart';
import 'internship_progress_screen.dart';
import 'all_internships_screen.dart';
import 'profile_screen.dart';
import '../notifications_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';

class DashboardMahasiswa extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardMahasiswa({super.key});

  @override
  State<DashboardMahasiswa> createState() => _DashboardMahasiswaState();
}

class _DashboardMahasiswaState extends State<DashboardMahasiswa> {
  int _selectedIndex = 0;
  String _query = '';
  String? _categoryFilter;

  // Data katalog selalu berasal dari API.
  List<Internship> _recommended = [];
  bool _isLoading = true;
  String? _error;

  // INJEKSI 3: Jalankan penarikan data saat halaman pertama kali dibuka
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDataLowongan();
    });
  }

  Future<void> _fetchDataLowongan() async {
    final token = NexusScope.of(context).authToken;
    try {
      final data = await ApiService.fetchLowonganMahasiswa(token);
      if (mounted) {
        setState(() {
          _recommended = data;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = NexusScope.of(context);
    final recommendations =
        _recommended
            .where((item) {
              final query = _query.toLowerCase();
              return query.isEmpty ||
                  item.position.toLowerCase().contains(query) ||
                  item.company.toLowerCase().contains(query);
            })
            .where((item) {
              return _categoryFilter == null ||
                  item.tags.any(
                    (tag) =>
                        tag.toLowerCase() == _categoryFilter!.toLowerCase(),
                  );
            })
            .toList();
    final activeApplications =
        appState.applications
            .where((item) => item.status != ApplicationStatus.rejected)
            .length;
    final accepted =
        appState.applications
            .where((item) => item.status == ApplicationStatus.accepted)
            .length;
    final completion =
        activeApplications == 0 ? 0.0 : accepted / activeApplications;
    final activities = appState.applications;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, ${appState.currentGreetingName}!',
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium?.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 6),
              Text(
                'Ready to jumpstart your career today?',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
              ),
              const SizedBox(height: 18),
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'Search internships...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: _showFilter,
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registration Status',
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$activeApplications Aktif',
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(color: Colors.white, fontSize: 28),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ongoing applications',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 86,
                      height: 86,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: completion,
                            strokeWidth: 8,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          Text(
                            '${(completion * 100).round()}%',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recommended for You',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed:
                        () => Navigator.pushNamed(
                          context,
                          AllInternshipsScreen.routeName,
                        ),
                    child: const Text('See all'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // INJEKSI 4: Tampilkan animasi loading, text kosong, atau List Lowongan API
              _isLoading
                  ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                  : _error != null
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          TextButton(
                            onPressed: () {
                              setState(() => _isLoading = true);
                              _fetchDataLowongan();
                            },
                            child: const Text('Coba lagi'),
                          ),
                        ],
                      ),
                    ),
                  )
                  : recommendations.isEmpty
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Belum ada lowongan magang tersedia.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.neutral,
                        ),
                      ),
                    ),
                  )
                  : SizedBox(
                    height: 236,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendations.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final item = recommendations[index];
                        return _RecommendationCard(
                          internship: item,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => InternshipDetailScreen(
                                      internship: item,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),

              const SizedBox(height: 22),
              Text(
                'Recent Activity',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (activities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('Belum ada riwayat lamaran.')),
                ),
              ...activities.map(
                (application) => _ActivityTile(
                  application: application,
                  onTap: () => _openApplication(context, application),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NexusBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              nexusTabRoute(const ApplicationHistoryScreen()),
            );
            return;
          }

          if (index == 3) {
            Navigator.push(
              context,
              nexusTabRoute(const DashboardMahasiswaProfileScreen()),
            );
            return;
          }

          if (index == 2) {
            Navigator.push(
              context,
              nexusTabRoute(const NotificationsScreen()),
            );
            return;
          }

          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Future<void> _showFilter() async {
    final categories =
        _recommended.expand((item) => item.tags).toSet().toList()..sort();
    final selected = await showModalBottomSheet<String?>(
      context: context,
      builder:
          (context) => SafeArea(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Filter kategori',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                ListTile(
                  title: const Text('Semua kategori'),
                  trailing:
                      _categoryFilter == null
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                  onTap: () => Navigator.pop(context, ''),
                ),
                ...categories.map(
                  (category) => ListTile(
                    title: Text(category),
                    trailing:
                        category == _categoryFilter
                            ? const Icon(Icons.check, color: AppColors.primary)
                            : null,
                    onTap: () => Navigator.pop(context, category),
                  ),
                ),
              ],
            ),
          ),
    );
    if (!mounted || selected == null) return;
    setState(() => _categoryFilter = selected.isEmpty ? null : selected);
  }

  String _formatDate(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _openApplication(BuildContext context, Application application) {
    final route =
        application.status == ApplicationStatus.accepted
            ? InternshipProgressScreen(application: application)
            : ApplicationStatusScreen(application: application);
    Navigator.push(context, MaterialPageRoute(builder: (_) => route));
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.internship, required this.onTap});

  final Internship internship;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF7F2FF), Color(0xFFFDFBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE9E0FA)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.apartment_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              internship.position,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              internship.company,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
            ),
            const SizedBox(height: 8),
            Text(
              internship.location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
            ),
            const Spacer(),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  internship.tags
                      .take(2)
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.application, required this.onTap});

  final Application application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F5FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.history_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lamaran ${application.status.label}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  '${application.internship.position} - ${application.internship.company}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDate(application.appliedDate),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.neutral),
          ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) return '-';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
