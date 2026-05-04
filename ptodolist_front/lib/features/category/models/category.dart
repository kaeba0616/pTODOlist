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

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'color': color,
        'icon': icon,
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as String,
        name: (map['name'] as String?) ?? '',
        color: (map['color'] as String?) ?? '#9E9E9E',
        icon: map['icon'] as String?,
      );
}
