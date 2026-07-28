import 'package:flutter/material.dart' hide Text;
import 'package:pemrog_hambaallah/l10n/localized_text.dart';

import '../../models/dosen_model.dart';
import '../../models/nexus_app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/bottom_nav.dart';
import '../../widgets/dosen_bottom_nav.dart';
import '../notifications_screen.dart';
import 'dosen_dashboard_screen.dart';
import 'profile_screen.dart';
import 'student_profile_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  late TextEditingController _searchController;
  late List<MahasiswaBimbingan> _filteredStudents;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredStudents = [];
  }

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _updateFilteredStudents('');
      final state = NexusScope.of(context);
      if (state.mahasiswaBimbingan.isEmpty) {
        // load from API (fire-and-forget, state will notify)
        state.loadMahasiswaBimbingan();
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilteredStudents(String query) {
    final state = NexusScope.of(context);
    if (query.isEmpty) {
      _filteredStudents = state.mahasiswaBimbingan;
    } else {
      _filteredStudents =
          state.mahasiswaBimbingan
              .where(
                (student) =>
                    student.name.toLowerCase().contains(query.toLowerCase()) ||
                    student.internshipPosition.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
              )
              .toList();
    }
    setState(() {});
  }

  String _getStatusLabel(double progress) {
    if (progress > 0.7) {
      return 'On Track';
    } else if (progress >= 0.4) {
      return 'Needs Attention';
    } else {
      return 'Behind';
    }
  }

  Color _getStatusColor(double progress) {
    if (progress > 0.7) {
      return Colors.green;
    } else if (progress >= 0.4) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = NexusScope.of(context);
    final students =
        _filteredStudents.isEmpty && _searchController.text.isEmpty
            ? state.mahasiswaBimbingan
            : _filteredStudents;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Text(
          'Mahasiswa Bimbingan',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(
              Icons.notifications_none_rounded,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: tr('Cari mahasiswa...'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon:
                      _searchController.text.isEmpty
                          ? null
                          : IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _updateFilteredStudents('');
                            },
                          ),
                ),
                onChanged: _updateFilteredStudents,
              ),
            ),
            Expanded(
              child:
                  students.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 56,
                              color: AppColors.neutral.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Belum ada mahasiswa bimbingan',
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: AppColors.neutral,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final status = _getStatusLabel(
                            student.progressPercent,
                          );
                          final statusColor = _getStatusColor(
                            student.progressPercent,
                          );

                          final avatarLabel =
                              (student.name.isNotEmpty)
                                  ? student.name[0].toUpperCase()
                                  : '?';

                          return GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => StudentProfileScreen(
                                          student: student,
                                        ),
                                  ),
                                ),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: AppColors.primary,
                                        child: Text(
                                          avatarLabel,
                                          style: const TextStyle(
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            Text(
                                              student.internshipPosition,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.bodySmall?.copyWith(
                                                color: AppColors.neutral,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          'Minggu ${student.currentWeek}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall?.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: student.progressPercent,
                                      minHeight: 8,
                                      backgroundColor: AppColors.background,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(student.progressPercent * 100).toStringAsFixed(0)} %',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelSmall?.copyWith(
                                          color: AppColors.neutral,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          // lokal Bahasa Indonesia
                                          status == 'On Track'
                                              ? 'Sesuai Jadwal'
                                              : status == 'Needs Attention'
                                              ? 'Perlu Perhatian'
                                              : 'Tertinggal',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall?.copyWith(
                                            color: statusColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: DosenBottomNav(
        selectedIndex: 1,
        onDestinationSelected: (index) => _handleNavigation(context, index),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 1) return;
    if (index == 0) {
      _openDosenHome(context);
      return;
    }
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        nexusTabRoute(const NotificationsScreen()),
      );
      return;
    }
    if (index == 3) {
      Navigator.pushReplacement(
        context,
        nexusTabRoute(const DosenProfileScreen()),
      );
    }
  }

  void _openDosenHome(BuildContext context) {
    var dashboardFound = false;
    Navigator.of(context).popUntil((route) {
      if (route.settings.name == DosenDashboardScreen.routeName) {
        dashboardFound = true;
        return true;
      }
      return route.isFirst;
    });
    if (!dashboardFound && context.mounted) {
      Navigator.pushReplacement(
        context,
        nexusTabRoute(const DosenDashboardScreen()),
      );
    }
  }
}
