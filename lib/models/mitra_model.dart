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

  PendaftarTerbaru({
    required this.id,
    required this.name,
    required this.position,
    required this.avatarUrl,
    required this.appliedAt,
    required this.status,
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
