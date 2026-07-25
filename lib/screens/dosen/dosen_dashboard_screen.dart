import 'package:flutter/material.dart';

import '../../models/dosen_model.dart';
import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';
import '../notifications_screen.dart';
import '../../widgets/dosen_bottom_nav.dart';
import '../../widgets/bottom_nav.dart';
import 'profile_screen.dart';
import 'student_profile_screen.dart';
import 'students_screen.dart';
import 'weekly_report_detail_screen.dart';

class DosenDashboardScreen extends StatefulWidget {
  static const routeName = '/dosen';

  const DosenDashboardScreen({super.key});

  @override
  State<DosenDashboardScreen> createState() => _DosenDashboardScreenState();
}

class _DosenDashboardScreenState extends State<DosenDashboardScreen> {
  int _selectedIndex = 0;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _loadError;

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showApprovalDialog(
    MahasiswaBimbingan student,
    WeeklyReportDosen latestReport,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Approve Weekly Report'),
            content: Text('Approve this week\'s report for ${student.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final state = NexusScope.of(context);
                  state.approveDosenReport(
                    studentId: student.id,
                    reportId: latestReport.id,
                    feedback: 'Good work this week',
                  );

                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Report approved successfully'),
                    ),
                  );
                },
                child: const Text('Approve'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = NexusScope.of(context);
    final dosenStats = state.dosenStats;
    final pendingApprovals =
        state.mahasiswaBimbingan
            .where((student) => student.getLatestUnapprovedReport() != null)
            .toList();
    final recentReports = state.recentDosenReports;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: InkWell(
          onTap:
              () => Navigator.pushNamed(context, DosenProfileScreen.routeName),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Notifikasi',
              onPressed:
                  () => Navigator.pushNamed(
                    context,
                    NotificationsScreen.routeName,
                  ),
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.black87,
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
                'Halo, ${state.currentGreetingName}!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pantau perkembangan mahasiswa bimbinganmu hari ini.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
              ),
              const SizedBox(height: 20),
              // Overview Header
              Text(
                'Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitoring ${state.mahasiswaBimbingan.length} active internship students.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
              ),
              const SizedBox(height: 20),

              // Total Approval Needed Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Approval Needed',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(
                          Icons.assignment_rounded,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _isLoading
                        ? const Center(
                          child: SizedBox(
                            height: 48,
                            width: 48,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          ),
                        )
                        : Text(
                          dosenStats.totalApprovalNeeded.toString().padLeft(
                            2,
                            '0',
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(
                            color: AppColors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          color: AppColors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isLoading
                              ? 'Memuat…'
                              : '+${dosenStats.approvalChangeFromYesterday} from yesterday',
                          style: Theme.of(
                            context,
                          ).textTheme.labelSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Stats Cards Row
              Row(
                children: [
                  // Completed Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Completed',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dosenStats.completedInternships}',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Ongoing Card
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.hourglass_bottom_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Ongoing',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${dosenStats.ongoingInternships}',
                            style: Theme.of(
                              context,
                            ).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (_loadError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Gagal memuat mahasiswa: $_loadError',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.neutral),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),

              // Pending Approvals Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pending Approvals',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  GestureDetector(
                    onTap: _navigateToStudents,
                    child: Text(
                      'View All',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (pendingApprovals.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No pending approvals',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      pendingApprovals.length > 2 ? 2 : pendingApprovals.length,
                  itemBuilder: (context, index) {
                    final student = pendingApprovals[index];
                    final latestReport = student.getLatestUnapprovedReport()!;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  student.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap:
                                          () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => StudentProfileScreen(
                                                    student: student,
                                                  ),
                                            ),
                                          ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        child: Text(
                                          student.name,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      student.internshipPosition,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(color: AppColors.neutral),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Week ${student.currentWeek}',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Internship Progress',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: AppColors.neutral),
                              ),
                              Text(
                                '${(student.progressPercent * 100).toStringAsFixed(0)}%',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: student.progressPercent,
                              minHeight: 6,
                              backgroundColor: AppColors.background,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      WeeklyReportDetailScreen.routeName,
                                      arguments: {
                                        'report': latestReport,
                                        'student': student,
                                      },
                                    );
                                  },
                                  child: const Text('Review'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      () => _showApprovalDialog(
                                        student,
                                        latestReport,
                                      ),
                                  child: const Text('Approve'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Recent Weekly Reports Section
              Text(
                'Recent Weekly Reports',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (recentReports.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      'No reports yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentReports.length,
                  itemBuilder: (context, index) {
                    final report = recentReports[index];
                    // Find student for this report
                    MahasiswaBimbingan? reportStudent;
                    for (var student in state.mahasiswaBimbingan) {
                      if (student.weeklyReports.any((r) => r.id == report.id)) {
                        reportStudent = student;
                        break;
                      }
                    }

                    return GestureDetector(
                      onTap:
                          reportStudent != null
                              ? () {
                                Navigator.pushNamed(
                                  context,
                                  WeeklyReportDetailScreen.routeName,
                                  arguments: {
                                    'report': report,
                                    'student': reportStudent,
                                  },
                                );
                              }
                              : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 60,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.description_outlined,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Week ${report.weekNumber} - ${report.title}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Submitted by ${report.submittedBy} • ${_getRelativeTime(report.submittedAt)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: AppColors.neutral),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.neutral,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: DosenBottomNav(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          if (index == 0) {
            setState(() => _selectedIndex = 0);
            return;
          }

          if (index == 1) {
            _navigateToStudents();
            return;
          }

          if (index == 2) {
            Navigator.push(
              context,
              nexusTabRoute(const NotificationsScreen()),
            );
            return;
          }

          if (index == 3) {
            Navigator.push(
              context,
              nexusTabRoute(const DosenProfileScreen()),
            );
            return;
          }
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final state = NexusScope.of(context);
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      await state.loadMahasiswaBimbingan();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = e.toString();
        });
      }
    }
  }

  void _navigateToStudents() {
    Navigator.push(
      context,
      nexusTabRoute(const StudentsScreen()),
    );
  }
}
