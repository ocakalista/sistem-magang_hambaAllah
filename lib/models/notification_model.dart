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
    );
  }
}