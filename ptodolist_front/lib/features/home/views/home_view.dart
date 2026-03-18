import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/repos/routine_repo.dart';
import 'package:ptodolist/features/routine/views/routine_form_view.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';
import 'package:ptodolist/features/task/repos/task_repo.dart';
import 'package:ptodolist/features/task/views/task_form_view.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';
import 'package:ptodolist/features/home/repos/daily_record_repo.dart';
import 'package:ptodolist/features/home/widgets/daily_progress_ring.dart';
import 'package:ptodolist/features/home/widgets/add_bottom_sheet.dart';

class HomeView extends StatefulWidget {
  final CategoryRepository categoryRepo;
  final RoutineRepository routineRepo;
  final TaskRepository taskRepo;
  final DailyRecordRepository? dailyRecordRepo;

  const HomeView({
    super.key,
    required this.categoryRepo,
    required this.routineRepo,
    required this.taskRepo,
    this.dailyRecordRepo,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late DailyRecord _dailyRecord;
  final _today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    _initDailyRecord();
  }

  void _initDailyRecord() {
    if (widget.dailyRecordRepo != null) {
      _dailyRecord = widget.dailyRecordRepo!
          .getOrCreateToday(widget.routineRepo.getActive());
    } else {
      final activeRoutines = widget.routineRepo.getActive();
      _dailyRecord = DailyRecord(
        date: _today,
        routineCompletions: {
          for (final r in activeRoutines) r.id: false,
        },
      );
    }
  }

  List<Routine> get _activeRoutines => widget.routineRepo.getActive();

  List<AdditionalTask> get _todayTasks {
    final tasks = widget.taskRepo.getByDate(_today);
    // 미완료 먼저, 완료 나중
    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.order.compareTo(b.order);
    });
    return tasks;
  }

  int get _totalCount => _activeRoutines.length + _todayTasks.length;

  int get _completedCount {
    final routinesDone = _dailyRecord.completedCount;
    final tasksDone = _todayTasks.where((t) => t.isCompleted).length;
    return routinesDone + tasksDone;
  }

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  Category? _getCategoryFor(String categoryId) {
    return widget.categoryRepo.getById(categoryId);
  }

  void _toggleRoutine(String routineId) {
    setState(() {
      _dailyRecord = _dailyRecord.toggleRoutine(routineId);
      widget.dailyRecordRepo?.save(_dailyRecord);
    });
  }

  void _toggleTask(String taskId) {
    setState(() {
      widget.taskRepo.toggleComplete(taskId);
    });
  }

  Future<void> _editRoutine(Routine routine) async {
    final categories = widget.categoryRepo.getAll();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => RoutineFormView(
        routine: routine,
        categories: categories,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        final updated = routine.copyWith(
          title: result['title'],
          categoryId: result['categoryId'],
          isActive: result['isActive'],
          subtasks: List<String>.from(result['subtasks'] ?? []),
        );
        widget.routineRepo.update(updated);
        if (!updated.isActive) {
          final completions =
              Map<String, bool>.from(_dailyRecord.routineCompletions);
          completions.remove(updated.id);
          _dailyRecord =
              _dailyRecord.copyWith(routineCompletions: completions);
          widget.dailyRecordRepo?.save(_dailyRecord);
        }
      });
    }
  }

  Future<void> _editTask(AdditionalTask task) async {
    final categories = widget.categoryRepo.getAll();
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => TaskFormView(
        task: task,
        categories: categories,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        final updated = task.copyWith(
          title: result['title'],
          categoryId: result['categoryId'],
          subtasks: List<String>.from(result['subtasks'] ?? []),
        );
        widget.taskRepo.update(updated);
      });
    }
  }

  Future<void> _showAddSheet() async {
    final type = await showModalBottomSheet<AddType>(
      context: context,
      builder: (_) => const AddBottomSheet(),
    );
    if (type == null || !mounted) return;

    final categories = widget.categoryRepo.getAll();

    if (type == AddType.routine) {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (_) => RoutineFormView(categories: categories),
      );
      if (result != null && mounted) {
        setState(() {
          final id = widget.routineRepo.add(
            title: result['title'],
            categoryId: result['categoryId'],
            subtasks: List<String>.from(result['subtasks'] ?? []),
          );
          final updated = Map<String, bool>.from(_dailyRecord.routineCompletions);
          updated[id] = false;
          _dailyRecord = _dailyRecord.copyWith(routineCompletions: updated);
        });
      }
    } else {
      final result = await showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        builder: (_) => TaskFormView(categories: categories),
      );
      if (result != null && mounted) {
        setState(() {
          widget.taskRepo.add(
            title: result['title'],
            categoryId: result['categoryId'],
            subtasks: List<String>.from(result['subtasks'] ?? []),
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('yyyy년 M월 d일 EEEE', 'ko_KR').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘'),
      ),
      body: _totalCount == 0
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit_note, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('아직 할 일이 없어요'),
                  const SizedBox(height: 4),
                  Text(
                    '+ 버튼으로 추가해보세요',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // 날짜 헤더
                Center(
                  child: Text(
                    dateStr,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                  ),
                ),
                const SizedBox(height: 16),

                // 진행률 링
                Center(
                  child: DailyProgressRing(
                    completed: _completedCount,
                    total: _totalCount,
                  ),
                ),
                const SizedBox(height: 24),

                // 루틴 섹션
                if (_activeRoutines.isNotEmpty) ...[
                  Text(
                    '오늘의 루틴',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ..._activeRoutines.map((routine) {
                    final isDone = _dailyRecord.isRoutineCompleted(routine.id);
                    final category = _getCategoryFor(routine.categoryId);
                    return _buildCheckTile(
                      title: routine.title,
                      isDone: isDone,
                      categoryColor: category?.color ?? '#8B5CF6',
                      subtasks: routine.subtasks,
                      onToggle: () => _toggleRoutine(routine.id),
                      onTap: () => _editRoutine(routine),
                      onDelete: () {
                        setState(() {
                          widget.routineRepo.delete(routine.id);
                          final updated = Map<String, bool>.from(
                              _dailyRecord.routineCompletions);
                          updated.remove(routine.id);
                          _dailyRecord = _dailyRecord.copyWith(
                              routineCompletions: updated);
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // 할 일 섹션
                if (_todayTasks.isNotEmpty) ...[
                  Text(
                    '추가 할 일',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  ..._todayTasks.map((task) {
                    final category = _getCategoryFor(task.categoryId);
                    return _buildCheckTile(
                      title: task.title,
                      isDone: task.isCompleted,
                      categoryColor: category?.color ?? '#8B5CF6',
                      subtasks: task.subtasks,
                      onToggle: () => _toggleTask(task.id),
                      onTap: () => _editTask(task),
                      onDelete: () {
                        setState(() {
                          widget.taskRepo.delete(task.id);
                        });
                      },
                    );
                  }),
                ],
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCheckTile({
    required String title,
    required bool isDone,
    required String categoryColor,
    required VoidCallback onToggle,
    required VoidCallback onTap,
    required VoidCallback onDelete,
    List<String> subtasks = const [],
  }) {
    return Dismissible(
      key: Key(title + isDone.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: onToggle,
              child: Icon(
                isDone ? Icons.check_circle : Icons.circle_outlined,
                color: isDone
                    ? const Color(0xFF10B981)
                    : Theme.of(context).colorScheme.outline,
              ),
            ),
            title: Text(
              title,
              style: TextStyle(
                decoration: isDone ? TextDecoration.lineThrough : null,
                color: isDone ? Colors.grey : null,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (subtasks.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '${subtasks.length}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _parseColor(categoryColor),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            onTap: onTap,
          ),
          if (subtasks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 56, right: 16, bottom: 8),
              child: Column(
                children: subtasks.map((sub) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Icon(Icons.subdirectory_arrow_right,
                            size: 14, color: Colors.grey[400]),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            sub,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDone ? Colors.grey[400] : Colors.grey[600],
                              decoration:
                                  isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
