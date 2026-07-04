import 'package:flutter/material.dart';

import 'application_model.dart';
import 'admin_model.dart';
import 'dosen_model.dart';
import 'notification_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

enum UserRole { student, admin, dosen, mitra }

class NexusAppState extends ChangeNotifier {
  NexusAppState() {
    _notifications.addAll(_buildStaticDemoNotifications());
    _initAdminData();
    _initDosenData();
  }

  Application? _currentApplication;
  UserRole currentUserRole = UserRole.student;
  String? authToken;
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
      _currentApplication?.status == ApplicationStatus.accepted;

  void toggleSavedInternship(String internshipId) {
    if (_savedInternshipIds.contains(internshipId)) {
      _savedInternshipIds.remove(internshipId);
    } else {
      _savedInternshipIds.add(internshipId);
    }
    notifyListeners();
  }

  void submitApplication(Application application) {
    _currentApplication = application;
    notifyListeners();
  }

  void updateApplicationStatus(ApplicationStatus status) {
    final application = _currentApplication;
    if (application == null) {
      return;
    }

    final previousStatus = application.status;
    application.status = status;

    if (status == ApplicationStatus.accepted) {
      application.currentWeek ??= 3;
      application.totalWeeks ??= 6;
      application.progressPercent ??= 0.5;
      if (application.weeklyReports.isEmpty) {
        application.weeklyReports = buildDemoWeeklyReports();
      }
      if (previousStatus != ApplicationStatus.accepted) {
        _addNotification(_buildInternshipOfferNotification(application));
      }
      _syncCompletedReportNotifications(application);
    }

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

  void markNotificationAsRead(String id) {
    final index = _notifications.indexWhere(
      (notification) => notification.id == id,
    );
    if (index == -1) {
      return;
    }

    _notifications[index].isRead = true;
    notifyListeners();
  }

  void markAllNotificationsAsRead() {
    for (final notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  Application createDemoApplication() {
    return Application(
      id: 'app-${DateTime.now().millisecondsSinceEpoch}',
      internship: demoInternship,
      status: ApplicationStatus.submitted,
      appliedDate: DateTime.now(),
    );
  }

  void setUserRole(UserRole role) {
    currentUserRole = role;
    notifyListeners();
  }

  void setAuthToken(String? token) {
    authToken = token;
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

  void _initAdminData() {
    adminStats = PlatformStats(
      totalUsers: 12482,
      totalUsersGrowthPercent: 12.0,
      activeInternships: 842,
      activeInternshipsGrowthPercent: 8.0,
    );

    studentEnrollments.addAll([
      StudentEnrollment(
        id: 's-1',
        name: 'Sarah Jenkins',
        email: 'sarah.jenkins@example.com',
        program: 'Computer Science',
        avatarUrl: 'https://i.pravatar.cc/150?img=47',
      ),
      StudentEnrollment(
        id: 's-2',
        name: 'Marcus Thorne',
        email: 'marcus.thorne@example.com',
        program: 'Digital Media',
        avatarUrl: 'https://i.pravatar.cc/150?img=12',
      ),
      StudentEnrollment(
        id: 's-3',
        name: 'Aria Lovelace',
        email: 'aria.lovelace@example.com',
        program: 'Cybersecurity',
        avatarUrl: null,
      ),
    ]);

    pendingLowongan.addAll([
      PendingLowongan(
        id: 'p-1',
        companyName: 'Stellar Dynamics',
        companyCategory: 'Cloud Infrastructure',
        requestDescription:
            'Requested to post 5 Software Engineering internship positions for Fall 2024.',
      ),
      PendingLowongan(
        id: 'p-2',
        companyName: 'Design Flow',
        companyCategory: 'Creative Agency',
        requestDescription:
            'New internship listing request for UI/UX Design and Illustration roles.',
      ),
    ]);

    internshipDistribution.addAll([
      InternshipDistribution(
        category: 'Engineering',
        percent: 45,
        color: AppColors.primary,
      ),
      InternshipDistribution(
        category: 'Design',
        percent: 30,
        color: AppColors.secondary,
      ),
      InternshipDistribution(
        category: 'Business',
        percent: 25,
        color: AppColors.tertiary,
      ),
    ]);
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
      final fetched = await ApiService.fetchAdminLowongan(token);
      pendingLowongan
        ..clear()
        ..addAll(fetched);
      notifyListeners();
    } catch (_) {
      // Keep existing local demo data when backend fetch fails.
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

  AppNotification _buildInternshipOfferNotification(Application application) {
    return AppNotification(
      id: 'offer-${application.id}',
      title: 'Internship Offer',
      description:
          'Congratulations! ${application.internship.company} has accepted your application for the ${application.internship.position}.',
      timestamp: DateTime.now(),
      category: NotificationCategory.approval,
      priority: NotificationPriority.high,
      icon: Icons.work_rounded,
      group: 'New Notifications',
    );
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

  List<AppNotification> _buildStaticDemoNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'demo-message',
        title: 'New Message',
        description:
            'Your internship mentor sent a quick update about this week\'s design review.',
        timestamp: now.subtract(const Duration(hours: 2, minutes: 10)),
        category: NotificationCategory.update,
        priority: NotificationPriority.normal,
        icon: Icons.chat_bubble_outline_rounded,
        isRead: true,
        group: 'Earlier Today',
      ),
      AppNotification(
        id: 'demo-interview',
        title: 'Interview Scheduled',
        description:
            'A new interview slot has been reserved for your upcoming internship discussion.',
        timestamp: now.subtract(const Duration(hours: 4, minutes: 20)),
        category: NotificationCategory.update,
        priority: NotificationPriority.normal,
        icon: Icons.schedule_rounded,
        isRead: true,
        group: 'Earlier Today',
      ),
    ];
  }

  void _initDosenData() {
    // Initialize DosenStats with demo data
    dosenStats = DosenStats(
      totalApprovalNeeded: 8,
      approvalChangeFromYesterday: 2,
      completedInternships: 14,
      ongoingInternships: 10,
    );

    // Weekly reports for Arkananta Rizky
    final arkanantaReports = [
      WeeklyReportDosen(
        id: 'report-ark-12',
        weekNumber: 12,
        title: 'Final Sprint Completion',
        submittedBy: 'Arkananta Rizky',
        submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
        reportContent:
            'Completed the user authentication module with OAuth 2.0 integration. Wrote comprehensive unit tests achieving 95% code coverage. Collaborated with QA team to resolve 12 critical bugs. Performance metrics improved by 40% after database optimization.',
        isApproved: false,
      ),
      WeeklyReportDosen(
        id: 'report-ark-11',
        weekNumber: 11,
        title: 'Database Optimization',
        submittedBy: 'Arkananta Rizky',
        submittedAt: DateTime.now().subtract(const Duration(hours: 26)),
        reportContent:
            'Analyzed database query performance and identified N+1 problems. Implemented query optimization using indexing and caching strategies. Reduced average response time from 500ms to 150ms.',
        isApproved: true,
        lecturerFeedback: 'Excellent work on database optimization!',
      ),
    ];

    // Weekly reports for Sarah Safitri
    final sarahReports = [
      WeeklyReportDosen(
        id: 'report-sarah-8',
        weekNumber: 8,
        title: 'Design System Implementation',
        submittedBy: 'Sarah Safitri',
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
        reportContent:
            'Created comprehensive design system documentation with 50+ components. Established color palette guidelines and typography standards. Conducted design review sessions with stakeholders and gathered feedback for iteration. Started implementing component library in React.',
        isApproved: false,
      ),
      WeeklyReportDosen(
        id: 'report-sarah-7',
        weekNumber: 7,
        title: 'User Research Analysis',
        submittedBy: 'Sarah Safitri',
        submittedAt: DateTime.now().subtract(const Duration(hours: 30)),
        reportContent:
            'Conducted 15 user interviews for the mobile app redesign project. Analyzed interview transcripts and created affinity map. Identified 8 key user pain points and created wireframes addressing these issues.',
        isApproved: true,
        lecturerFeedback: 'Great insights from user research!',
      ),
    ];

    // Recent reports for dashboard display
    recentDosenReports.addAll([
      WeeklyReportDosen(
        id: 'report-budi-11',
        weekNumber: 11,
        title: 'Development Sprint',
        submittedBy: 'Budi Doremi',
        submittedAt: DateTime.now().subtract(const Duration(hours: 2)),
        reportContent:
            'Completed backend API development for payment processing module. Integrated Stripe API and implemented webhook handlers. Wrote extensive documentation for API endpoints. Started performance testing with load simulations.',
        isApproved: false,
      ),
      WeeklyReportDosen(
        id: 'report-anita-10',
        weekNumber: 10,
        title: 'User Testing Result',
        submittedBy: 'Anita W.',
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
        reportContent:
            'Conducted usability testing with 20 participants on the new feature. Task success rate was 89% with average task completion time of 2.3 minutes. Identified 5 usability issues and created prioritized action items for design improvements. All issues have been logged in the product backlog.',
        isApproved: false,
      ),
    ]);

    // Initialize MahasiswaBimbingan list
    mahasiswaBimbingan.addAll([
      MahasiswaBimbingan(
        id: 'mhs-ark',
        name: 'Arkananta Rizky',
        internshipPosition: 'Software Engineer @ Gojek',
        avatarUrl: null,
        currentWeek: 12,
        totalWeeks: 16,
        progressPercent: 0.85,
        weeklyReports: arkanantaReports,
      ),
      MahasiswaBimbingan(
        id: 'mhs-sarah',
        name: 'Sarah Safitri',
        internshipPosition: 'UI Designer @ Traveloka',
        avatarUrl: null,
        currentWeek: 8,
        totalWeeks: 12,
        progressPercent: 0.60,
        weeklyReports: sarahReports,
      ),
      MahasiswaBimbingan(
        id: 'mhs-budi',
        name: 'Budi Doremi',
        internshipPosition: 'Backend Developer @ Tokopedia',
        avatarUrl: null,
        currentWeek: 11,
        totalWeeks: 14,
        progressPercent: 0.75,
        weeklyReports: [
          WeeklyReportDosen(
            id: 'report-budi-10',
            weekNumber: 10,
            title: 'API Documentation',
            submittedBy: 'Budi Doremi',
            submittedAt: DateTime.now().subtract(const Duration(hours: 48)),
            reportContent:
                'Created comprehensive API documentation using OpenAPI spec. Documented 25+ endpoints with request/response examples. Created postman collection for testing.',
            isApproved: true,
            lecturerFeedback: 'Well-documented API endpoints!',
          ),
        ],
      ),
      MahasiswaBimbingan(
        id: 'mhs-anita',
        name: 'Anita W.',
        internshipPosition: 'Product Manager @ Bukalapak',
        avatarUrl: null,
        currentWeek: 10,
        totalWeeks: 13,
        progressPercent: 0.70,
        weeklyReports: [
          WeeklyReportDosen(
            id: 'report-anita-9',
            weekNumber: 9,
            title: 'Market Analysis',
            submittedBy: 'Anita W.',
            submittedAt: DateTime.now().subtract(const Duration(hours: 72)),
            reportContent:
                'Analyzed competitive landscape and identified market opportunities. Created product strategy document with 3-year roadmap. Presented findings to stakeholders.',
            isApproved: true,
            lecturerFeedback: 'Comprehensive market analysis!',
          ),
        ],
      ),
    ]);
  }

  void approveDosenReport({
    required String studentId,
    required String reportId,
    required String feedback,
  }) {
    // Find the student and report
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

          // Decrement total approval needed
          dosenStats = dosenStats.copyWith(
            totalApprovalNeeded: dosenStats.totalApprovalNeeded - 1,
          );

          notifyListeners();
          return;
        }
      }
    }
  }

  void rejectDosenReport({
    required String studentId,
    required String reportId,
    required String reason,
  }) {
    // Find the student and report - mark for revision
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
