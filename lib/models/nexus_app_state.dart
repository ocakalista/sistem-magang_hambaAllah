import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'application_model.dart';
import 'admin_model.dart';
import 'dosen_model.dart';
import 'notification_model.dart';
import '../services/api_service.dart';

enum UserRole { student, admin, dosen, mitra }

class NexusAppState extends ChangeNotifier {
  NexusAppState() {
    _initAdminData();
    _initDosenData();
    _restoreSession();
  }

  static const _tokenKey = 'auth_token';
  static const _roleKey = 'user_role';

  Application? _currentApplication;
  UserRole currentUserRole = UserRole.student;
  String? authToken;
  Map<String, dynamic>? currentUser;
  bool isSyncing = false;
  String? syncError;
  final List<Application> applications = <Application>[];
  final Set<String> _savedInternshipIds = <String>{};
  final List<AppNotification> _notifications = <AppNotification>[];

  late PlatformStats adminStats;
  final List<StudentEnrollment> studentEnrollments = <StudentEnrollment>[];
  final List<PendingLowongan> pendingLowongan = <PendingLowongan>[];
  final List<InternshipDistribution> internshipDistribution =
      <InternshipDistribution>[];

  // Dosen role related state
  late DosenStats dosenStats;
  final List<MahasiswaBimbingan> mahasiswaBimbingan = <MahasiswaBimbingan>[];
  final List<WeeklyReportDosen> recentDosenReports = <WeeklyReportDosen>[];

  Application? get currentApplication => _currentApplication;

  String get currentDisplayName {
    final value = _currentUserValue(const [
      'name',
      'nama_lengkap',
      'nama',
    ]);
    return value ?? _roleFallback;
  }

  String get currentGreetingName {
    final displayName = currentDisplayName.trim();
    if (currentUserRole == UserRole.mitra) return displayName;
    final withoutTitle = displayName.replaceFirst(
      RegExp(r'^(dr\.?|prof\.?|ir\.?)\s+', caseSensitive: false),
      '',
    );
    return withoutTitle.split(RegExp(r'\s+')).first;
  }

  String? currentUserValue(List<String> keys) => _currentUserValue(keys);

  String? _currentUserValue(List<String> keys) {
    final user = currentUser;
    if (user == null) return null;
    final profiles = <Map<String, dynamic>>[
      user,
      for (final nestedKey in const [
        'data',
        'user',
        'mahasiswa',
        'dosen',
        'mitra',
        'profile',
      ])
        if (user[nestedKey] is Map)
          (user[nestedKey] as Map).cast<String, dynamic>(),
    ];
    for (final profile in profiles.reversed) {
      for (final key in keys) {
        final value = profile[key]?.toString().trim();
        if (value != null && value.isNotEmpty) return value;
      }
    }
    return null;
  }

  String get _roleFallback {
    switch (currentUserRole) {
      case UserRole.student:
        return 'Mahasiswa';
      case UserRole.dosen:
        return 'Dosen';
      case UserRole.mitra:
        return 'Mitra';
      case UserRole.admin:
        return 'Admin';
    }
  }

  Application? get activeInternship {
    for (final application in applications) {
      if (application.status == ApplicationStatus.accepted) {
        return application;
      }
    }
    return _currentApplication?.status == ApplicationStatus.accepted
        ? _currentApplication
        : null;
  }

  List<AppNotification> get notifications {
    final items = List<AppNotification>.from(_notifications);
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  int get unreadNotificationCount =>
      _notifications.where((notification) => !notification.isRead).length;

  bool isInternshipSaved(String internshipId) =>
      _savedInternshipIds.contains(internshipId);

  bool get hasApplication => _currentApplication != null;

  bool get hasAcceptedApplication =>
      activeInternship != null;

  Future<void> updateStudentProfile({
    required String name,
    required int semester,
    required String phone,
  }) async {
    final token = authToken;
    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan.');
    }
    await ApiService.updateStudentProfile(
      token: token,
      name: name,
      semester: semester,
      phone: phone,
    );
    currentUser = await ApiService.fetchCurrentUser(token);
    notifyListeners();
  }

