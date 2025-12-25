import 'package:equatable/equatable.dart';

enum NoticePriority { low, medium, high }
enum NoticeCategory { general, maintenance, event, emergency }

class NoticeModel extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final NoticePriority priority;
  final NoticeCategory category;
  final String author;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const NoticeModel({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.priority,
    required this.category,
    required this.author,
    this.isArchived = false,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        content,
        date,
        priority,
        category,
        author,
        isArchived,
        createdAt,
        updatedAt,
      ];

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String),
      priority: _noticePriorityFromString(json['priority'] as String),
      category: _noticeCategoryFromString(json['category'] as String),
      author: json['author'] as String,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static NoticePriority _noticePriorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'medium':
        return NoticePriority.medium;
      case 'high':
        return NoticePriority.high;
      case 'low':
      default:
        return NoticePriority.low;
    }
  }

  static NoticeCategory _noticeCategoryFromString(String category) {
    switch (category.toLowerCase()) {
      case 'maintenance':
        return NoticeCategory.maintenance;
      case 'event':
        return NoticeCategory.event;
      case 'emergency':
        return NoticeCategory.emergency;
      case 'general':
      default:
        return NoticeCategory.general;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'priority': priority.name,
      'category': category.name,
      'author': author,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

