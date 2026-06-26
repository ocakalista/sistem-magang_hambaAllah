import 'package:flutter/material.dart';

import 'admin_model.dart';
import 'application_model.dart';
import 'mitra_model.dart';

class MitraProvider extends ChangeNotifier {
  MitraProvider();

  MitraStats stats = const MitraStats(
    totalLowongan: 12,
    pendaftarBaru: 48,
    pendaftarGrowthPercent: 15.0,
    diterima: 24,
    approvalRate: 85.0,
  );

  final List<PendaftarTerbaru> pendaftarTerbaru = [
    PendaftarTerbaru(
      id: 'm-1',
      name: 'Ahmad Sulaiman',
      position: 'Fullstack Developer Intern',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
      appliedAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: ApplicationStatus.underReview,
    ),
    PendaftarTerbaru(
      id: 'm-2',
      name: 'Sarah Putri',
      position: 'UI/UX Designer Intern',
      avatarUrl: 'https://i.pravatar.cc/150?img=12',
      appliedAt: DateTime.now().subtract(const Duration(hours: 5)),
      status: ApplicationStatus.interview,
    ),
    PendaftarTerbaru(
      id: 'm-3',
      name: 'Budi Santoso',
      position: 'Data Scientist Intern',
      avatarUrl: 'https://i.pravatar.cc/150?img=32',
      appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: ApplicationStatus.submitted,
    ),
  ];

  InsightMingguan insight = const InsightMingguan(
    insightText:
        'Interaksi postingan Anda meningkat 24% dibandingkan minggu lalu. Posisi UI/UX Designer paling banyak diminati.',
    capacityUsed: 70,
    capacityTotal: 100,
  );

  final List<LowonganMitra> lowonganList = [
    LowonganMitra(
      id: 'm-l-1',
      position: 'Frontend Developer Intern',
      category: 'Engineering',
      location: 'Remote',
      tags: ['Remote', 'Full-time', '6 Months'],
      period: 'Jul - Des 2026',
      quota: 4,
      applicantCount: 24,
      description:
          'Bergabung dengan tim produk kami untuk membangun antarmuka web yang dinamis dan terukur menggunakan Flutter Web dan React.',
      requirements: [
        'Sedang menempuh studi TI atau sejenisnya',
        'Menguasai HTML, CSS, dan JavaScript',
        'Paham prinsip desain responsif',
      ],
      benefits: ['Competitive Stipend', 'Mentorship Program'],
      approvalStatus: LowonganApprovalStatus.approved,
      deadline: DateTime.now().add(const Duration(days: 16)),
    ),
  ];

  void tambahLowongan(LowonganMitra lowongan) {
    final pendingLowongan = LowonganMitra(
      id: 'm-l-${DateTime.now().millisecondsSinceEpoch}',
      position: lowongan.position,
      category: lowongan.category,
      location: lowongan.location,
      tags: lowongan.tags,
      period: lowongan.period,
      quota: lowongan.quota,
      applicantCount: lowongan.applicantCount,
      description: lowongan.description,
      requirements: lowongan.requirements,
      benefits: lowongan.benefits,
      approvalStatus: LowonganApprovalStatus.pending,
      deadline: lowongan.deadline,
    );

    lowonganList.insert(0, pendingLowongan);
    stats = stats.copyWith(totalLowongan: stats.totalLowongan + 1);
    notifyListeners();
  }

  void updateApplicantStatus(String id, ApplicationStatus status) {
    final index = pendaftarTerbaru.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }

    pendaftarTerbaru[index] = PendaftarTerbaru(
      id: pendaftarTerbaru[index].id,
      name: pendaftarTerbaru[index].name,
      position: pendaftarTerbaru[index].position,
      avatarUrl: pendaftarTerbaru[index].avatarUrl,
      appliedAt: pendaftarTerbaru[index].appliedAt,
      status: status,
    );
    notifyListeners();
  }
}