  void toggleSavedInternship(String internshipId) {
    if (_savedInternshipIds.contains(internshipId)) {
      _savedInternshipIds.remove(internshipId);
    } else {
      _savedInternshipIds.add(internshipId);
    }
    notifyListeners();
  }

  void submitApplication(Application application) {
    applications.insert(0, application);
    _currentApplication = activeInternship ?? application;
    notifyListeners();
  }

  void updateAcceptedProgress({
    int? currentWeek,
    int? totalWeeks,
    double? progressPercent,
    List<WeeklyReport>? weeklyReports,
  }) {
    final application = _currentApplication;
    if (application == null) {
      return;
    }

    application.currentWeek = currentWeek ?? application.currentWeek;
    application.totalWeeks = totalWeeks ?? application.totalWeeks;
    application.progressPercent =
        progressPercent ?? application.progressPercent;
    if (weeklyReports != null) {
      application.weeklyReports = weeklyReports;
      _syncCompletedReportNotifications(application);
    }
    notifyListeners();
  }

  void updateWeeklyReportStatus({
    required int weekNumber,
    required String status,
    String? feedbackFromLecturer,
    String? lecturerName,
  }) {
    final application = _currentApplication;
    if (application == null) {
      return;
    }

    final reportIndex = application.weeklyReports.indexWhere(
      (report) => report.weekNumber == weekNumber,
    );
    if (reportIndex == -1) {
      return;
    }

    final report = application.weeklyReports[reportIndex];
    final previousStatus = report.status;
    application.weeklyReports[reportIndex] = WeeklyReport(
      weekNumber: report.weekNumber,
      title: report.title,
      description: report.description,
      status: status,
      dueDate: report.dueDate,
      reportFileUrl: report.reportFileUrl,
      feedbackFromLecturer: feedbackFromLecturer ?? report.feedbackFromLecturer,
      lecturerName: lecturerName ?? report.lecturerName,
    );

    final updatedReport = application.weeklyReports[reportIndex];

    if (previousStatus != 'completed' &&
        status == 'completed' &&
        (updatedReport.feedbackFromLecturer ?? '').isNotEmpty) {
      _addNotification(_buildLogbookNotification(application, updatedReport));
    }

    notifyListeners();
  }

  Future<void> loadNotifications() async {
    final token = authToken;
    if (token == null || token.isEmpty) return;
    final fetched = await ApiService.fetchNotifications(token);
    _notifications
      ..clear()
      ..addAll(fetched.map(AppNotification.fromJson));
    notifyListeners();
  }

  Future<void> markNotificationAsRead(String id) async {
    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );
    if (index == -1) {
      return;
    }

