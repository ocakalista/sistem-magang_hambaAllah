import 'package:flutter/material.dart';

import '../../models/nexus_app_state.dart';
import '../../models/admin_model.dart';
import '../../theme/app_theme.dart';
import 'admin_bottom_nav.dart';
import 'profile_screen.dart';
import '../notifications_screen.dart';
import 'enrollments_screen.dart';
import 'lowongan_detail_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  static const routeName = '/admin';

  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _hasLoadedLowongan = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedLowongan) {
      _hasLoadedLowongan = true;
      final state = NexusScope.of(context);
      state.loadAdminLowongan();
      state.loadAdminEnrollments().catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = NexusScope.of(context);

    final stats = state.adminStats;
    final students = state.studentEnrollments;
    final pending =
        state.pendingLowongan
            .where((item) => item.status == LowonganApprovalStatus.pending)
            .toList();
    final distribution = state.internshipDistribution;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            const Icon(Icons.apartment_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
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
          Stack(
            children: [
              IconButton(
                onPressed:
                    () => Navigator.pushNamed(
                      context,
                      NotificationsScreen.routeName,
                    ),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              tooltip: 'Profil admin',
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminProfileScreen(),
                    ),
                  ),
              icon: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ADMIN CONTROL CENTER',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Platform Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              _StatCard(
                icon: Icons.people_rounded,
                label: 'Total Users',
                value: '${stats.totalUsers}',
                growth: '+${stats.totalUsersGrowthPercent.round()}%',
              ),
              const SizedBox(height: 12),
              _StatCard(
                icon: Icons.work_rounded,
                label: 'Active Internships',
                value: '${stats.activeInternships}',
                growth: '+${stats.activeInternshipsGrowthPercent.round()}%',
              ),
              const SizedBox(height: 18),
              _SectionHeaderWithAction(
                title: 'Student Enrollment',
                actionLabel: 'View All',
                onAction:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminEnrollmentsScreen(),
                      ),
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'User',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppColors.neutral),
                          ),
                        ),
                        Text(
                          'Program',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(color: AppColors.neutral),
                        ),
                      ],
                    ),
                    const Divider(),
                    if (students.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            'No students enrolled yet',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.neutral),
                          ),
                        ),
                      )
                    else
                      ...students.map((s) => _StudentRow(student: s)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pending Lowongan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (pending.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${pending.length} NEW',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (pending.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: Text(
                    'No pending requests',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
                  ),
                )
              else
                ...pending.map(
                  (p) => _PendingCard(
                    pending: p,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => AdminLowonganDetailScreen(lowongan: p),
                          ),
                        ),
                    onApprove: () async {
                      try {
                        await state.approveLowongan(p.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lowongan approved')),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Approve gagal: $e')),
                        );
                      }
                    },
                    onReject: () async {
                      final reason = await _showRejectDialog(context);
                      if (!context.mounted) return;
                      if (reason != null && reason.isNotEmpty) {
                        try {
                          await state.rejectLowongan(p.id, reason);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Lowongan rejected')),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reject gagal: $e')),
                          );
                        }
                      }
                    },
                  ),
                ),
              const SizedBox(height: 18),
              Text(
                'Internship Distribution',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              _DistributionChart(items: distribution),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminBottomNav(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          navigateAdminTab(context, currentIndex: 0, destinationIndex: index);
        },
      ),
    );
  }

  Future<String?> _showRejectDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Listing Request'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Are you sure you want to reject this listing request?',
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Reason for rejection',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = controller.text.trim();
                if (reason.isEmpty) return;
                Navigator.of(context).pop(reason);
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.growth,
  });

  final IconData icon;
  final String label;
  final String value;
  final String growth;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE9F7)),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 64, color: AppColors.primary),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              growth,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeaderWithAction extends StatelessWidget {
  const _SectionHeaderWithAction({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionLabel,
            style: const TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.student});

  final StudentEnrollment student;

  @override
  Widget build(BuildContext context) {
    final initials =
        student.name
            .split(' ')
            .map((s) => s.isNotEmpty ? s[0] : '')
            .take(2)
            .join();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (student.avatarUrl != null)
            CircleAvatar(
              backgroundImage: NetworkImage(student.avatarUrl!),
              radius: 22,
            )
          else
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  student.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  student.program.isEmpty
                      ? 'Program belum tersedia'
                      : student.program,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (student.company.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    student.company,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: AppColors.neutral),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({
    required this.pending,
    required this.onApprove,
    required this.onReject,
    required this.onTap,
  });

  final PendingLowongan pending;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.business, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pending.companyName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        pending.companyCategory,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              pending.requestDescription,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    child: const Text('Reject'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DistributionChart extends StatelessWidget {
  const _DistributionChart({required this.items});

  final List<InternshipDistribution> items;

  @override
  Widget build(BuildContext context) {
    final maxPercent = items
        .map((e) => e.percent)
        .fold<double>(0, (p, n) => n > p ? n : p);
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children:
                items.map((it) {
                  final heightFactor = it.percent / maxPercent;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 80 * heightFactor,
                            decoration: BoxDecoration(
                              color: it.color.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            it.category,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.neutral),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${it.percent.round()}%',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.neutral),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              items.map((it) {
                return Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: it.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      it.category,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${it.percent.round()}%',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                    ),
                  ],
                );
              }).toList(),
        ),
      ],
    );
  }
}
