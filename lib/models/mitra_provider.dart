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

    try {
      final user = await ApiService.fetchCurrentUser(token);
      info = MitraInfo(
        idMitra: '',
        idUser: user['id']?.toString() ?? '',
        companyName: user['name']?.toString() ?? 'Mitra',
      );
      final fetched = await ApiService.fetchMitraLowongan(token);
      lowonganList = fetched;
      final applicants = <PendaftarTerbaru>[];
      for (final lowongan in fetched) {
        final rows = await ApiService.fetchApplicants(token, lowongan.id);
        for (final row in rows) {
          applicants.add(
            PendaftarTerbaru(
              id: row['id_pendaftaran']?.toString() ?? '',
              name: row['nama_mahasiswa']?.toString() ?? '',
              position: lowongan.position,
              avatarUrl: null,
              appliedAt:
                  DateTime.tryParse(row['tanggal_daftar']?.toString() ?? '') ??
                  DateTime.fromMillisecondsSinceEpoch(0),
              status: Application.statusFromApi(row['status']),
              nim: row['nim']?.toString(),
              major: row['jurusan']?.toString(),
              cvUrl: row['url_cv']?.toString(),
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
    }
    isLoadingLowongan = false;
    notifyListeners();
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
      name: pendaftarTerbaru[index].name,
      position: pendaftarTerbaru[index].position,
      avatarUrl: pendaftarTerbaru[index].avatarUrl,
      appliedAt: pendaftarTerbaru[index].appliedAt,
      status: status,
      nim: pendaftarTerbaru[index].nim,
      major: pendaftarTerbaru[index].major,
      cvUrl: pendaftarTerbaru[index].cvUrl,
    );
    notifyListeners();
  }
}
