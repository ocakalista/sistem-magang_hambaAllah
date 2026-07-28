import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';
import 'package:provider/provider.dart';

import '../../models/application_model.dart';
import '../../models/mitra_model.dart';
import '../../models/mitra_provider.dart';
import '../../theme/app_theme.dart';
import 'pendaftar_detail_screen.dart';

class MitraApplicantsScreen extends StatefulWidget {
  const MitraApplicantsScreen({super.key});

  @override
  State<MitraApplicantsScreen> createState() => _MitraApplicantsScreenState();
}

class _MitraApplicantsScreenState extends State<MitraApplicantsScreen> {
  String _query = '';
  ApplicationStatus? _status;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MitraProvider>();
    final applicants =
        provider.pendaftarTerbaru.where((item) {
          final matchesQuery =
              item.name.toLowerCase().contains(_query.toLowerCase()) ||
              item.position.toLowerCase().contains(_query.toLowerCase());
          return matchesQuery && (_status == null || item.status == _status);
        }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Semua Pendaftar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: tr('Cari mahasiswa atau posisi...'),
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              children: [
                _chip('Semua', null),
                _chip('Applied', ApplicationStatus.submitted),
                _chip('Diterima', ApplicationStatus.accepted),
                _chip('Ditolak', ApplicationStatus.rejected),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                applicants.isEmpty
                    ? const Center(child: Text('Tidak ada pendaftar.'))
                    : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: applicants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final applicant = applicants[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.15,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(applicant.name),
                            subtitle: Text(applicant.position),
                            trailing: Chip(
                              label: Text(applicant.status.mitraBadgeLabel),
                              backgroundColor: applicant.status.mitraBadgeColor,
                              labelStyle: TextStyle(
                                color: applicant.status.mitraBadgeTextColor,
                                fontSize: 11,
                              ),
                            ),
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => PendaftarDetailScreen(
                                          applicant: applicant,
                                        ),
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, ApplicationStatus? value) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _status == value,
      backgroundColor: Colors.white,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: _status == value ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      side: BorderSide.none,
      onSelected: (_) => setState(() => _status = value),
    ),
  );
}
