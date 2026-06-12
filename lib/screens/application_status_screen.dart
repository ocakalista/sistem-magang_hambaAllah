import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/application_model.dart';
import '../models/nexus_app_state.dart';
import '../theme/app_theme.dart';
import 'dashboard_mahasiswa.dart';
import 'internship_progress_screen.dart';
import 'nexus_bottom_navigation_bar.dart';

class ApplicationStatusScreen extends StatelessWidget {
  const ApplicationStatusScreen({super.key, this.application});

  final Application? application;

  @override
  Widget build(BuildContext context) {
    final state = NexusScope.of(context);
    final app = application ?? state.currentApplication;

    if (app == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Nexus'),
          centerTitle: false,
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        body: const Center(child: Text('No application found yet.')),
        bottomNavigationBar: NexusBottomNavigationBar(
          selectedIndex: 1,
          onDestinationSelected: (index) => _handleNav(context, index),
        ),
      );
    }

    final stageIndex = _statusToStageIndex(app.status);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'Nexus',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
            children: [
              _CompanySummaryCard(application: app),
              const SizedBox(height: 18),
              _SectionBlock(
                title: 'Application Progress',
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('View History'),
                ),
                child: _Timeline(application: app, stageIndex: stageIndex),
              ),
              const SizedBox(height: 18),
              _SectionBlock(
                title: 'Activity History',
                child: Column(
                  children:
                      _activityItems(
                        app,
                      ).map((item) => _ActivityRow(item: item)).toList(),
                ),
              ),
              if (app.status.index >= ApplicationStatus.underReview.index) ...[
                const SizedBox(height: 18),
                _FeedbackSection(application: app),
              ],
            ],
          ),
          if (kDebugMode)
            Positioned(
              right: 16,
              bottom: 104,
              child: _DevStatusMenu(
                currentStatus: app.status,
                onChanged: (status) {
                  state.updateApplicationStatus(status);
                  if (status == ApplicationStatus.accepted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const InternshipProgressScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: NexusBottomNavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) => _handleNav(context, index),
      ),
    );
  }

  int _statusToStageIndex(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.submitted:
        return 0;
      case ApplicationStatus.underReview:
        return 1;
      case ApplicationStatus.interview:
        return 2;
      case ApplicationStatus.accepted:
        return 3;
      case ApplicationStatus.rejected:
        return 3;
    }
  }

  List<_ActivityItemData> _activityItems(Application app) {
    return [
      _ActivityItemData(
        icon: Icons.send_rounded,
        title: 'Application submitted',
        description:
            'Your application has been received by ${app.internship.company}.',
        timestamp: 'Just now',
      ),
      _ActivityItemData(
        icon: Icons.search_rounded,
        title: 'Profile screening in progress',
        description: 'The talent team is reviewing your portfolio and resume.',
        timestamp: 'Today',
      ),
      _ActivityItemData(
        icon: Icons.schedule_rounded,
        title: 'Next stage prepared',
        description:
            'You will be notified when the next step becomes available.',
        timestamp: 'Soon',
      ),
    ];
  }

  void _handleNav(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, DashboardMahasiswa.routeName);
    }
  }
}

