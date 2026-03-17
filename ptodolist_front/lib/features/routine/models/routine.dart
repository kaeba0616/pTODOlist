class Routine {
  final String id;
  final String title;
  final String categoryId;
  final DateTime createdAt;
  final bool isActive;
  final int order;

  const Routine({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.createdAt,
    this.isActive = true,
    this.order = 0,
  });

  Routine copyWith({
    String? id,
    String? title,
    String? categoryId,
    DateTime? createdAt,
    bool? isActive,
    int? order,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Routine &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          categoryId == other.categoryId &&
          isActive == other.isActive &&
          order == other.order;

  @override
  int get hashCode => Object.hash(id, title, categoryId, isActive, order);
}
