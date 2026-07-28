import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/api_config.dart';
import '../../models/application_model.dart';
import '../../theme/app_theme.dart';

class LogbookDetailScreen extends StatelessWidget {
  const LogbookDetailScreen({super.key, required this.report});

  final WeeklyReport report;

  @override
  Widget build(BuildContext context) {
    final status = _statusData(report.status);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Logbook Minggu ${report.weekNumber}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        report.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: status.$2.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.$1,
                        style: TextStyle(
                          color: status.$2,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Tanggal',
                  value: _formatDate(report.dueDate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Kegiatan Mingguan'),
                const SizedBox(height: 10),
                Text(
                  report.description.isEmpty
                      ? 'Deskripsi belum tersedia.'
                      : report.description,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('File Laporan'),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFF1E8FF),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: Text(
                    report.reportFileUrl == null
                        ? 'PDF tidak tersedia'
                        : 'Buka PDF Logbook',
                  ),
                  subtitle: const Text('Dokumen laporan mingguan'),
                  trailing:
                      report.reportFileUrl == null
                          ? null
                          : const Icon(Icons.open_in_new_rounded),
                  onTap:
                      report.reportFileUrl == null
                          ? null
                          : () => _openDocument(context, report.reportFileUrl!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionTitle('Feedback Dosen Pembimbing'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFF1E8FF),
                      child: Icon(
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
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const Text(
                            'Dosen Pembimbing',
                            style: TextStyle(color: AppColors.neutral),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F5FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    report.feedbackFromLecturer?.trim().isNotEmpty == true
                        ? report.feedbackFromLecturer!
                        : 'Belum ada feedback dari dosen pembimbing.',
                    style: const TextStyle(height: 1.45),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _statusData(String value) {
    switch (value) {
      case 'completed':
        return ('DISETUJUI', Colors.green);
      case 'revision':
        return ('PERLU REVISI', Colors.orange);
      default:
        return ('MENUNGGU REVIEW', AppColors.primary);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _openDocument(BuildContext context, String rawUrl) async {
    final uri = _documentUri(rawUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF logbook tidak dapat dibuka.')),
    );
  }

  Uri _documentUri(String value) {
    final normalized = value.trim().replaceAll('\\', '/');
    final parsed = Uri.tryParse(normalized);
    if (parsed != null && parsed.hasScheme) return parsed;
    final apiUri = Uri.parse(ApiConfig.baseUrl);
    var path = normalized.startsWith('/') ? normalized : '/$normalized';
    if (!path.startsWith('/storage/')) path = '/storage$path';
    return apiUri.replace(path: path);
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(color: AppColors.neutral)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