class _CompanySummaryCard extends StatelessWidget {
  const _CompanySummaryCard({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                children: const [
                  _MiniTag(label: 'Full-time Internship'),
                  _MiniTag(label: '6 Months'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            application.internship.position,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            application.internship.company,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.neutral,
              ),
              const SizedBox(width: 6),
              Text(
                application.internship.location,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.application, required this.stageIndex});

  final Application application;
  final int stageIndex;

  @override
  Widget build(BuildContext context) {
    final stages = [
      _TimelineStage(
        title: 'Application Submitted',
        description:
            'Your internship application has been successfully received.',
        date: application.appliedDate,
        estimatedTime: 'Usually reviewed within 1-2 days.',
      ),
      _TimelineStage(
        title: 'Under Technical Review',
        description:
            'The team is checking your portfolio, resume, and alignment to the role.',
        date: application.appliedDate.add(const Duration(days: 2)),
        estimatedTime: 'Technical review typically takes 3-4 days.',
      ),
      _TimelineStage(
        title: 'Interview Session',
        description:
            'A recruiter or design lead will reach out for a discussion.',
        date: application.appliedDate.add(const Duration(days: 5)),
        estimatedTime: 'Interview invites are usually sent within a week.',
      ),
      _TimelineStage(
        title: 'Final Decision',
        description:
            application.status == ApplicationStatus.rejected
                ? 'Your application was not selected this round, but your profile remains valuable for future openings.'
                : 'Final offer and onboarding details will be shared here.',
        date: application.appliedDate.add(const Duration(days: 9)),
        estimatedTime:
            application.status == ApplicationStatus.rejected
                ? 'You may reapply for future openings.'
                : 'Final decision usually follows soon after interviews.',
      ),
    ];

    return Column(
      children: List.generate(stages.length, (index) {
        final stage = stages[index];
        final isCompleted = index < stageIndex;
        final isCurrent = index == stageIndex;
        final isFuture = index > stageIndex;
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color:
                        isCompleted || isCurrent
                            ? AppColors.primary
                            : const Color(0xFFE3DFEB),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child:
                        isCompleted
                            ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 16,
                            )
                            : isCurrent
                            ? const Icon(
                              Icons.schedule_rounded,
                              color: Colors.white,
                              size: 16,
                            )
                            : Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: AppColors.neutral,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                  ),
                ),
                if (index != stages.length - 1)
                  Container(
                    width: 2,
                    height: 64,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          isFuture
                              ? const Color(0xFFD9D4E4)
                              : AppColors.primary,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isFuture ? AppColors.neutral : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stage.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isFuture ? AppColors.neutral : Colors.black87,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(stage.date),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          stage.estimatedTime,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _TimelineStage {
  const _TimelineStage({
    required this.title,
    required this.description,
    required this.date,
    required this.estimatedTime,
  });

  final String title;
  final String description;
  final DateTime date;
  final String estimatedTime;
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF2ECFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final _ActivityItemData item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F5FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.neutral),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            item.timestamp,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.neutral),
          ),
        ],
      ),
    );
  }
}

class _ActivityItemData {
  const _ActivityItemData({
    required this.icon,
    required this.title,
    required this.description,
    required this.timestamp,
  });

  final IconData icon;
  final String title;
  final String description;
  final String timestamp;
}

class _FeedbackSection extends StatelessWidget {
  const _FeedbackSection({required this.application});

  final Application application;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary, AppColors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'TOP CANDIDATE HIGHLIGHT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Your portfolio scores in the top 5%',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '“The clarity in your case studies and the structure of your design thinking make you stand out for this internship.”',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(
                child: _FeedbackMiniChip(
                  title: 'VIBE CHECK',
                  text: 'Strong design maturity',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _FeedbackMiniChip(
                  title: 'UPSKILLING',
                  text: 'Sharpen mobile micro-interactions',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 124,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  top: -8,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Preparing for the next step? Read our guide before the interview round opens.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackMiniChip extends StatelessWidget {
  const _FeedbackMiniChip({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.94),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DevStatusMenu extends StatelessWidget {
  const _DevStatusMenu({required this.currentStatus, required this.onChanged});

  final ApplicationStatus currentStatus;
  final ValueChanged<ApplicationStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      child: PopupMenuButton<ApplicationStatus>(
        onSelected: onChanged,
        itemBuilder:
            (context) => [
              const PopupMenuItem(
                value: ApplicationStatus.submitted,
                child: Text('Set Submitted'),
              ),
              const PopupMenuItem(
                value: ApplicationStatus.underReview,
                child: Text('Set Under Review'),
              ),
              const PopupMenuItem(
                value: ApplicationStatus.interview,
                child: Text('Set Interview'),
              ),
              const PopupMenuItem(
                value: ApplicationStatus.rejected,
                child: Text('Set Rejected'),
              ),
              const PopupMenuItem(
                value: ApplicationStatus.accepted,
                child: Text('Set Accepted'),
              ),
            ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'DEV',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              Text(
                currentStatus.label,
                style: Theme.of(
                  context,
                ).textTheme.labelSmall?.copyWith(color: AppColors.neutral),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
