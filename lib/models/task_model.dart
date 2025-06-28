import 'location_model.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final bool done;
  final String category;
  final DateTime createdAt;
  final DateTime? dueDate;
  final Location? location;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.done,
    required this.category,
    required this.createdAt,
    this.dueDate,
    this.location,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      done: json['done'],
      category: json['category'],
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'done': done,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
        'location': location?.toJson(),
      };

  Task copyWith({
    int? id,
    String? title,
    String? description,
    bool? done,
    String? category,
    DateTime? createdAt,
    DateTime? dueDate,
    Location? location,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      location: location ?? this.location,
    );
  }
}