class AdditionalTask {
  final String id;
  final String title;
  final String categoryId;
  final DateTime createdAt;
  final String targetDate; // yyyy-MM-dd
  final bool isCompleted;
  final int order;

  const AdditionalTask({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.createdAt,
    required this.targetDate,
    this.isCompleted = false,
    this.order = 0,
  });

  AdditionalTask copyWith({
    String? id,
    String? title,
    String? categoryId,
    DateTime? createdAt,
    String? targetDate,
    bool? isCompleted,
    int? order,
  }) {
    return AdditionalTask(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdditionalTask &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          categoryId == other.categoryId &&
          targetDate == other.targetDate &&
          isCompleted == other.isCompleted &&
          order == other.order;

  @override
  int get hashCode =>
      Object.hash(id, title, categoryId, targetDate, isCompleted, order);
}
