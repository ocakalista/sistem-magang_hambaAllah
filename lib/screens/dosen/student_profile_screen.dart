import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';

import '../../models/dosen_model.dart';
import '../../theme/app_theme.dart';
import 'weekly_report_detail_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key, required this.student});

  final MahasiswaBimbingan student;

  @override
  Widget build(BuildContext context) {
    final initial =
        student.name.trim().isEmpty
            ? '?'
            : student.name.trim()[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profil Mahasiswa')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  student.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  student.internshipPosition,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoCard(
            children: [
              _InfoRow(
                icon: Icons.badge_outlined,
                label: 'NIM / ID Mahasiswa',
                value: student.id,
              ),
              if (_hasValue(student.studyProgram))
                _InfoRow(
                  icon: Icons.school_outlined,
                  label: 'Program Studi',
                  value: student.studyProgram!,
                ),
              if (_hasValue(student.email))
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: student.email!,
                ),
              if (_hasValue(student.phone))
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Telepon',
                  value: student.phone!,
                ),
              if (_hasValue(student.company))
                _InfoRow(
                  icon: Icons.business_outlined,
                  label: 'Perusahaan',
                  value: student.company!,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _ProgressCard(student: student),
          const SizedBox(height: 20),
          Text(
            'Riwayat Weekly Report',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (student.weeklyReports.isEmpty)
            const _EmptyReports()
          else
            ...student.weeklyReports.reversed.map(
              (report) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(
                    report.isApproved
                        ? Icons.check_circle_rounded
                        : Icons.description_outlined,
                    color: report.isApproved ? Colors.green : AppColors.primary,
                  ),
                  title: Text('Minggu ${report.weekNumber} — ${report.title}'),
                  subtitle: Text(
                    report.isApproved ? 'Disetujui' : 'Menunggu review',
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => WeeklyReportDetailScreen(
                                report: report,
                                student: student,
                              ),
                        ),
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static bool _hasValue(String? value) =>
      value != null && value.trim().isNotEmpty;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.neutral),
                ),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.student});

  final MahasiswaBimbingan student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress Magang',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                '${(student.progressPercent * 100).round()}%',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: student.progressPercent,
            minHeight: 8,
            borderRadius: BorderRadius.circular(99),
            backgroundColor: AppColors.background,
          ),
          const SizedBox(height: 8),
          Text(
            'Minggu ${student.currentWeek} dari ${student.totalWeeks}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
          ),
        ],
      ),
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(child: Text('Belum ada weekly report.')),
    );
  }
}
