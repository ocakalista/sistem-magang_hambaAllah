import 'package:flutter/material.dart';

import '../../models/application_model.dart';
import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../notifications_screen.dart';
import 'application_status_screen.dart';
import 'dashboard_mahasiswa.dart';
import 'internship_progress_screen.dart';
import 'profile_screen.dart';

class ApplicationHistoryScreen extends StatelessWidget {
  const ApplicationHistoryScreen({super.key, this.showBackButton = false});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final applications = NexusScope.of(context).applications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: showBackButton,
        title: const Text('Riwayat Lamaran'),
      ),
      body:
          applications.isEmpty
              ? const Center(child: Text('Belum ada lamaran magang.'))
              : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                itemCount: applications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final application = applications[index];
                  return _ApplicationCard(
                    application: application,
                    onTap: () => _openApplication(context, application),
                  );
                },
              ),
      bottomNavigationBar:
          showBackButton
              ? null
              : NexusBottomNavigationBar(
                selectedIndex: 1,
                onDestinationSelected:
                    (index) => _handleNavigation(context, index),
              ),
    );
  }

  void _openApplication(BuildContext context, Application application) {
    final screen =
        application.status == ApplicationStatus.accepted
            ? InternshipProgressScreen(application: application)
            : ApplicationStatusScreen(application: application);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 1) return;

    if (index == 0) {
      var dashboardFound = false;
      Navigator.of(context).popUntil((route) {
        if (route.settings.name == DashboardMahasiswa.routeName) {
          dashboardFound = true;
          return true;
        }
        return route.isFirst;
      });
      if (!dashboardFound && context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          DashboardMahasiswa.routeName,
        );
      }
      return;
    }

    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
      return;
    }

    if (index == 3) {
      Navigator.pushReplacementNamed(
        context,
        DashboardMahasiswaProfileScreen.routeName,
      );
    }
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application, required this.onTap});

  final Application application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(application.status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.business_center_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.internship.position,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      application.internship.company,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            application.status.label,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(application.appliedDate),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.accepted:
        return const Color(0xFF1E9E59);
      case ApplicationStatus.rejected:
        return const Color(0xFFE5484D);
      case ApplicationStatus.interview:
        return const Color(0xFF2563EB);
      case ApplicationStatus.underReview:
        return const Color(0xFFF59E0B);
      case ApplicationStatus.submitted:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) return '-';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
