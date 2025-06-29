class Category {
  final int id;
  final String name;
  final int userId;
  final DateTime createdAt;
  final int? taskCount;

  Category({
    required this.id,
    required this.name,
    required this.userId,
    required this.createdAt,
    this.taskCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      userId: json['userId'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
      taskCount: json['taskCount'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'userId': userId,
    'createdAt': createdAt.toIso8601String(),
    'taskCount': taskCount,
  };

  Category copyWith({
    int? id,
    String? name,
    int? userId,
    DateTime? createdAt,
    int? taskCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      taskCount: taskCount ?? this.taskCount,
    );
  }
}
