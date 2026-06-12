import 'package:flutter/material.dart';

import '../models/application_model.dart';
import '../models/nexus_app_state.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';
import '../widgets/bottom_nav.dart';
import 'application_status_screen.dart';
import 'dashboard_mahasiswa.dart';
import 'internship_progress_screen.dart';

enum _NotificationFilter { all, updates, approvals }

class NotificationsScreen extends StatefulWidget {
  static const routeName = '/alerts';

  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  _NotificationFilter _selectedFilter = _NotificationFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = NexusScope.of(context);
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
        automaticallyImplyLeading: false,
        titleSpacing: 20,
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
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person, color: Colors.white, size: 20),
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
                                  onTap: () => _handleNotificationTap(
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
                                  onTap: () => _handleNotificationTap(
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: NexusBottomNavigationBar(
        selectedIndex: 2,
        onDestinationSelected: (index) => _handleNav(context, state, index),
      ),
    );
  }

  List<AppNotification> _filteredNotifications(List<AppNotification> items) {
    switch (_selectedFilter) {
      case _NotificationFilter.all:
        return items;
      case _NotificationFilter.updates:
        return items
            .where(
              (notification) => notification.category == NotificationCategory.update,
            )
            .toList();
      case _NotificationFilter.approvals:
        return items
            .where(
              (notification) => notification.category == NotificationCategory.approval,
            )
            .toList();
    }
  }

  void _handleNotificationTap(
    BuildContext context,
    NexusAppState state,
    AppNotification notification,
  ) {
    if (!notification.isRead) {
      state.markNotificationAsRead(notification.id);
    }

    if (notification.title == 'Internship Offer' ||
        notification.title == 'Logbook Approved') {
      final application = state.currentApplication;
      if (application != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InternshipProgressScreen(application: application),
          ),
        );
      }
    }
  }

  void _handleNav(BuildContext context, NexusAppState state, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, DashboardMahasiswa.routeName);
        break;
      case 1:
        final application = state.currentApplication;
        if (application == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Apply for an internship first.')),
          );
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    application.status == ApplicationStatus.accepted
                        ? InternshipProgressScreen(application: application)
                        : ApplicationStatusScreen(application: application),
          ),
        );
        break;
      case 2:
        break;
      case 3:
        break;
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
    final isUnread = !notification.isRead && notification.group == 'New Notifications';
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
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatRelativeTime(notification.timestamp),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.neutral,
                            ),
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
                      if (notification.priority == NotificationPriority.high) ...[
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
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
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
    return Center(
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
            'No notifications here',
            style: TextStyle(
              color: AppColors.neutral,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}