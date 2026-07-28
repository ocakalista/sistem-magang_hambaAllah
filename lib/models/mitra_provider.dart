import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'application_model.dart';
import 'mitra_model.dart';

class MitraProvider extends ChangeNotifier {
  MitraProvider();

  MitraInfo info = const MitraInfo(
    idMitra: '',
    idUser: '',
    companyName: 'Mitra',
  );

  MitraStats stats = const MitraStats(
    totalLowongan: 0,
    pendaftarBaru: 0,
    pendaftarGrowthPercent: 0,
    diterima: 0,
    approvalRate: 0,
  );

  final List<PendaftarTerbaru> pendaftarTerbaru = <PendaftarTerbaru>[];

  bool isLoadingLowongan = false;
  String? lowonganError;

  InsightMingguan insight = const InsightMingguan(
    insightText: 'Statistik dihitung dari data pelamar di server.',
    capacityUsed: 0,
    capacityTotal: 0,
  );

  List<LowonganMitra> lowonganList = <LowonganMitra>[];

  Future<void> loadLowongan(String? token) async {
    isLoadingLowongan = true;
    lowonganError = null;
    notifyListeners();

    if (token == null || token.isEmpty) {
      lowonganError = 'Token tidak tersedia. Silakan login ulang.';
      isLoadingLowongan = false;
      notifyListeners();
      return;
    }

    final infoFuture = _loadMitraInfo(token);

    try {
      final fetched = await ApiService.fetchMitraLowongan(token);
      lowonganList = fetched;
      stats = stats.copyWith(totalLowongan: fetched.length);

      // Daftar lowongan adalah data utama halaman. Tampilkan segera tanpa
      // menunggu profil dan request pelamar untuk setiap lowongan.
      isLoadingLowongan = false;
      notifyListeners();

      final applicantRows = await Future.wait(
        fetched.map((lowongan) => _loadApplicants(token, lowongan)),
      );
      final applicants = <PendaftarTerbaru>[];
      for (final result in applicantRows) {
        final lowongan = result.lowongan;
        final rows = result.rows;
        for (final row in rows) {
          applicants.add(
            PendaftarTerbaru(
              id: row['id_pendaftaran']?.toString() ?? '',
              lowonganId: lowongan.id,
              name: row['nama_mahasiswa']?.toString() ?? '',
              position: lowongan.position,
              avatarUrl: null,
              appliedAt:
                  DateTime.tryParse(row['tanggal_daftar']?.toString() ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0),
              status: Application.statusFromApi(row['status']),
              nim: row['nim']?.toString(),
              major: row['jurusan']?.toString(),
              cvUrl:
                  (row['url_cv'] ??
                          row['cv_url'] ??
                          row['berkas_cv_url'] ??
                          row['cv'] ??
                          row['berkas_cv'])
                      ?.toString(),
              email: row['email']?.toString(),
              phone: (row['no_telp'] ?? row['phone'])?.toString(),
              semester: row['semester']?.toString(),
              motivation: (row['motivasi'] ?? row['motivation'])?.toString(),
              portfolioUrl:
                  (row['url_portofolio'] ??
                          row['portofolio_url'] ??
                          row['portfolio_link'] ??
                          row['portofolio_link'] ??
                          row['portfolio_url'] ??
                          row['berkas_portofolio_url'] ??
                          row['berkas_portofolio'])
                      ?.toString(),
            ),
          );
        }
      }
      applicants.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      pendaftarTerbaru
        ..clear()
        ..addAll(applicants);
      final accepted =
          applicants
              .where((item) => item.status == ApplicationStatus.accepted)
              .length;
      stats = MitraStats(
        totalLowongan: fetched.length,
        pendaftarBaru: applicants.length,
        pendaftarGrowthPercent: 0,
        diterima: accepted,
        approvalRate:
            applicants.isEmpty ? 0 : (accepted / applicants.length) * 100,
      );
      insight = InsightMingguan(
        insightText:
            '${applicants.length} pelamar dari ${fetched.length} lowongan.',
        capacityUsed: applicants.length.toDouble(),
        capacityTotal: fetched.fold<double>(
          0,
          (total, item) => total + item.quota + item.applicantCount,
        ),
      );
    } catch (e) {
      lowonganError = e.toString();
    } finally {
      isLoadingLowongan = false;
      notifyListeners();
    }

    await infoFuture;
  }

  Future<void> _loadMitraInfo(String token) async {
    try {
      final user = await ApiService.fetchCurrentUser(token);
      final data =
          user['data'] is Map
              ? (user['data'] as Map).cast<String, dynamic>()
              : user;
      final mitra =
          data['mitra'] is Map
              ? (data['mitra'] as Map).cast<String, dynamic>()
              : data['profile'] is Map
              ? (data['profile'] as Map).cast<String, dynamic>()
              : const <String, dynamic>{};

      String firstValue(List<String> keys, {String fallback = ''}) {
        for (final source in [mitra, data, user]) {
          for (final key in keys) {
            final value = source[key]?.toString().trim();
            if (value != null && value.isNotEmpty) return value;
          }
        }
        return fallback;
      }

      info = MitraInfo(
        idMitra: firstValue(const ['id_mitra', 'id']),
        idUser: firstValue(const ['id_user', 'user_id', 'id']),
        companyName: firstValue(const [
          'nama_perusahaan',
          'company_name',
          'company',
          'name',
        ], fallback: 'Mitra'),
      );
      notifyListeners();
    } catch (_) {
      // Profil bukan prasyarat untuk menampilkan daftar lowongan.
    }
  }

  Future<({LowonganMitra lowongan, List<Map<String, dynamic>> rows})>
  _loadApplicants(String token, LowonganMitra lowongan) async {
    try {
      final rows = await ApiService.fetchApplicants(token, lowongan.id);
      return (lowongan: lowongan, rows: rows);
    } catch (_) {
      // Satu endpoint pelamar yang gagal tidak boleh menahan semua lowongan.
      return (lowongan: lowongan, rows: <Map<String, dynamic>>[]);
    }
  }

  Future<void> tambahLowongan(
    String token,
    Map<String, dynamic> payload,
  ) async {
    await ApiService.createLowongan(token, payload);
    await loadLowongan(token);
  }

  Future<void> updateApplicantStatus(
    String token,
    String id,
    ApplicationStatus status,
  ) async {
    final index = pendaftarTerbaru.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    final apiStatus =
        status == ApplicationStatus.accepted ? 'diterima' : 'ditolak';
    await ApiService.updateApplicantStatus(token, id, apiStatus);
    pendaftarTerbaru[index] = PendaftarTerbaru(
      id: pendaftarTerbaru[index].id,
      lowonganId: pendaftarTerbaru[index].lowonganId,
      name: pendaftarTerbaru[index].name,
      position: pendaftarTerbaru[index].position,
      avatarUrl: pendaftarTerbaru[index].avatarUrl,
      appliedAt: pendaftarTerbaru[index].appliedAt,
      status: status,
      nim: pendaftarTerbaru[index].nim,
      major: pendaftarTerbaru[index].major,
      cvUrl: pendaftarTerbaru[index].cvUrl,
      email: pendaftarTerbaru[index].email,
      phone: pendaftarTerbaru[index].phone,
      semester: pendaftarTerbaru[index].semester,
      motivation: pendaftarTerbaru[index].motivation,
      portfolioUrl: pendaftarTerbaru[index].portfolioUrl,
    );
    notifyListeners();
  }
}
