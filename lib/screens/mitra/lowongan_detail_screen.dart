import 'package:flutter/material.dart';

import '../../models/mitra_model.dart';
import '../../theme/app_theme.dart';

class MitraLowonganDetailScreen extends StatelessWidget {
  const MitraLowonganDetailScreen({super.key, required this.lowongan});

  final LowonganMitra lowongan;

  @override
  Widget build(BuildContext context) {
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
                  value: '${lowongan.applicantCount}',
                ),
              ],
            ),
          ),
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
