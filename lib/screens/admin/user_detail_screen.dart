import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';

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
    final role = (data['role'] ?? user.role).toString().toLowerCase();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _card('Data akun', [
          _row('Nama', (data['name'] ?? user.name).toString()),
          _row('Role', (data['role'] ?? user.role).toString()),
          _row('Email/NIM', (data['email'] ?? user.email).toString()),
          _row('Telepon', (data['phone'] ?? user.phone ?? '-').toString()),
          ...profile.entries
              .where((entry) => !_hiddenProfileFields.contains(entry.key))
              .map(
                (entry) => _row(_label(entry.key), _displayValue(entry.value)),
              ),
        ]),
        if (_isMahasiswa(role)) ..._studentSections(data),
        if (_isDosen(role)) ..._lecturerSections(data),
        if (_isMitra(role)) ..._partnerSections(data),
      ],
    );
  }

  static const _hiddenProfileFields = {
    'id',
    'user_id',
    'id_user',
    'created_at',
    'updated_at',
  };

  bool _isMahasiswa(String role) => role == 'mahasiswa' || role == 'student';
  bool _isDosen(String role) =>
      role == 'dosen' || role == 'lecturer' || role == 'teacher';
  bool _isMitra(String role) => role == 'mitra' || role == 'partner';

  List<Widget> _studentSections(Map<String, dynamic> data) => [
    const SizedBox(height: 14),
    _relationCard(
      'Lowongan yang Dilamar',
      _list(data['applications']),
      fields: const [
        'judul_posisi',
        'nama_perusahaan',
        'status',
        'tanggal_daftar',
        'progress',
      ],
      emptyText: 'Mahasiswa belum memiliki riwayat lamaran.',
    ),
    const SizedBox(height: 14),
    _relationCard(
      'Dosen Pembimbing',
      _supervisors(data),
      fields: const ['nama_dosen', 'nidn', 'email', 'jumlah_logbook'],
      emptyText: 'Dosen pembimbing belum ditentukan.',
    ),
  ];

  List<Widget> _lecturerSections(Map<String, dynamic> data) => [
    const SizedBox(height: 14),
    _relationCard(
      'Mahasiswa Bimbingan',
      _list(data['supervised_students']),
      fields: const [
        'nama_mahasiswa',
        'nim',
        'judul_posisi',
        'nama_perusahaan',
        'status',
        'jumlah_logbook',
        'progress',
      ],
      emptyText: 'Belum ada mahasiswa bimbingan.',
    ),
  ];

  List<Widget> _partnerSections(Map<String, dynamic> data) => [
    const SizedBox(height: 14),
    _relationCard(
      'Lowongan Mitra',
      _list(data['vacancies']),
      fields: const [
        'judul_posisi',
        'status_approval',
        'kuota',
        'jumlah_pendaftar',
      ],
      emptyText: 'Mitra belum memiliki lowongan.',
    ),
    const SizedBox(height: 14),
    _relationCard(
      'Pendaftar Lowongan',
      _list(data['applicants']),
      fields: const [
        'nama_mahasiswa',
        'nim',
        'judul_posisi',
        'status',
        'tanggal_daftar',
      ],
      emptyText: 'Belum ada mahasiswa yang mendaftar.',
    ),
  ];

  List<Map<String, dynamic>> _supervisors(Map<String, dynamic> data) {
    final direct =
        data['supervisor'] ??
        data['lecturer'] ??
        data['dosen_pembimbing'] ??
        data['pembimbing'];
    if (direct is Map) {
      return [direct.cast<String, dynamic>()];
    }
    final applications = _list(data['applications']);
    final result = <Map<String, dynamic>>[];
    for (final application in applications) {
      final nested =
          application['dosen_pembimbing'] ??
          application['supervisor'] ??
          application['lecturer'];
      if (nested is Map) {
        result.add(nested.cast<String, dynamic>());
      } else if (nested != null && nested.toString().trim().isNotEmpty) {
        result.add({'nama_dosen': nested});
      }
    }
    return result;
  }

  List<Map<String, dynamic>> _list(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => item.cast<String, dynamic>())
        .toList();
  }

  Widget _relationCard(
    String title,
    List<Map<String, dynamic>> items, {
    required List<String> fields,
    required String emptyText,
  }) {
    return _card(
      title,
      items.isEmpty
          ? [Text(emptyText, style: const TextStyle(color: AppColors.neutral))]
          : [
            for (var index = 0; index < items.length; index++) ...[
              if (index > 0) const Divider(height: 24),
              ..._itemRows(items[index], fields),
            ],
          ],
    );
  }

  List<Widget> _itemRows(
    Map<String, dynamic> item,
    List<String> preferredFields,
  ) {
    final rows = <Widget>[];
    for (final field in preferredFields) {
      final value = _findValue(item, field);
      if (value == null || value.toString().trim().isEmpty) continue;
      rows.add(_row(_label(field), _displayValue(value)));
    }
    if (rows.isNotEmpty) return rows;
    return item.entries
        .where((entry) => !_hiddenProfileFields.contains(entry.key))
        .map((entry) => _row(_label(entry.key), _displayValue(entry.value)))
        .toList();
  }

  dynamic _findValue(Map<String, dynamic> item, String key) {
    if (item.containsKey(key)) return item[key];
    const aliases = {
      'nim': ['id_mahasiswa', 'email'],
      'nidn': ['id_dosen'],
      'nama_dosen': ['dosen_pembimbing', 'nama_pembimbing'],
      'nama_mahasiswa': ['name', 'nama'],
      'judul_posisi': ['position', 'program'],
      'nama_perusahaan': ['company', 'company_name'],
      'status': ['status_pendaftaran', 'application_status'],
      'jumlah_logbook': ['logbook_count'],
      'jumlah_pendaftar': ['applicant_count'],
    };
    for (final alias in aliases[key] ?? const <String>[]) {
      if (item.containsKey(alias)) return item[alias];
    }
    return null;
  }

  String _label(String key) {
    const labels = {
      'nim': 'NIM',
      'nidn': 'NIDN',
      'nama': 'Nama',
      'nama_mahasiswa': 'Mahasiswa',
      'nama_dosen': 'Dosen pembimbing',
      'program_studi': 'Program studi',
      'jurusan': 'Program studi',
      'semester': 'Semester',
      'judul_posisi': 'Lowongan',
      'status': 'Status',
      'status_approval': 'Status lowongan',
      'tanggal_daftar': 'Tanggal daftar',
      'jumlah_logbook': 'Logbook',
      'jumlah_pendaftar': 'Pendaftar',
      'kuota': 'Kuota',
      'progress': 'Progres',
      'email': 'Email',
      'telepon': 'Telepon',
      'phone': 'Telepon',
      'nama_perusahaan': 'Nama perusahaan',
      'id_mitra': 'ID Mitra',
    };
    return labels[key] ??
        key
            .split('_')
            .map(
              (part) =>
                  part.isEmpty
                      ? part
                      : '${part[0].toUpperCase()}${part.substring(1)}',
            )
            .join(' ');
  }

  String _displayValue(dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'null') return '-';
    if (value is Map) {
      return (value['nama_dosen'] ??
              value['nama'] ??
              value['name'] ??
              value['nama_perusahaan'] ??
              '-')
          .toString();
    }
    if (value is List) return value.join(', ');
    final text = value.toString();
    if (text.contains('T') && DateTime.tryParse(text) != null) {
      final date = DateTime.parse(text).toLocal();
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
    return text;
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
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(label, style: const TextStyle(color: AppColors.neutral)),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 6,
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
