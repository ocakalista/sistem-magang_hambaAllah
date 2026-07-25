import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/dosen_model.dart';
import '../models/nexus_app_state.dart';
import '../models/notification_model.dart';
import '../models/mitra_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/mitra_bottom_nav.dart';
import '../widgets/dosen_bottom_nav.dart';
import 'dosen/dosen_dashboard_screen.dart';
import 'dosen/profile_screen.dart';
import 'dosen/students_screen.dart';
import 'dosen/weekly_report_detail_screen.dart';
import 'mahasiswa/application_history_screen.dart';
import 'mahasiswa/dashboard_mahasiswa.dart';
import 'mahasiswa/profile_screen.dart';
import 'mahasiswa/internship_progress_screen.dart';
import 'mitra/kelola_lowongan_screen.dart';
import 'mitra/mitra_dashboard_screen.dart';
import 'mitra/profile_screen.dart';
import 'mitra/pendaftar_detail_screen.dart';

enum _NotificationFilter { all, updates, approvals }

class NotificationsScreen extends StatefulWidget {
  static const routeName = '/alerts';

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  _NotificationFilter _selectedFilter = _NotificationFilter.all;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotifications());
  }

  Future<void> _loadNotifications() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      await NexusScope.of(context).loadNotifications();
    } catch (error) {
      _loadError = error.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = NexusScope.of(context);
    final role = state.currentUserRole;

    final filteredNotifications = _filteredNotifications(state.notifications);
    final newNotifications =
        filteredNotifications
            .where((notification) => notification.group == 'New Notifications')
            .toList();
    final earlierNotifications =
        filteredNotifications
            .where((notification) => notification.group == 'Earlier Today')
            .toList();
    final unreadCount =
        newNotifications.where((notification) => !notification.isRead).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // INJEKSI: Tombol back hanya muncul untuk Admin karena Admin tidak punya bottom nav Alerts
        automaticallyImplyLeading: role == UserRole.admin,
        titleSpacing: role == UserRole.admin ? 0 : 20,
        title: Row(
          children: [
            const Icon(Icons.notifications_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(
              'Alerts',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: const Color(0xFFF3ECFF),
              shape: const CircleBorder(),
              child: IconButton(
                onPressed:
                    state.unreadNotificationCount == 0
                        ? null
                        : state.markAllNotificationsAsRead,
                tooltip: 'Mark all as read',
                icon: const Icon(
                  Icons.done_all_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: IconButton(
              tooltip: 'Profil',
              onPressed: () => _openProfile(context, role),
              icon: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FilterChipsRow(
                selectedFilter: _selectedFilter,
                onChanged: (filter) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
              ),
              const SizedBox(height: 18),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _loadError != null && filteredNotifications.isEmpty
                        ? _NotificationError(
                          message: _loadError!,
                          onRetry: _loadNotifications,
                        )
                        : RefreshIndicator(
                          onRefresh: _loadNotifications,
                          child:
                              filteredNotifications.isEmpty
                                  ? const _EmptyState()
                                  : ListView(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    children: [
                                      if (newNotifications.isNotEmpty) ...[
                                        _SectionHeader(
                                          title: 'New Notifications',
                                          count: unreadCount,
                                          emphasis: true,
                                        ),
                                        const SizedBox(height: 12),
                                        ...newNotifications.map(
                                          (notification) => _NotificationCard(
                                            notification: notification,
                                            onTap:
                                                () => _handleNotificationTap(
                                                  context,
                                                  state,
                                                  notification,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                      if (earlierNotifications.isNotEmpty) ...[
                                        const _SectionHeader(
                                          title: 'Earlier Today',
                                          emphasis: false,
                                        ),
                                        const SizedBox(height: 12),
                                        ...earlierNotifications.map(
                                          (notification) => _NotificationCard(
                                            notification: notification,
                                            mutedIconStyle: true,
                                            onTap:
                                                () => _handleNotificationTap(
                                                  context,
                                                  state,
                                                  notification,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                        ),
              ),
            ],
          ),
        ),
      ),
      // INJEKSI: Dinamis merender Bottom Navigation Bar sesuai Role
      bottomNavigationBar: _buildBottomNav(context, state, role),
    );
  }

  Widget? _buildBottomNav(
    BuildContext context,
    NexusAppState state,
    UserRole role,
  ) {
    if (role == UserRole.mitra) {
      return MitraBottomNavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) => _handleNav(context, state, index),
      );
    } else if (role == UserRole.dosen) {
      return DosenBottomNav(
        selectedIndex: 2,
        onDestinationSelected: (index) => _handleNav(context, state, index),
      );
    } else if (role == UserRole.student) {
      return NexusBottomNavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) => _handleNav(context, state, index),
      );
    }
    return null; // Admin menekan tombol back, tidak pakai nav bawah
  }

  List<AppNotification> _filteredNotifications(List<AppNotification> items) {
    switch (_selectedFilter) {
      case _NotificationFilter.all:
        return items;
      case _NotificationFilter.updates:
        return items
            .where(
              (notification) =>
                  notification.category == NotificationCategory.update,
            )
            .toList();
      case _NotificationFilter.approvals:
        return items
            .where(
              (notification) =>
                  notification.category == NotificationCategory.approval,
            )
            .toList();
    }
  }

  Future<void> _handleNotificationTap(
    BuildContext context,
    NexusAppState state,
    AppNotification notification,
  ) async {
    if (!notification.isRead) {
      try {
        await state.markNotificationAsRead(notification.id);
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Gagal menandai notifikasi: '
                '${error.toString().replaceFirst('Exception: ', '')}',
              ),
            ),
          );
        }
      }
    }

    if (state.currentUserRole == UserRole.mitra &&
        notification.category == NotificationCategory.approval) {
      final applicationId =
          (notification.data['id_pendaftaran'] ??
                  notification.data['application_id'])
              ?.toString();
      if (applicationId != null &&
          applicationId.isNotEmpty &&
          context.mounted) {
        final provider = context.read<MitraProvider>();
        final index = provider.pendaftarTerbaru.indexWhere(
          (item) => item.id == applicationId,
        );
        if (index != -1 && context.mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => PendaftarDetailScreen(
                    applicant: provider.pendaftarTerbaru[index],
                  ),
            ),
          );
          return;
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data pendaftar belum ditemukan. Muat ulang Home.'),
          ),
        );
      }
      return;
    }

    if (state.currentUserRole == UserRole.dosen &&
        notification.category == NotificationCategory.approval) {
      final reportId =
          (notification.data['id_logbook'] ??
                  notification.data['logbook_id'] ??
                  notification.data['id'])
              ?.toString();
      if (reportId == null || reportId.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifikasi belum memiliki ID logbook.'),
            ),
          );
        }
        return;
      }

      MahasiswaBimbingan? student;
      WeeklyReportDosen? report;
      for (final item in state.mahasiswaBimbingan) {
        for (final weeklyReport in item.weeklyReports) {
          if (weeklyReport.id == reportId) {
            student = item;
            report = weeklyReport;
            break;
          }
        }
        if (report != null) break;
      }
      if (report == null) {
        try {
          await state.loadMahasiswaBimbingan();
        } catch (_) {
          // Pesan yang sama di bawah cukup menjelaskan jika data tak ditemukan.
        }
        for (final item in state.mahasiswaBimbingan) {
          for (final weeklyReport in item.weeklyReports) {
            if (weeklyReport.id == reportId) {
              student = item;
              report = weeklyReport;
              break;
            }
          }
          if (report != null) break;
        }
      }
      if (context.mounted && student != null && report != null) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => WeeklyReportDetailScreen(
                  report: report!,
                  student: student!,
                ),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Logbook tidak ditemukan pada daftar mahasiswa bimbingan.',
            ),
          ),
        );
      }
      return;
    }

    if (notification.title == 'Internship Offer' ||
        notification.title == 'Logbook Approved') {
      final application =
          state.activeInternship ?? state.currentApplication;
      if (application != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InternshipProgressScreen(application: application),
          ),
        );
      }
    }
  }

  void _openProfile(BuildContext context, UserRole role) {
    switch (role) {
      case UserRole.dosen:
        Navigator.pushNamed(context, DosenProfileScreen.routeName);
        break;
      case UserRole.mitra:
        Navigator.pushNamed(context, MitraProfileScreen.routeName);
        break;
      case UserRole.student:
        Navigator.pushNamed(context, DashboardMahasiswaProfileScreen.routeName);
        break;
      case UserRole.admin:
        Navigator.pop(context);
        break;
    }
  }

  // INJEKSI: Navigasi disesuaikan dengan setiap menu yang dimiliki role masing-masing
  void _handleNav(BuildContext context, NexusAppState state, int index) {
    if (index == 2) return; // Jika klik tab Alerts lagi, diam saja

    final role = state.currentUserRole;

    if (role == UserRole.dosen) {
      switch (index) {
        case 0:
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
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            nexusTabRoute(const StudentsScreen()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            nexusTabRoute(const DosenProfileScreen()),
          );
          break;
      }
    } else if (role == UserRole.mitra) {
      switch (index) {
        case 0:
          var dashboardFound = false;
          Navigator.of(context).popUntil((route) {
            if (route.settings.name == MitraDashboardScreen.routeName) {
              dashboardFound = true;
              return true;
            }
            return route.isFirst;
          });
          if (!dashboardFound && context.mounted) {
            Navigator.pushReplacement(
              context,
              nexusTabRoute(const MitraDashboardScreen()),
            );
          }
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            nexusTabRoute(const MitraKelolaLowonganScreen()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            nexusTabRoute(const MitraProfileScreen()),
          );
          break;
      }
    } else if (role == UserRole.student) {
      switch (index) {
        case 0:
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
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            nexusTabRoute(const ApplicationHistoryScreen()),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            nexusTabRoute(const DashboardMahasiswaProfileScreen()),
          );
          break;
      }
    }
  }
}

