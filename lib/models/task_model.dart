import 'category_model.dart';
import 'user_model.dart';

class Task {
  final int id;
  final String title;
  final String description;
  final bool done;
  final User user;
  final Category category;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.done,
    required this.user,
    required this.category,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      done: json['done'],
      user: User.fromJson(json['user']),
      category: Category.fromJson(json['category']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'done': done,
        'user': user.toJson(),
        'category': category.toJson(),
      };
}