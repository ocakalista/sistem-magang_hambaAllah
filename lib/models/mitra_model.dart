import 'package:flutter/material.dart';

import 'admin_model.dart';
import 'application_model.dart';
import '../theme/app_theme.dart';

class MitraStats {
  final int totalLowongan;
  final int pendaftarBaru;
  final double pendaftarGrowthPercent;
  final int diterima;
  final double approvalRate;

  const MitraStats({
    required this.totalLowongan,
    required this.pendaftarBaru,
    required this.pendaftarGrowthPercent,
    required this.diterima,
    required this.approvalRate,
  });

  MitraStats copyWith({
    int? totalLowongan,
    int? pendaftarBaru,
    double? pendaftarGrowthPercent,
    int? diterima,
    double? approvalRate,
  }) {
    return MitraStats(
      totalLowongan: totalLowongan ?? this.totalLowongan,
      pendaftarBaru: pendaftarBaru ?? this.pendaftarBaru,
      pendaftarGrowthPercent:
          pendaftarGrowthPercent ?? this.pendaftarGrowthPercent,
      diterima: diterima ?? this.diterima,
      approvalRate: approvalRate ?? this.approvalRate,
    );
  }
}

class PendaftarTerbaru {
  final String id;
  final String name;
  final String position;
  final String? avatarUrl;
  final DateTime appliedAt;
  final ApplicationStatus status;
  final String? nim;
  final String? major;
  final String? cvUrl;

  PendaftarTerbaru({
    required this.id,
    required this.name,
    required this.position,
    required this.avatarUrl,
    required this.appliedAt,
    required this.status,
    this.nim,
    this.major,
    this.cvUrl,
  });
}

class InsightMingguan {
  final String insightText;
  final double capacityUsed;
  final double capacityTotal;

  const InsightMingguan({
    required this.insightText,
    required this.capacityUsed,
    required this.capacityTotal,
  });
}

class MitraInfo {
  final String idMitra;
  final String idUser;
  final String companyName;

  const MitraInfo({
    required this.idMitra,
    required this.idUser,
    required this.companyName,
  });
}

class LowonganMitra {
  final String id;
  final String position;
  final String category;
  final String location;
  final List<String> tags;
  final String period;
  final int quota;
  final int applicantCount;
  final String description;
  final List<String> requirements;
  final List<String> benefits;
  final LowonganApprovalStatus approvalStatus;
  final DateTime deadline;

  LowonganMitra({
    required this.id,
    required this.position,
    required this.category,
    required this.location,
    required this.tags,
    required this.period,
    required this.quota,
    required this.applicantCount,
    required this.description,
    required this.requirements,
    required this.benefits,
    required this.approvalStatus,
    required this.deadline,
  });

  factory LowonganMitra.fromJson(Map<String, dynamic> json) {
    final approvalString =
        json['status_approval'] ??
        json['approval_status'] ??
        json['approvalStatus'] ??
        json['status'] ??
        'pending';
    final deadlineRaw =
        json['batas_waktu'] ??
        json['deadline'] ??
        json['tanggal_berakhir'] ??
        json['tgl_deadline'] ??
        json['end_date'];

    return LowonganMitra(
      id: json['id']?.toString() ?? json['id_lowongan']?.toString() ?? '',
      position:
          json['position'] ??
          json['title'] ??
          json['judul_posisi'] ??
          json['posisi'] ??
          '',
      category: json['category'] ?? json['kategori'] ?? json['jenis'] ?? '',
      location: json['location'] ?? json['lokasi'] ?? '',
      tags: _normalizeStringList(
        json['tags'] ??
            [
              json['tipe_kerja'],
              json['tipe_kontrak'],
            ].whereType<String>().toList(),
      ),
      period: json['period'] ?? json['periode'] ?? '',
      quota:
          int.tryParse((json['kuota'] ?? json['quota'])?.toString() ?? '') ?? 0,
      applicantCount:
          int.tryParse(json['applicant_count']?.toString() ?? '') ??
          int.tryParse(json['applicantCount']?.toString() ?? '') ??
          0,
      description:
          json['description'] ?? json['deskripsi'] ?? json['detail'] ?? '',
      requirements: _normalizeStringList(
        json['requirements'] ?? json['persyaratan'] ?? [],
      ),
      benefits: _normalizeStringList(
        json['benefit'] ?? json['benefits'] ?? json['keuntungan'] ?? [],
      ),
      approvalStatus: LowonganApprovalStatus.values.firstWhere(
        (status) =>
            status.name.toLowerCase() ==
            approvalString.toString().toLowerCase(),
        orElse: () => LowonganApprovalStatus.pending,
      ),
      deadline:
          DateTime.tryParse(deadlineRaw?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static List<String> _normalizeStringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String) {
      return value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <String>[];
  }
}

extension ApplicationStatusMitraBadge on ApplicationStatus {
  String get mitraBadgeLabel {
    switch (this) {
      case ApplicationStatus.submitted:
        return 'APPLIED';
      case ApplicationStatus.underReview:
        return 'REVIEW';
      case ApplicationStatus.interview:
        return 'INTERVIEW';
      case ApplicationStatus.accepted:
        return 'ACCEPTED';
      case ApplicationStatus.rejected:
        return 'REJECTED';
    }
  }

  Color get mitraBadgeColor {
    switch (this) {
      case ApplicationStatus.submitted:
        return AppColors.neutral.withValues(alpha: 0.12);
      case ApplicationStatus.underReview:
        return AppColors.primary.withValues(alpha: 0.14);
      case ApplicationStatus.interview:
        return AppColors.secondary.withValues(alpha: 0.14);
      case ApplicationStatus.accepted:
        return Colors.green.withAlpha((0.16 * 255).round());
      case ApplicationStatus.rejected:
        return Colors.red.withAlpha((0.16 * 255).round());
    }
  }

  Color get mitraBadgeTextColor {
    switch (this) {
      case ApplicationStatus.submitted:
        return AppColors.neutral;
      case ApplicationStatus.underReview:
        return AppColors.primary;
      case ApplicationStatus.interview:
        return AppColors.secondary;
      case ApplicationStatus.accepted:
        return Colors.green.shade700;
      case ApplicationStatus.rejected:
        return Colors.red.shade700;
    }
  }
}
