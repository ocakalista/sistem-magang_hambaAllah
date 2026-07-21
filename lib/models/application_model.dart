enum ApplicationStatus { submitted, underReview, interview, accepted, rejected }

class Internship {
  final String id;
  final String position;
  final String company;
  final String location;
  final List<String> tags;
  final String period;
  final String quota;
  final String description;
  final List<String> requirements;
  final List<String> benefits;

  const Internship({
    required this.id,
    required this.position,
    required this.company,
    required this.location,
    required this.tags,
    required this.period,
    required this.quota,
    required this.description,
    required this.requirements,
    required this.benefits,
  });

  // FUNGSI BARU: Untuk mengubah data JSON dari API Laravel menjadi objek Internship
  factory Internship.fromJson(Map<String, dynamic> json) {
    List<String> strings(dynamic value) {
      if (value is List) return value.map((item) => item.toString()).toList();
      if (value is String) {
        return value
            .split(RegExp(r'[,\n]'))
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }
      return <String>[];
    }

    final start = json['tanggal_mulai']?.toString();
    final end = (json['batas_waktu'] ?? json['tanggal_selesai'])?.toString();
    return Internship(
      id: json['id_lowongan']?.toString() ?? json['id']?.toString() ?? '',
      position:
          json['judul_posisi'] ??
          json['posisi'] ??
          json['position'] ??
          'Posisi Magang',
      company:
          json['nama_perusahaan']?.toString() ??
          json['company']?.toString() ??
          '',
      location:
          json['lokasi']?.toString() ?? json['location']?.toString() ?? '',
      tags: strings(json['tags'] ?? json['kategori']),
      period:
          json['periode']?.toString() ??
          json['period']?.toString() ??
          [
            start,
            end,
          ].whereType<String>().where((value) => value.isNotEmpty).join(' - '),
      quota: json['kuota']?.toString() ?? json['quota']?.toString() ?? '0',
      description:
          json['deskripsi']?.toString() ??
          json['description']?.toString() ??
          '',
      requirements: strings(json['requirements'] ?? json['persyaratan']),
      benefits: strings(json['benefits'] ?? json['keuntungan']),
    );
  }
}

class Application {
  final String id;
  final Internship internship;
  ApplicationStatus status;
  final DateTime appliedDate;
  int? currentWeek;
  int? totalWeeks;
  double? progressPercent;
  List<WeeklyReport> weeklyReports;

  Application({
    required this.id,
    required this.internship,
    required this.status,
    required this.appliedDate,
    this.currentWeek,
    this.totalWeeks,
    this.progressPercent,
    List<WeeklyReport>? weeklyReports,
  }) : weeklyReports = weeklyReports ?? <WeeklyReport>[];

  Application copyWith({
    String? id,
    Internship? internship,
    ApplicationStatus? status,
    DateTime? appliedDate,
    int? currentWeek,
    int? totalWeeks,
    double? progressPercent,
    List<WeeklyReport>? weeklyReports,
  }) {
    return Application(
      id: id ?? this.id,
      internship: internship ?? this.internship,
      status: status ?? this.status,
      appliedDate: appliedDate ?? this.appliedDate,
      currentWeek: currentWeek ?? this.currentWeek,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      progressPercent: progressPercent ?? this.progressPercent,
      weeklyReports: weeklyReports ?? this.weeklyReports,
    );
  }

  static ApplicationStatus statusFromApi(dynamic value) {
    switch (value?.toString().toLowerCase()) {
      case 'diterima':
      case 'accepted':
      case 'selesai':
        return ApplicationStatus.accepted;
      case 'ditolak':
      case 'rejected':
        return ApplicationStatus.rejected;
      case 'review':
      case 'under_review':
        return ApplicationStatus.underReview;
      case 'interview':
        return ApplicationStatus.interview;
      default:
        return ApplicationStatus.submitted;
    }
  }

  factory Application.fromJson(
    Map<String, dynamic> json, {
    required Internship internship,
    List<WeeklyReport> weeklyReports = const [],
  }) {
    final appliedAt = json['created_at'] ?? json['tanggal_daftar'];
    return Application(
      id: json['id_pendaftaran']?.toString() ?? json['id']?.toString() ?? '',
      internship: internship,
      status: statusFromApi(json['status']),
      appliedDate:
          DateTime.tryParse(appliedAt?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      currentWeek:
          weeklyReports.isEmpty
              ? 0
              : weeklyReports
                  .map((item) => item.weekNumber)
                  .reduce((a, b) => a > b ? a : b),
      weeklyReports: weeklyReports,
    );
  }
}

class WeeklyReport {
  final String id;
  final int weekNumber;
  final String title;
  final String description;
  final String status;
  final DateTime? dueDate;
  String? feedbackFromLecturer;
  String? lecturerName;

  WeeklyReport({
    this.id = '',
    required this.weekNumber,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
    this.feedbackFromLecturer,
    this.lecturerName,
  });

  factory WeeklyReport.fromJson(Map<String, dynamic> json) {
    final validation = json['status_validasi']?.toString().toLowerCase();
    return WeeklyReport(
      id: json['id_logbook']?.toString() ?? json['id']?.toString() ?? '',
      weekNumber: int.tryParse(json['minggu_ke']?.toString() ?? '') ?? 0,
      title: 'Logbook Minggu ${json['minggu_ke'] ?? '-'}',
      description:
          json['deskripsi_kegiatan']?.toString() ??
          json['deskripsi']?.toString() ??
          '',
      status:
          validation == 'disetujui'
              ? 'completed'
              : validation == 'revisi'
              ? 'revision'
              : 'submitted',
      dueDate: DateTime.tryParse(json['tanggal']?.toString() ?? ''),
    );
  }
}

extension ApplicationStatusLabel on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.underReview:
        return 'Under Review';
      case ApplicationStatus.interview:
        return 'Interview';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }
}
