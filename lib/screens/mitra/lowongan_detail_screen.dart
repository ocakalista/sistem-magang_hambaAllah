import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';
import 'package:provider/provider.dart';

import '../../models/mitra_model.dart';
import '../../models/mitra_provider.dart';
import '../../theme/app_theme.dart';
import 'pendaftar_detail_screen.dart';

class MitraLowonganDetailScreen extends StatelessWidget {
  const MitraLowonganDetailScreen({super.key, required this.lowongan});

  final LowonganMitra lowongan;

  @override
  Widget build(BuildContext context) {
    final applicants =
        context
            .watch<MitraProvider>()
            .pendaftarTerbaru
            .where((applicant) => applicant.lowonganId == lowongan.id)
            .toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Lowongan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lowongan.position,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  lowongan.category,
                  style: const TextStyle(color: AppColors.primary),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...lowongan.tags.map((tag) => Chip(label: Text(tag))),
                    Chip(label: Text('${lowongan.quota} kuota')),
                    Chip(
                      label: Text(lowongan.approvalStatus.name.toUpperCase()),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _Card(
            child: Column(
              children: [
                _Info(
                  icon: Icons.location_on_outlined,
                  label: 'Lokasi',
                  value: lowongan.location,
                ),
                _Info(
                  icon: Icons.calendar_today_outlined,
                  label: 'Deadline',
                  value: _date(lowongan.deadline),
                ),
                _Info(
                  icon: Icons.group_outlined,
                  label: 'Pendaftar',
                  value: '${applicants.length}',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ApplicantsSection(applicants: applicants),
          const SizedBox(height: 14),
          _Section(title: 'Deskripsi', text: lowongan.description),
          const SizedBox(height: 14),
          _ListSection(title: 'Persyaratan', items: lowongan.requirements),
          const SizedBox(height: 14),
          _ListSection(title: 'Benefit', items: lowongan.benefits),
        ],
      ),
    );
  }

  static String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class _ApplicantsSection extends StatelessWidget {
  const _ApplicantsSection({required this.applicants});

  final List<PendaftarTerbaru> applicants;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Daftar Pendaftar',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${applicants.length} mahasiswa',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (applicants.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: Text('Belum ada mahasiswa yang melamar.')),
            )
          else
            ...applicants.map(
              (applicant) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.14,
                      ),
                      child: Text(
                        applicant.name.isEmpty
                            ? '?'
                            : applicant.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    title: Text(
                      applicant.name.isEmpty ? 'Mahasiswa' : applicant.name,
                    ),
                    subtitle: Text(
                      [
                        applicant.nim,
                        applicant.semester == null
                            ? null
                            : 'Semester ${applicant.semester}',
                      ].whereType<String>().join(' • '),
                    ),
                    trailing: Chip(
                      label: Text(applicant.status.mitraBadgeLabel),
                      backgroundColor: applicant.status.mitraBadgeColor,
                      labelStyle: TextStyle(
                        color: applicant.status.mitraBadgeTextColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    PendaftarDetailScreen(applicant: applicant),
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
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Flexible(
          child: Text(
            value.isEmpty ? '-' : value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text(text.isEmpty ? 'Belum tersedia.' : text),
      ],
    ),
  );
}

class _ListSection extends StatelessWidget {
  const _ListSection({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) => _Card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (items.isEmpty)
          const Text('Belum tersedia.')
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [const Text('• '), Expanded(child: Text(item))],
              ),
            ),
          ),
      ],
    ),
  );
}
