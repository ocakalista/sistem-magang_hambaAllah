import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';

import '../../models/admin_model.dart';
import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';

class AdminEnrollmentsScreen extends StatefulWidget {
  const AdminEnrollmentsScreen({super.key});

  @override
  State<AdminEnrollmentsScreen> createState() => _AdminEnrollmentsScreenState();
}

class _AdminEnrollmentsScreenState extends State<AdminEnrollmentsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = NexusScope.of(context);
    final items =
        state.studentEnrollments.where((item) {
          final query = _query.toLowerCase();
          return item.name.toLowerCase().contains(query) ||
              item.program.toLowerCase().contains(query) ||
              item.company.toLowerCase().contains(query);
        }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Student Enrollment')),
      body: RefreshIndicator(
        onRefresh: state.loadAdminEnrollments,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: tr('Cari mahasiswa, posisi, atau perusahaan...'),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(child: Text('Belum ada data enrollment.')),
              )
            else
              ...items.map((item) => _EnrollmentCard(item: item)),
          ],
        ),
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({required this.item});
  final StudentEnrollment item;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                child: Icon(Icons.school, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Chip(
                label: Text(
                  item.status.isEmpty ? 'UNKNOWN' : item.status.toUpperCase(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(item.program.isEmpty ? 'Posisi belum tersedia' : item.program),
          if (item.company.isNotEmpty) Text(item.company),
          if (item.email.isNotEmpty)
            Text(item.email, style: const TextStyle(color: AppColors.neutral)),
        ],
      ),
    ),
  );
}
