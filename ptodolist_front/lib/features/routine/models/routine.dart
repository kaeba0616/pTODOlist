class Routine {
  final String id;
  final String title;
  final String categoryId;
  final DateTime createdAt;
  final bool isActive;
  final int order;
  final List<String> subtasks;

  const Routine({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.createdAt,
    this.isActive = true,
    this.order = 0,
    this.subtasks = const [],
  });

  Routine copyWith({
    String? id,
    String? title,
    String? categoryId,
    DateTime? createdAt,
    bool? isActive,
    int? order,
    List<String>? subtasks,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      subtasks: subtasks ?? this.subtasks,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Routine || runtimeType != other.runtimeType) return false;
    if (id != other.id ||
        title != other.title ||
        categoryId != other.categoryId ||
        isActive != other.isActive ||
        order != other.order)
      return false;
    if (subtasks.length != other.subtasks.length) return false;
    for (int i = 0; i < subtasks.length; i++) {
      if (subtasks[i] != other.subtasks[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    categoryId,
    isActive,
    order,
    Object.hashAll(subtasks),
  );
}
