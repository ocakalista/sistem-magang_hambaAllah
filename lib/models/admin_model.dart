import 'package:flutter/material.dart';

class PlatformStats {
  PlatformStats({
    required this.totalUsers,
    required this.totalUsersGrowthPercent,
    required this.activeInternships,
    required this.activeInternshipsGrowthPercent,
  });

  final int totalUsers;
  final double totalUsersGrowthPercent;
  final int activeInternships;
  final double activeInternshipsGrowthPercent;
}

class StudentEnrollment {
  StudentEnrollment({
    required this.id,
    required this.name,
    required this.email,
    required this.program,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String program;
  final String? avatarUrl;
}

enum LowonganApprovalStatus { pending, approved, rejected }

class PendingLowongan {
  PendingLowongan({
    required this.id,
    required this.companyName,
    required this.companyCategory,
    required this.requestDescription,
    this.status = LowonganApprovalStatus.pending,
  });

  final String id;
  final String companyName;
  final String companyCategory;
  final String requestDescription;
  LowonganApprovalStatus status;
}

class InternshipDistribution {
  InternshipDistribution({
    required this.category,
    required this.percent,
    required this.color,
  });

  final String category;
  final double percent;
  final Color color;
}
