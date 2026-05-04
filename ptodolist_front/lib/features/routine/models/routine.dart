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
  final String? deletedAt; // yyyy-MM-dd, null=삭제 안됨

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
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

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
    String? Function()? deletedAt,
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
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'categoryId': categoryId,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
        'order': order,
        'subtasks': subtasks,
        'priority': priority,
        'iconCodePoint': iconCodePoint,
        'activeDays': activeDays,
        'deletedAt': deletedAt,
      };

  factory Routine.fromMap(Map<String, dynamic> map) => Routine(
        id: map['id'] as String,
        title: (map['title'] as String?) ?? '',
        categoryId: (map['categoryId'] as String?) ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.now(),
        isActive: (map['isActive'] as bool?) ?? true,
        order: (map['order'] as num?)?.toInt() ?? 0,
        subtasks:
            (map['subtasks'] as List<dynamic>? ?? []).cast<String>(),
        priority: (map['priority'] as num?)?.toInt() ?? 1,
        iconCodePoint: (map['iconCodePoint'] as num?)?.toInt(),
        activeDays:
            (map['activeDays'] as List<dynamic>? ?? []).cast<int>(),
        deletedAt: map['deletedAt'] as String?,
      );
}
