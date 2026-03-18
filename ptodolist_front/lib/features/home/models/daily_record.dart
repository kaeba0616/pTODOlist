class DailyRecord {
  final String date; // yyyy-MM-dd
  final Map<String, bool> routineCompletions; // routineId -> completed

  const DailyRecord({required this.date, required this.routineCompletions});

  DailyRecord copyWith({String? date, Map<String, bool>? routineCompletions}) {
    return DailyRecord(
      date: date ?? this.date,
      routineCompletions:
          routineCompletions ?? Map.from(this.routineCompletions),
    );
  }

  bool isRoutineCompleted(String routineId) {
    return routineCompletions[routineId] ?? false;
  }

  DailyRecord toggleRoutine(String routineId) {
    final updated = Map<String, bool>.from(routineCompletions);
    updated[routineId] = !(updated[routineId] ?? false);
    return copyWith(routineCompletions: updated);
  }

  int get completedCount => routineCompletions.values.where((v) => v).length;

  int get totalCount => routineCompletions.length;

  double get completionRate =>
      totalCount == 0 ? 0.0 : completedCount / totalCount;
}
