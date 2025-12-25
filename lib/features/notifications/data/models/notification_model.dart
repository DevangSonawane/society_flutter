import 'package:equatable/equatable.dart';

enum NotificationType {
  complaint,
  payment,
  permission,
  maintenance,
  notice,
  general,
}

enum NotificationPriority {
  low,
  medium,
  high,
}

class NotificationModel extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final NotificationPriority priority;
  final bool isRead;
  final String? relatedId; // ID of related entity (complaint, payment, etc.)
  final String? relatedType; // Type of related entity
  final DateTime createdAt;
  final DateTime? readAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.priority = NotificationPriority.medium,
    this.isRead = false,
    this.relatedId,
    this.relatedType,
    required this.createdAt,
    this.readAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        message,
        type,
        priority,
        isRead,
        relatedId,
        relatedType,
        createdAt,
        readAt,
      ];

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: _notificationTypeFromString(json['type'] as String),
      priority: _notificationPriorityFromString(json['priority'] as String? ?? 'medium'),
      isRead: json['is_read'] as bool? ?? false,
      relatedId: json['related_id'] as String?,
      relatedType: json['related_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  static NotificationType _notificationTypeFromString(String type) {
    switch (type.toLowerCase()) {
      case 'complaint':
        return NotificationType.complaint;
      case 'payment':
        return NotificationType.payment;
      case 'permission':
        return NotificationType.permission;
      case 'maintenance':
        return NotificationType.maintenance;
      case 'notice':
        return NotificationType.notice;
      case 'general':
      default:
        return NotificationType.general;
    }
  }

  static NotificationPriority _notificationPriorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return NotificationPriority.high;
      case 'medium':
        return NotificationPriority.medium;
      case 'low':
      default:
        return NotificationPriority.low;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'priority': priority.name,
      'is_read': isRead,
      'related_id': relatedId,
      'related_type': relatedType,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    NotificationPriority? priority,
    bool? isRead,
    String? relatedId,
    String? relatedType,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      relatedId: relatedId ?? this.relatedId,
      relatedType: relatedType ?? this.relatedType,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

