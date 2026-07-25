import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../models/application_model.dart';
import '../../models/nexus_app_state.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import 'application_history_screen.dart';
import 'dashboard_mahasiswa.dart';
import 'profile_screen.dart';
import '../notifications_screen.dart';
import '../../widgets/bottom_nav.dart';
import 'logbook_detail_screen.dart';

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

    final reports = app.weeklyReports;
    final currentWeek = app.currentWeek ?? 0;
    final totalWeeks = (app.totalWeeks ?? 12).clamp(8, 52);
    final completedReports =
        reports.where((report) => report.status == 'completed').length;
    final progress = completedReports / totalWeeks;
    final remainingWeeks = (totalWeeks - currentWeek).clamp(0, totalWeeks);
    final feedbackReports =
        reports
            .where((report) => (report.feedbackFromLecturer ?? '').isNotEmpty)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap:
              () => Navigator.pushNamed(
                context,
                DashboardMahasiswaProfileScreen.routeName,
              ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
        ),
        actions: [
          IconButton(
            tooltip: 'Riwayat Lamaran',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => const ApplicationHistoryScreen(
                          showBackButton: true,
                        ),
                  ),
                ),
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            tooltip: 'Alerts',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  ),
                ),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
        children: [
          _ProgressCard(
            application: app,
            currentWeek: currentWeek,
            totalWeeks: totalWeeks,
            remainingWeeks: remainingWeeks,
            progress: progress,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => const ApplicationHistoryScreen(
                            showBackButton: true,
                          ),
                    ),
                  ),
              icon: const Icon(Icons.history_rounded),
              label: const Text('Riwayat Lamaran'),
            ),
          ),
          const SizedBox(height: 6),
          _SectionTitleWithAction(
            title: 'Weekly Timeline',
            actionLabel: 'View History',
            onAction:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => WeeklyHistoryScreen(
                          reports: reports,
                          totalWeeks: totalWeeks,
                        ),
                  ),
                ),
          ),
          const SizedBox(height: 10),
          reports.isEmpty
              ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: Text('Belum ada logbook dari server.')),
              )
              : _WeeklyTimeline(reports: reports),
          const SizedBox(height: 18),
          _UploadSection(
            selectedReportFile: _selectedReportFile,
            onBrowse: () => _showLogbookForm(app),
          ),
          const SizedBox(height: 18),
          if (feedbackReports.isNotEmpty)
            _LecturerFeedbackCard(report: feedbackReports.last),
        ],
      ),
      bottomNavigationBar: NexusBottomNavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) => _handleNav(context, index),
      ),
    );
  }

  Future<void> _showLogbookForm(Application application) async {
    final descriptionController = TextEditingController();
    final weekController = TextEditingController(
      text: ((application.currentWeek ?? 0) + 1).toString(),
    );
    List<int>? reportBytes;
    String? reportFileName;
    final submitted = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder:
                (context, setDialogState) => AlertDialog(
                  title: const Text('Isi Logbook Mingguan'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: weekController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Minggu ke',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: descriptionController,
                          minLines: 3,
                          maxLines: 6,
                          decoration: const InputDecoration(
                            labelText: 'Deskripsi kegiatan',
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: const ['pdf'],
                              withData: true,
                            );
                            final file = result?.files.single;
                            if (file?.bytes == null) return;
                            if (file!.size > 5 * 1024 * 1024) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Ukuran PDF maksimal 5 MB.',
                                  ),
                                ),
                              );
                              return;
                            }
                            setDialogState(() {
                              reportBytes = file.bytes;
                              reportFileName = file.name;
                            });
                          },
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: Text(
                            reportFileName ?? 'Pilih PDF Logbook',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Format PDF, maksimal 5 MB.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed:
                          reportBytes == null
                              ? null
                              : () => Navigator.pop(dialogContext, true),
                      child: const Text('Kirim'),
                    ),
                  ],
                ),
          ),
    );
    if (submitted != true || !mounted) return;
    final week = int.tryParse(weekController.text);
    final description = descriptionController.text.trim();
    if (week == null ||
        week < 1 ||
        description.isEmpty ||
        reportBytes == null ||
        reportFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minggu, deskripsi, dan PDF wajib diisi.'),
        ),
      );
      return;
    }
    final state = NexusScope.of(context);
    final token = state.authToken;
    if (token == null) return;
    try {
      await ApiService.createLogbook(
        token: token,
        applicationId: application.id,
        week: week,
        date: DateTime.now(),
        description: description,
        reportBytes: reportBytes!,
        reportFileName: reportFileName!,
      );
      await state.loadStudentApplications();
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logbook berhasil dikirim.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logbook gagal: $error')));
    }
  }

  void _handleNav(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, DashboardMahasiswa.routeName);
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        nexusTabRoute(const NotificationsScreen()),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacement(
        context,
        nexusTabRoute(const DashboardMahasiswaProfileScreen()),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Week ${report.weekNumber} - ${report.title}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 8),
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
                            _statusLabel(report.status),
                            maxLines: 1,
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

  String _statusLabel(String status) {
    switch (status) {
      case 'completed':
        return 'APPROVED';
      case 'revision':
        return 'REVISION';
      case 'ongoing':
        return 'ONGOING';
      default:
        return 'WAITING';
    }
  }
}

