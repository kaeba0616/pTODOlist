class Routine {
  final String id;
  final String title;
  final String categoryId;
  final DateTime createdAt;
  final bool isActive;
  final int order;
  final List<String> subtasks;
  final int priority; // 0=낮음, 1=보통, 2=높음
  final int? iconCodePoint; // Material Icon codePoint, null=기본
  final List<int> activeDays; // 1=월~7=일, []=매일

  const Routine({
    required this.id,
    required this.title,
    required this.categoryId,
    required this.createdAt,
    this.isActive = true,
    this.order = 0,
    this.subtasks = const [],
    this.priority = 1,
    this.iconCodePoint,
    this.activeDays = const [],
  });

  /// 해당 요일에 활성인지 확인 (weekday: 1=월~7=일)
  bool isActiveOnDay(int weekday) {
    if (activeDays.isEmpty) return true; // 매일
    return activeDays.contains(weekday);
  }

  Routine copyWith({
    String? id,
    String? title,
    String? categoryId,
    DateTime? createdAt,
    bool? isActive,
    int? order,
    List<String>? subtasks,
    int? priority,
    int? Function()? iconCodePoint,
    List<int>? activeDays,
  }) {
    return Routine(
      id: id ?? this.id,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      subtasks: subtasks ?? this.subtasks,
      priority: priority ?? this.priority,
      iconCodePoint: iconCodePoint != null
          ? iconCodePoint()
          : this.iconCodePoint,
      activeDays: activeDays ?? this.activeDays,
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
        order != other.order ||
        priority != other.priority ||
        iconCodePoint != other.iconCodePoint)
      return false;
    if (subtasks.length != other.subtasks.length) return false;
    for (int i = 0; i < subtasks.length; i++) {
      if (subtasks[i] != other.subtasks[i]) return false;
    }
    if (activeDays.length != other.activeDays.length) return false;
    for (int i = 0; i < activeDays.length; i++) {
      if (activeDays[i] != other.activeDays[i]) return false;
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
    priority,
    iconCodePoint,
    Object.hashAll(subtasks),
    Object.hashAll(activeDays),
  );
}
