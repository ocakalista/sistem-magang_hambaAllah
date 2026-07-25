import 'package:flutter/material.dart';

enum NotificationCategory { update, approval }

enum NotificationPriority { normal, high }

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    required this.priority,
    required this.icon,
    this.isRead = false,
    this.group,
    this.data = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final NotificationCategory category;
  final NotificationPriority priority;
  final IconData icon;
  bool isRead;
  final String? group;
  final Map<String, dynamic> data;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    final data =
        rawData is Map
            ? rawData.map((key, value) => MapEntry(key.toString(), value))
            : <String, dynamic>{};
    final type = (json['type'] ?? data['type'] ?? '').toString().toLowerCase();
    final categoryValue =
        (json['category'] ?? data['category'] ?? '').toString().toLowerCase();
    final requiresAction =
        data['requires_action'] == true ||
        data['requires_action']?.toString() == '1';
    final isApproval =
        categoryValue == 'approval' ||
        requiresAction ||
        type.contains('submitted') ||
        type.contains('resubmitted') ||
        type.contains('approval') ||
        type == 'pelamar_baru';
    final readAt = json['read_at'];
    final createdAt =
        DateTime.tryParse(json['created_at']?.toString() ?? '') ??
        DateTime.now();

    return AppNotification(
      id: json['id']?.toString() ?? '',
      title: (json['title'] ?? data['title'] ?? 'Notifikasi').toString(),
      description:
          (json['description'] ??
                  json['message'] ??
                  data['message'] ??
                  data['description'] ??
                  '')
              .toString(),
      timestamp: createdAt,
      category:
          isApproval
              ? NotificationCategory.approval
              : NotificationCategory.update,
      priority:
          requiresAction || data['priority']?.toString() == 'high'
              ? NotificationPriority.high
              : NotificationPriority.normal,
      icon:
          isApproval
              ? Icons.assignment_turned_in_rounded
              : Icons.notifications_rounded,
      isRead: readAt != null && readAt.toString().isNotEmpty,
      group:
          readAt == null || readAt.toString().isEmpty
              ? 'New Notifications'
              : 'Earlier Today',
      data: data,
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? timestamp,
    NotificationCategory? category,
    NotificationPriority? priority,
    IconData? icon,
    bool? isRead,
    String? group,
    Map<String, dynamic>? data,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      icon: icon ?? this.icon,
      isRead: isRead ?? this.isRead,
      group: group ?? this.group,
      data: data ?? this.data,
    );
  }
}
