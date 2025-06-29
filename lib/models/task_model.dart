import 'location_model.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final bool done;
  final int? categoryId;
  final int userId;
  final DateTime createdAt;
  final DateTime? dueDate;
  final Location? location;
  final int? reminderMinutes;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.done,
    this.categoryId,
    required this.userId,
    required this.createdAt,
    this.dueDate,
    this.location,
    this.reminderMinutes,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      done: json['done'],
      categoryId: json['categoryId'] ?? null,
      userId: json['userId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      dueDate:
          json['dueDate'] != null && json['dueDate'].toString().isNotEmpty
              ? DateTime.parse(json['dueDate'])
              : null,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      reminderMinutes: json['reminderMinutes'] ?? null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'done': done,
    'categoryId': categoryId,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
    'dueDate': dueDate?.toIso8601String(),
    'location': location?.toJson(),
    'reminderMinutes': reminderMinutes,
  };

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? done,
    int? categoryId,
    int? userId,
    DateTime? createdAt,
    DateTime? dueDate,
    Location? location,
    int? reminderMinutes,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      categoryId: categoryId ?? this.categoryId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      location: location ?? this.location,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }
}