class _FilterChipsRow extends StatelessWidget {
  const _FilterChipsRow({
    required this.selectedFilter,
    required this.onChanged,
  });

  final _NotificationFilter selectedFilter;
  final ValueChanged<_NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final chips = [
      (_NotificationFilter.all, 'All'),
      (_NotificationFilter.updates, 'Updates'),
      (_NotificationFilter.approvals, 'Approvals'),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = chips[index];
          final isSelected = item.$1 == selectedFilter;
          return ChoiceChip(
            label: Text(item.$2),
            selected: isSelected,
            onSelected: (_) => onChanged(item.$1),
            selectedColor: AppColors.primary,
            backgroundColor: const Color(0xFFF2ECFF),
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
            side: BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.emphasis,
    this.count,
  });

  final String title;
  final bool emphasis;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: emphasis ? Colors.black87 : AppColors.neutral,
          ),
        ),
        const SizedBox(width: 10),
        if (count != null && count! > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count New',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    this.mutedIconStyle = false,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final bool mutedIconStyle;

  @override
  Widget build(BuildContext context) {
    final isUnread =
        !notification.isRead && notification.group == 'New Notifications';
    final cardBackground = isUnread ? const Color(0xFFF8F4FF) : Colors.white;
    final iconBackground =
        mutedIconStyle
            ? AppColors.primary.withValues(alpha: 0.10)
            : notification.category == NotificationCategory.approval
            ? AppColors.primary.withValues(alpha: 0.14)
            : AppColors.secondary.withValues(alpha: 0.12);
    final iconColor =
        notification.category == NotificationCategory.approval
            ? AppColors.primary
            : AppColors.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              isUnread
                  ? AppColors.primary.withValues(alpha: 0.10)
                  : const Color(0xFFE9E0FA),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(notification.icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isUnread) ...[
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 7, right: 8),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                          Expanded(
                            child: Text(
                              notification.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatRelativeTime(notification.timestamp),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(color: AppColors.neutral),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        notification.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral,
                          height: 1.45,
                        ),
                      ),
                      if (notification.priority ==
                          NotificationPriority.high) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'HIGH PRIORITY',
                            style: Theme.of(
                              context,
                            ).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    }
    return '${difference.inDays}d ago';
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.55,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.notifications_off_outlined,
                size: 48,
                color: AppColors.neutral,
              ),
              SizedBox(height: 12),
              Text(
                'Tidak ada notifikasi baru',
                style: TextStyle(
                  color: AppColors.neutral,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NotificationError extends StatelessWidget {
  const _NotificationError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: AppColors.neutral,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onRetry, child: const Text('Coba lagi')),
          ],
        ),
      ),
    );
  }
}
