import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/application_model.dart';
import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';
import 'dashboard_mahasiswa.dart';
import 'application_status_screen.dart';
import '../notifications_screen.dart';
import '../../widgets/bottom_nav.dart';

class InternshipProgressScreen extends StatefulWidget {
  const InternshipProgressScreen({super.key, this.application});

  final Application? application;

  @override
  State<InternshipProgressScreen> createState() =>
      _InternshipProgressScreenState();
}

class _InternshipProgressScreenState extends State<InternshipProgressScreen> {
  String? _selectedReportFile;

  @override
  Widget build(BuildContext context) {
    final state = NexusScope.of(context);
    final app = widget.application ?? state.currentApplication;

    if (app == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Nexus'),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        body: const Center(child: Text('No accepted internship found.')),
        bottomNavigationBar: NexusBottomNavigationBar(
          selectedIndex: 1,
          onDestinationSelected: (index) => _handleNav(context, index),
        ),
      );
    }

    final reports =
        app.weeklyReports.isNotEmpty
            ? app.weeklyReports
            : buildDemoWeeklyReports();
    final currentWeek = app.currentWeek ?? 3;
    final totalWeeks = app.totalWeeks ?? 6;
    final progress = app.progressPercent ?? (currentWeek / totalWeeks);
    final remainingWeeks = (totalWeeks - currentWeek).clamp(0, totalWeeks);
    final currentReport = reports.firstWhere(
      (report) => report.status == 'ongoing',
      orElse: () => reports.last,
    );
    final feedbackReport = reports.lastWhere(
      (report) => (report.feedbackFromLecturer ?? '').isNotEmpty,
      orElse: () => currentReport,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
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
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            children: [
              _ProgressCard(
                application: app,
                currentWeek: currentWeek,
                totalWeeks: totalWeeks,
                remainingWeeks: remainingWeeks,
                progress: progress,
              ),
              const SizedBox(height: 18),
              _SectionTitleWithAction(
                title: 'Weekly Timeline',
                actionLabel: 'View History',
                onAction: () {},
              ),
              const SizedBox(height: 10),
              _WeeklyTimeline(reports: reports),
              const SizedBox(height: 18),
              _UploadSection(
                selectedReportFile: _selectedReportFile,
                onBrowse: _pickReportFile,
              ),
              const SizedBox(height: 18),
              _LecturerFeedbackCard(report: feedbackReport),
            ],
          ),
          if (kDebugMode)
            Positioned(
              right: 16,
              bottom: 104,
              child: _DevStatusMenu(
                currentStatus: app.status,
                onChanged: (status) {
                  state.updateApplicationStatus(status);
                  if (status != ApplicationStatus.accepted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => ApplicationStatusScreen(
                              application: state.currentApplication,
                            ),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: NexusBottomNavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) => _handleNav(context, index),
      ),
    );
  }

  void _pickReportFile() {
    setState(() {
      _selectedReportFile = 'Weekly_Report_Week_3.pdf';
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Weekly report attached.')));
  }

  void _handleNav(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, DashboardMahasiswa.routeName);
      return;
    }

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    }
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.application,
    required this.currentWeek,
    required this.totalWeeks,
    required this.remainingWeeks,
    required this.progress,
  });

  final Application application;
  final int currentWeek;
  final int totalWeeks;
  final int remainingWeeks;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.internship.position,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.internship.company,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
                  '${(progress * 100).round()}% Completed',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 10,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: const Color(0xFFE7E1F4),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricTile(label: 'Week $currentWeek of $totalWeeks'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricTile(label: '$remainingWeeks Weeks Remaining'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _SectionTitleWithAction extends StatelessWidget {
  const _SectionTitleWithAction({
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
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _WeeklyTimeline extends StatelessWidget {
  const _WeeklyTimeline({required this.reports});

  final List<WeeklyReport> reports;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(reports.length, (index) {
        final report = reports[index];
        final isCurrent = report.status == 'ongoing';
        final isCompleted = report.status == 'completed';
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color:
                        isCurrent
                            ? AppColors.primary
                            : (isCompleted
                                ? const Color(0xFFE0DBEE)
                                : Colors.transparent),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          isCurrent
                              ? AppColors.primary
                              : const Color(0xFFCFC8DF),
                    ),
                  ),
                  child: Center(
                    child:
                        isCompleted
                            ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primary,
                              size: 16,
                            )
                            : isCurrent
                            ? const Icon(
                              Icons.schedule_rounded,
                              color: Colors.white,
                              size: 16,
                            )
                            : Text(
                              '${report.weekNumber}',
                              style: const TextStyle(
                                color: AppColors.neutral,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                  ),
                ),
                if (index != reports.length - 1)
                  Container(
                    width: 2,
                    height: 76,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          isCompleted
                              ? AppColors.primary
                              : const Color(0xFFD9D4E4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isCurrent
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Week ${report.weekNumber} - ${report.title}',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isCurrent
                                    ? AppColors.primary
                                    : const Color(0xFFEDE9F7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isCurrent ? 'ONGOING' : 'COMPLETED',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color:
                                  isCurrent ? Colors.white : AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (report.dueDate != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 16,
                            color: AppColors.neutral,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatDate(report.dueDate!),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.neutral),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _UploadSection extends StatelessWidget {
  const _UploadSection({
    required this.selectedReportFile,
    required this.onBrowse,
  });

  final String? selectedReportFile;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upload Laporan Mingguan',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.22),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 34,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  'Drag & Drop report here',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Supported formats: PDF, DOCX, or DOC',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                ),
                if (selectedReportFile != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    selectedReportFile!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onBrowse,
                    child: const Text('Browse Files'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LecturerFeedbackCard extends StatelessWidget {
  const _LecturerFeedbackCard({required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lecturer Feedback',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.lecturerName ?? 'Dosen Pembimbing',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dosen Pembimbing',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                    ),
                  ],
                ),
              ),
              Text(
                'Today, 08:30',
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.neutral),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F5FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              report.feedbackFromLecturer ??
                  'Your weekly report is strong. Keep documenting decisions clearly and show the impact of each iteration.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DevStatusMenu extends StatelessWidget {
  const _DevStatusMenu({required this.currentStatus, required this.onChanged});

  final ApplicationStatus currentStatus;
  final ValueChanged<ApplicationStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      child: PopupMenuButton<ApplicationStatus>(
        onSelected: onChanged,
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: ApplicationStatus.submitted,
                child: Text('Set Submitted'),
              ),
              const PopupMenuItem(
                value: ApplicationStatus.underReview,
                child: Text('Set Under Review'),
              ),
              const PopupMenuItem(
                value: ApplicationStatus.interview,
                child: Text('Set Interview'),
              ),
              const PopupMenuItem(
                value: ApplicationStatus.rejected,
                child: Text('Set Rejected'),
              ),
              const PopupMenuItem(
                value: ApplicationStatus.accepted,
                child: Text('Set Accepted'),
              ),
            ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DEV',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              Text(
                currentStatus.label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.neutral),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