    _notifications[index] = _notifications[index].copyWith(
      isRead: true,
      group: 'Earlier Today',
    );
    notifyListeners();
    final token = authToken;
    if (token == null || token.isEmpty) return;
    try {
      await ApiService.markNotificationAsRead(token, id);
    } catch (_) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: false,
        group: 'New Notifications',
      );
      notifyListeners();
      rethrow;
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final unreadIds =
        _notifications
            .where((notification) => !notification.isRead)
            .map((notification) => notification.id)
            .toSet();
    for (final notification in _notifications) {
      final index = _notifications.indexOf(notification);
      _notifications[index] = notification.copyWith(
        isRead: true,
        group: 'Earlier Today',
      );
    }
    notifyListeners();
    final token = authToken;
    if (token == null || token.isEmpty) return;
    try {
      await ApiService.markAllNotificationsAsRead(token);
    } catch (_) {
      for (final notification in _notifications) {
        if (unreadIds.contains(notification.id)) {
          final index = _notifications.indexOf(notification);
          _notifications[index] = notification.copyWith(
            isRead: false,
            group: 'New Notifications',
          );
        }
      }
      notifyListeners();
      rethrow;
    }
  }

  Future<void> setUserRole(UserRole role) async {
    currentUserRole = role;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_roleKey, role.name);
  }

  Future<void> setAuthToken(String? token) async {
    authToken = token;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await preferences.remove(_tokenKey);
    } else {
      await preferences.setString(_tokenKey, token);
    }
  }

  Future<void> _restoreSession() async {
    final preferences = await SharedPreferences.getInstance();
    final savedToken = preferences.getString(_tokenKey);
    final savedRole = preferences.getString(_roleKey);
    authToken = savedToken;
    currentUserRole = UserRole.values.firstWhere(
      (role) => role.name == savedRole,
      orElse: () => UserRole.student,
    );
    notifyListeners();
    if (savedToken != null && savedToken.isNotEmpty) {
      await syncForCurrentRole();
    }
  }

  Future<void> logout() async {
    final token = authToken;
    if (token != null && token.isNotEmpty) {
      try {
        await ApiService.logout(token);
      } catch (_) {
        // Sesi lokal tetap harus dihapus ketika perangkat sedang offline.
      }
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenKey);
    await preferences.remove(_roleKey);
    authToken = null;
    currentUser = null;
    currentUserRole = UserRole.student;
    applications.clear();
    _currentApplication = null;
    notifyListeners();
  }

  Future<void> syncForCurrentRole() async {
    final token = authToken;
    if (token == null || token.isEmpty) return;
    isSyncing = true;
    syncError = null;
    notifyListeners();
    try {
      currentUser = await ApiService.fetchCurrentUser(token);
      await loadNotifications();
      switch (currentUserRole) {
        case UserRole.student:
          await loadStudentApplications();
          break;
        case UserRole.admin:
          await Future.wait([
            loadAdminLowongan(),
            loadAdminDashboard(),
            loadAdminEnrollments(),
          ]);
          break;
        case UserRole.dosen:
          await loadMahasiswaBimbingan();
          break;
        case UserRole.mitra:
          break;
      }
    } catch (e) {
      syncError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> loadStudentApplications() async {
    final token = authToken;
    if (token == null) return;
    final history = await ApiService.fetchApplicationHistory(token);
    final logbooks = await ApiService.fetchLogbooks(token);
    final parsed = <Application>[];
    for (final item in history) {
      final lowonganId = item['id_lowongan']?.toString() ?? '';
      if (lowonganId.isEmpty) continue;
      final detail = await ApiService.fetchLowonganDetail(lowonganId);
      final appId =
          item['id_pendaftaran']?.toString() ?? item['id']?.toString() ?? '';
      final supervisorRaw =
          item['dosen_pembimbing'] ?? item['dosen'] ?? item['lecturer'];
      final supervisor =
          supervisorRaw is Map
              ? supervisorRaw.cast<String, dynamic>()
              : const <String, dynamic>{};
      final supervisorName =
          (item['nama_dosen_pembimbing'] ??
                  item['nama_dosen'] ??
                  item['lecturer_name'] ??
                  (supervisorRaw is String ? supervisorRaw : null) ??
                  supervisor['name'] ??
                  supervisor['nama_lengkap'] ??
                  supervisor['nama_dosen'])
              ?.toString();
      final reports =
          logbooks
              .where((row) => row['id_pendaftaran']?.toString() == appId)
              .map(
                (row) => WeeklyReport.fromJson({
                  ...row,
                  if ((row['nama_dosen']?.toString().trim().isEmpty ?? true) &&
                      supervisorName != null &&
                      supervisorName.trim().isNotEmpty)
                    'nama_dosen': supervisorName,
                }),
              )
              .toList();
      parsed.add(
        Application.fromJson(
          {...item, 'total_weeks': item['total_weeks'] ?? 12},
          internship: Internship.fromJson(detail),
          weeklyReports: reports,
        ),
      );
    }
    parsed.sort((a, b) => b.appliedDate.compareTo(a.appliedDate));
    applications
      ..clear()
      ..addAll(parsed);
    _currentApplication = null;
    for (final application in parsed) {
      if (application.status == ApplicationStatus.accepted) {
        _currentApplication = application;
        break;
      }
    }
    _currentApplication ??= parsed.isEmpty ? null : parsed.first;
    notifyListeners();
  }

  Future<void> loadAdminDashboard() async {
    final token = authToken;
    if (token == null) return;
    final data = await ApiService.fetchAdminDashboard(token);
    adminStats = PlatformStats(
      totalUsers: int.tryParse(data['totalUsers']?.toString() ?? '') ?? 0,
      totalUsersGrowthPercent:
          double.tryParse(data['totalUsersGrowthPercent']?.toString() ?? '') ??
          0,
      activeInternships:
          int.tryParse(data['activeInternships']?.toString() ?? '') ?? 0,
      activeInternshipsGrowthPercent:
          double.tryParse(
            data['activeInternshipsGrowthPercent']?.toString() ?? '',
          ) ??
          0,
    );
    notifyListeners();
  }

  Future<void> loadAdminEnrollments() async {
    final token = authToken;
    if (token == null || token.isEmpty) return;
    final fetched = await ApiService.fetchAdminEnrollments(token);
    studentEnrollments
      ..clear()
      ..addAll(fetched);
    notifyListeners();
  }

  void _syncCompletedReportNotifications(Application application) {
    for (final report in application.weeklyReports) {
      if (report.status == 'completed' &&
          (report.feedbackFromLecturer ?? '').isNotEmpty) {
        _addNotification(_buildLogbookNotification(application, report));
      }
    }
  }

  // Nilai awal kosong sampai sinkronisasi admin selesai.
  void _initAdminData() {
    adminStats = PlatformStats(
      totalUsers: 0,
      totalUsersGrowthPercent: 0.0,
      activeInternships: 0,
      activeInternshipsGrowthPercent: 0.0,
    );
    studentEnrollments.clear();
    pendingLowongan.clear();
    internshipDistribution.clear();
  }

  int get pendingLowonganCount =>
      pendingLowongan
          .where((item) => item.status == LowonganApprovalStatus.pending)
          .length;

  void addPendingLowongan(PendingLowongan request) {
    pendingLowongan.insert(0, request);
    notifyListeners();
  }

  Future<void> loadAdminLowongan() async {
    final token = authToken;
    if (token == null) {
      return;
    }

    try {
      final results = await Future.wait([
        ApiService.fetchAdminLowongan(token),
        ApiService.fetchPublicLowonganForAdmin(),
      ]);
      final byId = <String, PendingLowongan>{};
      for (final item in [...results[0], ...results[1]]) {
        byId[item.id] = item;
      }
      pendingLowongan
        ..clear()
        ..addAll(byId.values);
      notifyListeners();
    } catch (_) {
      // Biarkan kosong jika fetch gagal
    }
  }

  Future<void> approveLowongan(String id) async {
    final token = authToken;
    final index = pendingLowongan.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final previousStatus = pendingLowongan[index].status;
    pendingLowongan[index].status = LowonganApprovalStatus.pending;
    notifyListeners();

    try {
      await ApiService.approveLowongan(token, id);
      pendingLowongan[index].status = LowonganApprovalStatus.approved;
      notifyListeners();
    } catch (e) {
      pendingLowongan[index].status = previousStatus;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> rejectLowongan(String id, String reason) async {
    final token = authToken;
    final index = pendingLowongan.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final previousStatus = pendingLowongan[index].status;
    pendingLowongan[index].status = LowonganApprovalStatus.pending;
    notifyListeners();

    try {
      await ApiService.rejectLowongan(token, id, reason);
      pendingLowongan[index].status = LowonganApprovalStatus.rejected;
      notifyListeners();
    } catch (e) {
      pendingLowongan[index].status = previousStatus;
      notifyListeners();
      rethrow;
    }
  }

  void _addNotification(AppNotification notification) {
    final exists = _notifications.any((item) => item.id == notification.id);
    if (exists) {
      return;
    }

    _notifications.add(notification);
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  AppNotification _buildLogbookNotification(
    Application application,
    WeeklyReport report,
  ) {
    final lecturerName = report.lecturerName ?? 'your lecturer';
    return AppNotification(
      id: 'logbook-${application.id}-week-${report.weekNumber}',
      title: 'Logbook Approved',
      description:
          'Your supervisor, $lecturerName, approved your weekly logbook for Week ${report.weekNumber}.',
      timestamp: DateTime.now(),
      category: NotificationCategory.approval,
      priority: NotificationPriority.normal,
      icon: Icons.verified_rounded,
      group: 'New Notifications',
    );
  }

  // Nilai awal kosong sampai sinkronisasi dosen selesai.
  void _initDosenData() {
    dosenStats = DosenStats(
      totalApprovalNeeded: 0,
      approvalChangeFromYesterday: 0,
      completedInternships: 0,
      ongoingInternships: 0,
    );
    recentDosenReports.clear();
    mahasiswaBimbingan.clear();
  }

  Future<void> loadMahasiswaBimbingan() async {
    final token = authToken;
    if (token == null) return;

    try {
      final fetched = await ApiService.fetchMahasiswaBimbingan(token);
      final List<MahasiswaBimbingan> parsed = [];

      for (final item in fetched) {
        try {
          final m = item is Map ? item : <String, dynamic>{};
          final id =
              (m['id'] ?? m['id_mahasiswa'] ?? m['nim'] ?? '').toString();
          final name =
              (m['name'] ?? m['nama'] ?? m['full_name'] ?? 'Mahasiswa')
                  .toString();
          final position =
              (m['position'] ??
                      m['posisi'] ??
                      m['internship_position'] ??
                      m['role'] ??
                      'Magang')
                  .toString();
          final avatar =
              (m['avatar'] ?? m['avatar_url'] ?? m['photo'])?.toString();
          final company = (m['company'] ?? m['nama_perusahaan'])?.toString();
          final email = m['email']?.toString();
          final phone = (m['phone'] ?? m['no_telp'])?.toString();
          final studyProgram =
              (m['study_program'] ?? m['program_studi'] ?? m['prodi'])
                  ?.toString();
          final currentWeek =
              int.tryParse(
                (m['current_week'] ?? m['week'] ?? m['currentWeek'] ?? 0)
                    .toString(),
              ) ??
              0;
          final totalWeeks =
              int.tryParse(
                (m['total_weeks'] ?? m['totalWeeks'] ?? 6).toString(),
              ) ??
              6;
          final progress =
              double.tryParse(
                (m['progress'] ??
                        m['progress_percent'] ??
                        m['progressPercent'] ??
                        0)
                    .toString(),
              ) ??
              0.0;

          final reportsRaw =
              m['weekly_reports'] ?? m['weeklyReports'] ?? m['reports'] ?? [];
          final List<WeeklyReportDosen> reports = [];
          if (reportsRaw is List) {
            for (final r in reportsRaw) {
              if (r is Map) {
                final idr = (r['id'] ?? r['report_id'] ?? '').toString();
                final weekNumber =
                    int.tryParse(
                      (r['minggu_ke'] ??
                              r['week_number'] ??
                              r['weekNumber'] ??
                              r['week'] ??
                              0)
                          .toString(),
                    ) ??
                    0;
                final title =
                    (r['title'] ?? r['judul'] ?? 'Logbook Minggu $weekNumber')
                        .toString();
                final submittedBy =
                    (r['submitted_by'] ?? r['submittedBy'] ?? name).toString();
                DateTime submittedAt;
                try {
                  submittedAt = DateTime.parse(
                    (r['tanggal'] ??
                            r['submitted_at'] ??
                            r['submittedAt'] ??
                            DateTime.now().toIso8601String())
                        .toString(),
                  );
                } catch (_) {
                  submittedAt = DateTime.now();
                }
                final content =
                    (r['deskripsi'] ?? r['content'] ?? r['description'] ?? '')
                        .toString();
                final isApproved =
                    (r['status_validasi']?.toString().toLowerCase() ==
                        'disetujui') ||
                    (r['is_approved'] ?? r['approved'] ?? false) == true;
                final feedback =
                    r['status_validasi']?.toString().toLowerCase() == 'revisi'
                        ? 'Perlu revisi'
                        : (r['lecturer_feedback'] ?? r['feedback'])?.toString();

                reports.add(
                  WeeklyReportDosen(
                    id: idr,
                    weekNumber: weekNumber,
                    title: title,
                    submittedBy: submittedBy,
                    submittedAt: submittedAt,
                    reportContent: content,
                    isApproved: isApproved,
                    lecturerFeedback: feedback,
                  ),
                );
              }
            }
          }

          parsed.add(
            MahasiswaBimbingan(
              id: id,
              name: name,
              internshipPosition: position,
              company: company,
              email: email,
              phone: phone,
              studyProgram: studyProgram,
              avatarUrl: avatar,
              currentWeek: currentWeek,
              totalWeeks: totalWeeks,
              progressPercent: (progress > 1 ? progress / 100 : progress).clamp(
                0.0,
                1.0,
              ),
              weeklyReports: reports,
            ),
          );
        } catch (_) {
          // skip malformed item
        }
      }

      mahasiswaBimbingan
        ..clear()
        ..addAll(parsed);

      // Update dosen stats based on fetched data
      final int totalApprovalNeeded = parsed
          .map((s) => s.getUnapprovedReports().length)
          .fold<int>(0, (p, e) => p + e);

      final int completedCount =
          parsed.where((s) {
            return s.progressPercent >= 1.0 || s.currentWeek >= s.totalWeeks;
          }).length;

      final int ongoingCount =
          parsed.where((s) {
            return s.progressPercent > 0.0 && s.progressPercent < 1.0;
          }).length;

      dosenStats = dosenStats.copyWith(
        totalApprovalNeeded: totalApprovalNeeded,
        completedInternships: completedCount,
        ongoingInternships: ongoingCount,
      );

      // Build recent reports list (flatten and sort)
      final allReports = <WeeklyReportDosen>[];
      for (final s in parsed) {
        allReports.addAll(s.weeklyReports);
      }
      allReports.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      recentDosenReports
        ..clear()
        ..addAll(allReports.take(6));

      notifyListeners();
    } catch (e) {
      // propagate error so callers can show retry UI
      rethrow;
    }
  }

  Future<void> approveDosenReport({
    required String studentId,
    required String reportId,
    required String feedback,
  }) async {
    final token = authToken;
    if (token == null) throw Exception('Sesi login tidak tersedia.');
    await ApiService.updateLogbookStatus(
      token,
      reportId,
      'disetujui',
      feedback,
    );
    for (var student in mahasiswaBimbingan) {
      if (student.id == studentId) {
        final reportIndex = student.weeklyReports.indexWhere(
          (r) => r.id == reportId,
        );
        if (reportIndex != -1) {
          final report = student.weeklyReports[reportIndex];
          student.weeklyReports[reportIndex] = report.copyWith(
            isApproved: true,
            lecturerFeedback: feedback,
          );

          dosenStats = dosenStats.copyWith(
            totalApprovalNeeded:
                dosenStats.totalApprovalNeeded > 0
                    ? dosenStats.totalApprovalNeeded - 1
                    : 0,
          );

          notifyListeners();
          return;
        }
      }
    }
  }

  Future<void> rejectDosenReport({
    required String studentId,
    required String reportId,
    required String reason,
  }) async {
    final token = authToken;
    if (token == null) throw Exception('Sesi login tidak tersedia.');
    await ApiService.updateLogbookStatus(token, reportId, 'revisi', reason);
    for (var student in mahasiswaBimbingan) {
      if (student.id == studentId) {
        final reportIndex = student.weeklyReports.indexWhere(
          (r) => r.id == reportId,
        );
        if (reportIndex != -1) {
          final report = student.weeklyReports[reportIndex];
          student.weeklyReports[reportIndex] = report.copyWith(
            lecturerFeedback: 'Please revise: $reason',
          );

          notifyListeners();
          return;
        }
      }
    }
  }
}

class NexusScope extends InheritedNotifier<NexusAppState> {
  const NexusScope({
    super.key,
    required NexusAppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static NexusAppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NexusScope>();
    assert(scope != null, 'NexusScope not found in widget tree');
    return scope!.notifier!;
  }
}
