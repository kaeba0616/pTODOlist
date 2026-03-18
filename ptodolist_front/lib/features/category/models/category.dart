class Category {
  final String id;
  final String name;
  final String color;
  final String? icon;

  const Category({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
  });

  Category copyWith({String? id, String? name, String? color, String? icon}) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          color == other.color &&
          icon == other.icon;

  @override
  int get hashCode => Object.hash(id, name, color, icon);
}