class WeeklyHistoryScreen extends StatelessWidget {
  const WeeklyHistoryScreen({
    super.key,
    required this.reports,
    required this.totalWeeks,
  });

  final List<WeeklyReport> reports;
  final int totalWeeks;

  @override
  Widget build(BuildContext context) {
    final reportsByWeek = {
      for (final report in reports) report.weekNumber: report,
    };
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Riwayat Weekly Logbook')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: totalWeeks,
        itemBuilder: (context, index) {
          final week = index + 1;
          final report = reportsByWeek[week];
          final approved = report?.status == 'completed';
          final revision = report?.status == 'revision';
          final status =
              report == null
                  ? 'Belum dikirim'
                  : approved
                  ? 'Disetujui dosen'
                  : revision
                  ? 'Perlu revisi'
                  : 'Menunggu persetujuan dosen';
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              onTap:
                  report == null
                      ? null
                      : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LogbookDetailScreen(report: report),
                        ),
                      ),
              leading: CircleAvatar(
                backgroundColor:
                    approved
                        ? Colors.green.withValues(alpha: 0.14)
                        : AppColors.primary.withValues(alpha: 0.10),
                child:
                    approved
                        ? const Icon(Icons.check, color: Colors.green)
                        : Text('$week'),
              ),
              title: Text('Minggu $week'),
              subtitle: Text(
                report == null || report.description.isEmpty
                    ? status
                    : '${report.description}\n$status',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: report != null && report.description.isNotEmpty,
              trailing: Icon(
                report != null
                    ? Icons.chevron_right_rounded
                    : approved
                    ? Icons.verified_rounded
                    : revision
                    ? Icons.edit_note_rounded
                    : report == null
                    ? Icons.lock_clock_outlined
                    : Icons.hourglass_top_rounded,
                color:
                    approved
                        ? Colors.green
                        : revision
                        ? Colors.orange
                        : AppColors.neutral,
              ),
            ),
          );
        },
      ),
    );
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
                  'Catat aktivitas mingguan',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Isi minggu, tanggal, dan deskripsi kegiatan',
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
                    child: const Text('Isi Logbook'),
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
                      report.lecturerName?.trim().isNotEmpty == true
                          ? report.lecturerName!
                          : 'Nama dosen belum tersedia',
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
                report.dueDate == null
                    ? '-'
                    : '${report.dueDate!.day.toString().padLeft(2, '0')}/${report.dueDate!.month.toString().padLeft(2, '0')}/${report.dueDate!.year}',
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
              report.feedbackFromLecturer ?? '',
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
