class DailyShareRoutine {
  final String name;
  final bool done;

  const DailyShareRoutine({required this.name, required this.done});

  Map<String, dynamic> toMap() => {'name': name, 'done': done};

  factory DailyShareRoutine.fromMap(Map<String, dynamic> map) =>
      DailyShareRoutine(
        name: (map['name'] as String?) ?? '',
        done: (map['done'] as bool?) ?? false,
      );
}

class DailyShare {
  final String uid;
  final String nickname;
  final String date; // yyyy-MM-dd
  final int completedCount;
  final int totalCount;
  final double rate; // 0.0 ~ 1.0
  final List<DailyShareRoutine> routines;
  final DateTime updatedAt;

  const DailyShare({
    required this.uid,
    required this.nickname,
    required this.date,
    required this.completedCount,
    required this.totalCount,
    required this.rate,
    required this.routines,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'nickname': nickname,
        'date': date,
        'completedCount': completedCount,
        'totalCount': totalCount,
        'rate': rate,
        'routines': routines.map((r) => r.toMap()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory DailyShare.fromMap(Map<String, dynamic> map) {
    final list = (map['routines'] as List<dynamic>? ?? [])
        .map((e) => DailyShareRoutine.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    return DailyShare(
      uid: (map['uid'] as String?) ?? '',
      nickname: (map['nickname'] as String?) ?? '',
      date: (map['date'] as String?) ?? '',
      completedCount: (map['completedCount'] as num?)?.toInt() ?? 0,
      totalCount: (map['totalCount'] as num?)?.toInt() ?? 0,
      rate: (map['rate'] as num?)?.toDouble() ?? 0.0,
      routines: list,
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static String docId(String uid, String date) => '${uid}_$date';
}
