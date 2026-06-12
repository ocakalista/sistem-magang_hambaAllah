import 'package:flutter/material.dart';

import 'application_model.dart';

class NexusAppState extends ChangeNotifier {
  Application? _currentApplication;
  final Set<String> _savedInternshipIds = <String>{};

  Application? get currentApplication => _currentApplication;

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

    application.status = status;

    if (status == ApplicationStatus.accepted) {
      application.currentWeek ??= 3;
      application.totalWeeks ??= 6;
      application.progressPercent ??= 0.5;
      if (application.weeklyReports.isEmpty) {
        application.weeklyReports = buildDemoWeeklyReports();
      }
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
