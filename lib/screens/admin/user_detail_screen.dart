import 'package:flutter/material.dart';

import '../../models/admin_model.dart';
import '../../models/nexus_app_state.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class AdminUserDetailScreen extends StatelessWidget {
  const AdminUserDetailScreen({super.key, required this.user});

  final UserAccount user;

  @override
  Widget build(BuildContext context) {
    final token = NexusScope.of(context).authToken;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Detail Pengguna')),
      body:
          token == null
              ? const Center(child: Text('Sesi admin tidak tersedia.'))
              : FutureBuilder<Map<String, dynamic>>(
                future: ApiService.fetchAdminUserDetail(token, user.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _basicContent(
                      context,
                      error: 'Data relasi belum tersedia: ${snapshot.error}',
                    );
                  }
                  return _detailContent(context, snapshot.data!);
                },
              ),
    );
  }

  Widget _basicContent(BuildContext context, {String? error}) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      _card('Data akun', [
        _row('Nama', user.name),
        _row('Role', user.role),
        _row('Email/NIM', user.email),
        _row('Telepon', user.phone ?? '-'),
      ]),
      if (error != null) ...[
        const SizedBox(height: 14),
        Text(error, style: const TextStyle(color: Colors.red)),
      ],
    ],
  );

  Widget _detailContent(BuildContext context, Map<String, dynamic> data) {
    final profile =
        data['profile'] is Map
            ? (data['profile'] as Map).cast<String, dynamic>()
            : <String, dynamic>{};
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _card('Data akun', [
          _row('Nama', (data['name'] ?? user.name).toString()),
          _row('Role', (data['role'] ?? user.role).toString()),
          _row('Email/NIM', (data['email'] ?? user.email).toString()),
          _row('Telepon', (data['phone'] ?? user.phone ?? '-').toString()),
          ...profile.entries.map((entry) => _row(entry.key, '${entry.value}')),
        ]),
        ..._relationSections(data),
      ],
    );
  }

  List<Widget> _relationSections(Map<String, dynamic> data) {
    const relations = {
      'applications': 'Lamaran & Magang Mahasiswa',
      'supervised_students': 'Mahasiswa Bimbingan',
      'vacancies': 'Lowongan Mitra',
      'applicants': 'Pendaftar Mitra',
    };
    final widgets = <Widget>[];
    for (final entry in relations.entries) {
      final raw = data[entry.key];
      if (raw is! List) continue;
      widgets
        ..add(const SizedBox(height: 14))
        ..add(
          _card(
            entry.value,
            raw.isEmpty
                ? [const Text('Tidak ada data.')]
                : raw.map((item) {
                  if (item is Map) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        item.entries
                            .map((value) => '${value.key}: ${value.value}')
                            .join('\n'),
                      ),
                    );
                  }
                  return Text(item.toString());
                }).toList(),
          ),
        );
    }
    return widgets;
  }

  Widget _card(String title, List<Widget> children) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}
