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
}

class WeeklyReport {
  final int weekNumber;
  final String title;
  final String description;
  final String status;
  final DateTime? dueDate;
  String? feedbackFromLecturer;
  String? lecturerName;

  WeeklyReport({
    required this.weekNumber,
    required this.title,
    required this.description,
    required this.status,
    this.dueDate,
    this.feedbackFromLecturer,
    this.lecturerName,
  });
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

const Internship demoInternship = Internship(
  id: 'tech-nova-senior-product-design',
  position: 'Senior Product Design Intern',
  company: 'TechNova Solutions',
  location: 'Jakarta, ID',
  tags: ['Remote', 'Full-time', '6 Months'],
  period: 'Aug - Jan 2024',
  quota: '3 Positions Left',
  description:
      'Join TechNova Solutions to contribute to fintech app design alongside senior design leads. You will help shape intuitive flows, polish interface systems, and support product decisions that make complex financial experiences feel simple and human.',
  requirements: [
    'Active student in Computer Science, Design, or a related field',
    'Proficiency with Figma, Adobe XD, or Framer',
    'Solid understanding of UI/UX systems and design thinking',
    'Comfort working in a fast-moving agile environment',
  ],
  benefits: [
    'Competitive Stipend',
    'Mentorship Program',
    'Potential Full-time Offer',
  ],
);

List<WeeklyReport> buildDemoWeeklyReports() {
  return [
    WeeklyReport(
      weekNumber: 1,
      title: 'Onboarding and Product Audit',
      description:
          'Completed onboarding sessions, mapped the current design system, and documented UX gaps across the financial onboarding flow.',
      status: 'completed',
      dueDate: DateTime(2024, 8, 9),
      feedbackFromLecturer:
          'Strong observation skills. Keep sharpening your hierarchy decisions.',
      lecturerName: 'Dr. Rina Saraswati',
    ),
    WeeklyReport(
      weekNumber: 2,
      title: 'Wireframe Exploration',
      description:
          'Created low-fidelity wireframes for the savings dashboard and aligned the proposed navigation with the product team.',
      status: 'completed',
      dueDate: DateTime(2024, 8, 16),
      feedbackFromLecturer:
          'Good structure. Consider more contrast in the primary actions.',
      lecturerName: 'Dr. Rina Saraswati',
    ),
    WeeklyReport(
      weekNumber: 3,
      title: 'Interaction Refinement',
      description:
          'Refining component states and preparing the high-fidelity handoff for the payments feature.',
      status: 'ongoing',
      dueDate: DateTime(2024, 8, 23),
      feedbackFromLecturer:
          'You are on track. Focus on edge states before the next review.',
      lecturerName: 'Dr. Rina Saraswati',
    ),
  ];
}
