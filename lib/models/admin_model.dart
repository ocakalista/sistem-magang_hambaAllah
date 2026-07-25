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

class AdminProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String username;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AdminProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.username,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {
        return null;
      }
    }

    return AdminProfile(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? json['username'] ?? 'Admin',
      email: json['email'] ?? json['email_or_nim'] ?? '',
      role: json['role'] ?? json['jenis_pengguna'] ?? 'admin',
      username: json['username'] ?? json['user_name'] ?? '',
      phone: json['phone'] ?? json['telepon'] ?? json['phone_number'],
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }
}

class UserAccount {
  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.username,
    this.phone,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? username;
  final String? phone;
  final DateTime? createdAt;

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic raw) {
      if (raw == null) return null;
      try {
        return DateTime.parse(raw.toString());
      } catch (_) {
        return null;
      }
    }

    return UserAccount(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? json['username'] ?? 'User',
      email: json['email'] ?? json['email_or_nim'] ?? '',
      role:
          json['role'] ??
          json['jenis_pengguna'] ??
          json['user_role'] ??
          'mahasiswa',
      username: json['username'] ?? json['user_name'],
      phone: json['phone'] ?? json['telepon'] ?? json['phone_number'],
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
    );
  }
}

class StudentEnrollment {
  StudentEnrollment({
    required this.id,
    required this.name,
    required this.email,
    required this.program,
    this.avatarUrl,
    this.status = '',
    this.company = '',
    this.applicationId = '',
  });

  final String id;
  final String name;
  final String email;
  final String program;
  final String? avatarUrl;
  final String status;
  final String company;
  final String applicationId;

  factory StudentEnrollment.fromJson(Map<String, dynamic> json) {
    return StudentEnrollment(
      id: (json['id_mahasiswa'] ?? json['nim'] ?? json['id'] ?? '').toString(),
      name:
          (json['nama_mahasiswa'] ?? json['name'] ?? json['nama'] ?? '')
              .toString(),
      email: (json['email'] ?? json['email_or_nim'] ?? '').toString(),
      program:
          (json['judul_posisi'] ?? json['program'] ?? json['position'] ?? '')
              .toString(),
      avatarUrl: (json['avatar_url'] ?? json['avatar'])?.toString(),
      status: (json['status'] ?? '').toString(),
      company: (json['nama_perusahaan'] ?? json['company'] ?? '').toString(),
      applicationId:
          (json['id_pendaftaran'] ?? json['application_id'] ?? '').toString(),
    );
  }
}

enum LowonganApprovalStatus { pending, approved, rejected }

class PendingLowongan {
  PendingLowongan({
    required this.id,
    required this.companyName,
    required this.companyCategory,
    required this.requestDescription,
    this.position = '',
    this.location = '',
    this.requirements = '',
    this.benefits = '',
    this.workType = '',
    this.contractType = '',
    this.quota = 0,
    this.deadline,
    this.status = LowonganApprovalStatus.pending,
  });

  factory PendingLowongan.fromJson(Map<String, dynamic> json) {
    final statusString =
        (json['status_approval'] ??
                json['status'] ??
                json['approval_status'] ??
                '')
            .toString()
            .toLowerCase();
    late LowonganApprovalStatus status;

    if (statusString.contains('approve')) {
      status = LowonganApprovalStatus.approved;
    } else if (statusString.contains('reject')) {
      status = LowonganApprovalStatus.rejected;
    } else {
      status = LowonganApprovalStatus.pending;
    }

    return PendingLowongan(
      id:
          json['id_lowongan']?.toString() ??
          json['id']?.toString() ??
          json['lowongan_id']?.toString() ??
          '',
      companyName:
          json['company_name'] ??
          json['companyName'] ??
          json['company'] ??
          json['nama_perusahaan'] ??
          'Unknown Company',
      companyCategory:
          json['company_category'] ??
          json['companyCategory'] ??
          json['category'] ??
          json['kategori'] ??
          'Unknown Category',
      requestDescription:
          json['request_description'] ??
          json['requestDescription'] ??
          json['description'] ??
          json['deskripsi'] ??
          '',
      position:
          (json['judul_posisi'] ?? json['position'] ?? json['title'] ?? '')
              .toString(),
      location: (json['lokasi'] ?? json['location'] ?? '').toString(),
      requirements:
          (json['persyaratan'] ?? json['requirements'] ?? '').toString(),
      benefits: (json['benefit'] ?? json['benefits'] ?? '').toString(),
      workType: (json['tipe_kerja'] ?? json['work_type'] ?? '').toString(),
      contractType:
          (json['tipe_kontrak'] ?? json['contract_type'] ?? '').toString(),
      quota:
          int.tryParse((json['kuota'] ?? json['quota'] ?? 0).toString()) ?? 0,
      deadline: DateTime.tryParse(
        (json['batas_waktu'] ?? json['deadline'] ?? '').toString(),
      ),
      status: status,
    );
  }

  final String id;
  final String companyName;
  final String companyCategory;
  final String requestDescription;
  final String position;
  final String location;
  final String requirements;
  final String benefits;
  final String workType;
  final String contractType;
  final int quota;
  final DateTime? deadline;
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
