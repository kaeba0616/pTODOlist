import 'package:flutter/material.dart';
import 'package:ptodolist/core/utils/color_utils.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/routine/models/routine.dart';
import 'package:ptodolist/features/routine/widgets/icon_presets.dart';

class RoutineFormView extends StatefulWidget {
  final Routine? routine; // null이면 추가, 있으면 수정
  final List<Category> categories;

  const RoutineFormView({super.key, this.routine, required this.categories});

  @override
  State<RoutineFormView> createState() => _RoutineFormViewState();
}

class _RoutineFormViewState extends State<RoutineFormView> {
  late final TextEditingController _titleController;
  late String _selectedCategoryId;
  late bool _isActive;
  late List<String> _subtasks;
  late int _priority;
  late int? _iconCodePoint;
  late Set<int> _activeDays; // 1=월~7=일
  final _subtaskController = TextEditingController();

  static const _dayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  bool get _isEditing => widget.routine != null;
  bool get _isEveryDay => _activeDays.isEmpty || _activeDays.length == 7;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.routine?.title ?? '');
    _selectedCategoryId =
        widget.routine?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.last.id : '');
    _isActive = widget.routine?.isActive ?? true;
    _subtasks = List.from(widget.routine?.subtasks ?? []);
    _priority = widget.routine?.priority ?? 1;
    _iconCodePoint = widget.routine?.iconCodePoint;
    final days = widget.routine?.activeDays ?? [];
    _activeDays = days.isEmpty ? {1, 2, 3, 4, 5, 6, 7} : Set.from(days);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(text);
      _subtaskController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isEditing ? '루틴 수정' : '루틴 추가',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController,
              maxLength: 30,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: const InputDecoration(
                labelText: '카테고리',
                border: OutlineInputBorder(),
              ),
              items: widget.categories.map((c) {
                return DropdownMenuItem(
                  value: c.id,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: parseHexColor(c.color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(c.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategoryId = value);
              },
            ),
            const SizedBox(height: 20),
            Text(
              '아이콘',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: GridView.count(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: routineIconPresets.map((preset) {
                  final isSelected = _iconCodePoint == preset.icon.codePoint;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _iconCodePoint = isSelected
                            ? null
                            : preset.icon.codePoint;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(
                                color: Theme.of(context).colorScheme.primary,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Icon(
                        preset.icon,
                        size: 22,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[600],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '우선순위',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('낮음')),
                ButtonSegment(value: 1, label: Text('보통')),
                ButtonSegment(value: 2, label: Text('높음')),
              ],
              selected: {_priority},
              onSelectionChanged: (values) {
                setState(() => _priority = values.first);
              },
            ),
            const SizedBox(height: 20),
            Text(
              '활성 요일',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: List.generate(7, (index) {
                final day = index + 1; // 1=월 ~ 7=일
                final isSelected = _activeDays.contains(day);
                return FilterChip(
                  label: Text(_dayLabels[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _activeDays.add(day);
                      } else if (_activeDays.length > 1) {
                        _activeDays.remove(day);
                      }
                    });
                  },
                );
              }),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('비활성화'),
                subtitle: const Text('홈 화면에서 숨깁니다'),
                value: !_isActive,
                onChanged: (value) =>
                    setState(() => _isActive = !(value ?? false)),
              ),
            ],
            const SizedBox(height: 20),
            Text(
              '세부 항목',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_subtasks.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  '세부 항목을 추가하면 루틴을 더 세분화할 수 있어요',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (_subtasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _subtasks.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() => _subtasks.removeAt(entry.key));
                      },
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subtaskController,
                    maxLength: 30,
                    decoration: const InputDecoration(
                      hintText: '세부 항목 추가',
                      border: UnderlineInputBorder(),
                      counterText: '',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addSubtask(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _addSubtask,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _titleController.text.trim().isEmpty
                  ? null
                  : () {
                      Navigator.pop(context, {
                        'title': _titleController.text.trim(),
                        'categoryId': _selectedCategoryId,
                        'isActive': _isActive,
                        'subtasks': _subtasks,
                        'priority': _priority,
                        'iconCodePoint': _iconCodePoint,
                        'activeDays':
                            _isEveryDay ? <int>[] : _activeDays.toList()
                              ..sort(),
                      });
                    },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
