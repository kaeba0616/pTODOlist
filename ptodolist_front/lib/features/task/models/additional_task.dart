class AdditionalTask {
  final String id;
  final String title;
  final String categoryId;
  final DateTime createdAt;
  final String targetDate; // yyyy-MM-dd
  final bool isCompleted;
  final int order;
  final List<String> subtasks;
  final List<bool> subtaskCompletions;

  const AdditionalTask({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.createdAt,
    required this.targetDate,
    this.isCompleted = false,
    this.order = 0,
    this.subtasks = const [],
    this.subtaskCompletions = const [],
  });

  bool isSubtaskCompleted(int index) {
    if (index < 0 || index >= subtaskCompletions.length) return false;
    return subtaskCompletions[index];
  }

  bool get areAllSubtasksCompleted {
    if (subtasks.isEmpty) return false;
    for (int i = 0; i < subtasks.length; i++) {
      if (!isSubtaskCompleted(i)) return false;
    }
    return true;
  }

  AdditionalTask copyWith({
    String? id,
    String? title,
    String? categoryId,
    DateTime? createdAt,
    String? targetDate,
    bool? isCompleted,
    int? order,
    List<String>? subtasks,
    List<bool>? subtaskCompletions,
  }) {
    return AdditionalTask(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
      subtasks: subtasks ?? this.subtasks,
      subtaskCompletions: subtaskCompletions ?? this.subtaskCompletions,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AdditionalTask || runtimeType != other.runtimeType)
      return false;
    if (id != other.id ||
        title != other.title ||
        categoryId != other.categoryId ||
        targetDate != other.targetDate ||
        isCompleted != other.isCompleted ||
        order != other.order)
      return false;
    if (subtasks.length != other.subtasks.length) return false;
    for (int i = 0; i < subtasks.length; i++) {
      if (subtasks[i] != other.subtasks[i]) return false;
    }
    if (subtaskCompletions.length != other.subtaskCompletions.length) {
      return false;
    }
    for (int i = 0; i < subtaskCompletions.length; i++) {
      if (subtaskCompletions[i] != other.subtaskCompletions[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    categoryId,
    targetDate,
    isCompleted,
    order,
    Object.hashAll(subtasks),
    Object.hashAll(subtaskCompletions),
  );
}
