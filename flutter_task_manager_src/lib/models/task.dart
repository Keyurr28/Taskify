import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }
enum TaskStatus { pending, completed }
enum TaskCategory { work, personal, health, finance, other }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? dueDate;
  final TaskCategory category;
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    required this.description,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.dueDate,
    this.category = TaskCategory.other,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
    TaskCategory? category,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.index,
      'status': status.index,
      'dueDate': dueDate?.toIso8601String(),
      'category': category.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: TaskPriority.values[json['priority'] ?? 1],
      status: TaskStatus.values[json['status'] ?? 0],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      category: TaskCategory.values[json['category'] ?? 4],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
