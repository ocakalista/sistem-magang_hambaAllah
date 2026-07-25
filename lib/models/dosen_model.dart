class DosenStats {
  int totalApprovalNeeded;
  final int approvalChangeFromYesterday;
  final int completedInternships;
  final int ongoingInternships;

  DosenStats({
    required this.totalApprovalNeeded,
    required this.approvalChangeFromYesterday,
    required this.completedInternships,
    required this.ongoingInternships,
  });

  DosenStats copyWith({
    int? totalApprovalNeeded,
    int? approvalChangeFromYesterday,
    int? completedInternships,
    int? ongoingInternships,
  }) {
    return DosenStats(
      totalApprovalNeeded: totalApprovalNeeded ?? this.totalApprovalNeeded,
      approvalChangeFromYesterday:
          approvalChangeFromYesterday ?? this.approvalChangeFromYesterday,
      completedInternships: completedInternships ?? this.completedInternships,
      ongoingInternships: ongoingInternships ?? this.ongoingInternships,
    );
  }
}

class WeeklyReportDosen {
  final String id;
  final int weekNumber;
  final String title;
  final String submittedBy;
  final DateTime submittedAt;
  final String reportContent;
  bool isApproved;
  String? lecturerFeedback;

  WeeklyReportDosen({
    required this.id,
    required this.weekNumber,
    required this.title,
    required this.submittedBy,
    required this.submittedAt,
    required this.reportContent,
    this.isApproved = false,
    this.lecturerFeedback,
  });

  WeeklyReportDosen copyWith({
    String? id,
    int? weekNumber,
    String? title,
    String? submittedBy,
    DateTime? submittedAt,
    String? reportContent,
    bool? isApproved,
    String? lecturerFeedback,
  }) {
    return WeeklyReportDosen(
      id: id ?? this.id,
      weekNumber: weekNumber ?? this.weekNumber,
      title: title ?? this.title,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedAt: submittedAt ?? this.submittedAt,
      reportContent: reportContent ?? this.reportContent,
      isApproved: isApproved ?? this.isApproved,
      lecturerFeedback: lecturerFeedback ?? this.lecturerFeedback,
    );
  }
}

class MahasiswaBimbingan {
  final String id;
  final String name;
  final String internshipPosition;
  final String? company;
  final String? email;
  final String? phone;
  final String? studyProgram;
  final String? avatarUrl;
  final int currentWeek;
  final int totalWeeks;
  final double progressPercent;
  final List<WeeklyReportDosen> weeklyReports;

  MahasiswaBimbingan({
    required this.id,
    required this.name,
    required this.internshipPosition,
    this.company,
    this.email,
    this.phone,
    this.studyProgram,
    this.avatarUrl,
    required this.currentWeek,
    required this.totalWeeks,
    required this.progressPercent,
    required this.weeklyReports,
  });

  MahasiswaBimbingan copyWith({
    String? id,
    String? name,
    String? internshipPosition,
    String? company,
    String? email,
    String? phone,
    String? studyProgram,
    String? avatarUrl,
    int? currentWeek,
    int? totalWeeks,
    double? progressPercent,
    List<WeeklyReportDosen>? weeklyReports,
  }) {
    return MahasiswaBimbingan(
      id: id ?? this.id,
      name: name ?? this.name,
      internshipPosition: internshipPosition ?? this.internshipPosition,
      company: company ?? this.company,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      studyProgram: studyProgram ?? this.studyProgram,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      currentWeek: currentWeek ?? this.currentWeek,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      progressPercent: progressPercent ?? this.progressPercent,
      weeklyReports: weeklyReports ?? this.weeklyReports,
    );
  }

  /// Get unapproved reports for this student
  List<WeeklyReportDosen> getUnapprovedReports() {
    return weeklyReports.where((report) => !report.isApproved).toList();
  }

  /// Get the latest unapproved report
  WeeklyReportDosen? getLatestUnapprovedReport() {
    final unapproved = getUnapprovedReports();
    if (unapproved.isEmpty) return null;
    unapproved.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return unapproved.first;
  }
}
