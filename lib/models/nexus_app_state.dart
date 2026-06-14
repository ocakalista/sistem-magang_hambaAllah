import 'package:flutter/material.dart';

import 'application_model.dart';
import 'admin_model.dart';
import 'notification_model.dart';
import '../theme/app_theme.dart';

enum UserRole { student, admin }

class NexusAppState extends ChangeNotifier {
  NexusAppState() {
    _notifications.addAll(_buildStaticDemoNotifications());
    _initAdminData();
  }

  Application? _currentApplication;
  UserRole currentUserRole = UserRole.student;
  final Set<String> _savedInternshipIds = <String>{};
  final List<AppNotification> _notifications = <AppNotification>[];
  late PlatformStats adminStats;
  final List<StudentEnrollment> studentEnrollments = <StudentEnrollment>[];
  final List<PendingLowongan> pendingLowongan = <PendingLowongan>[];
  final List<InternshipDistribution> internshipDistribution =
      <InternshipDistribution>[];

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

  int get pendingLowonganCount => pendingLowongan.length;

  void approveLowongan(String id) {
    final index = pendingLowongan.indexWhere((p) => p.id == id);
    if (index == -1) return;
    pendingLowongan[index].status = LowonganApprovalStatus.approved;
    pendingLowongan.removeAt(index);
    notifyListeners();
  }

  void rejectLowongan(String id, String reason) {
    final index = pendingLowongan.indexWhere((p) => p.id == id);
    if (index == -1) return;
    pendingLowongan[index].status = LowonganApprovalStatus.rejected;
    // In a real app we'd persist the reason; here we just remove from pending list
    pendingLowongan.removeAt(index);
    notifyListeners();
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
