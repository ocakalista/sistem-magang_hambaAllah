import 'package:flutter/material.dart';

import '../models/application_model.dart';
import '../models/nexus_app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'application_status_screen.dart';
import 'internship_detail_screen.dart';
import 'internship_progress_screen.dart';
import 'notifications_screen.dart';

class DashboardMahasiswa extends StatefulWidget {
  static const routeName = '/dashboard';

  const DashboardMahasiswa({super.key});

  @override
  State<DashboardMahasiswa> createState() => _DashboardMahasiswaState();
}

class _DashboardMahasiswaState extends State<DashboardMahasiswa> {
  int _selectedIndex = 0;
  final List<String> _filters = ['All', 'Engineering', 'Design', 'Marketing'];
  final List<Internship> _recommended = const [demoInternship];

  final List<Map<String, String>> _activities = const [
    {
      'title': 'Application submitted',
      'desc': 'Frontend Engineering Intern at Telkom Indonesia',
      'time': '10 min ago',
    },
    {
      'title': 'Interview scheduled',
      'desc': 'Product Design Intern at Gojek',
      'time': '2 hours ago',
    },
    {
      'title': 'Profile completed',
      'desc': 'Your internship profile is now 100% complete',
      'time': 'Yesterday',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final appState = NexusScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
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
                'Hello, Mahasiswa!',
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
                decoration: InputDecoration(
                  hintText: 'Search internships...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune_rounded),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 42,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final isSelected = index == 0;
                    return ChoiceChip(
                      label: Text(_filters[index]),
                      selected: isSelected,
                      onSelected: (_) {},
                      selectedColor: AppColors.primary,
                      labelStyle: Theme.of(
                        context,
                      ).textTheme.labelMedium?.copyWith(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      backgroundColor: const Color(0xFFF4EFFB),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    );
                  },
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
                            '2 Active',
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
                          const CircularProgressIndicator(
                            value: 0.75,
                            strokeWidth: 8,
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          Text(
                            '75%',
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
                  TextButton(onPressed: () {}, child: const Text('See all')),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 178,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recommended.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final item = _recommended[index];
                    return _RecommendationCard(
                      internship: item,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => InternshipDetailScreen(internship: item),
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
              ..._activities.map(
                (activity) => _ActivityTile(activity: activity),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
      ),
      bottomNavigationBar: NexusBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            final application = appState.currentApplication;
            if (application == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Apply for an internship first.')),
              );
              return;
            }
            final route =
                application.status == ApplicationStatus.accepted
                    ? InternshipProgressScreen(application: application)
                    : ApplicationStatusScreen(application: application);
            Navigator.push(context, MaterialPageRoute(builder: (_) => route));
            return;
          }

          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
            return;
          }

          setState(() => _selectedIndex = index);
        },
      ),
    );
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              internship.company,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
            ),
            const SizedBox(height: 8),
            Text(
              internship.location,
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
  const _ActivityTile({required this.activity});

  final Map<String, String> activity;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  activity['title'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  activity['desc'] ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            activity['time'] ?? '',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.neutral),
          ),
        ],
      ),
    );
  }
}
