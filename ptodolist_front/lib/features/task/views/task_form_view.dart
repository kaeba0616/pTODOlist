import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/core/utils/color_utils.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';

class TaskFormView extends StatefulWidget {
  final AdditionalTask? task; // null이면 추가, 있으면 수정
  final List<Category> categories;

  const TaskFormView({super.key, this.task, required this.categories});

  @override
  State<TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<TaskFormView> {
  late final TextEditingController _titleController;
  late String _selectedCategoryId;
  late List<String> _subtasks;
  late DateTime _targetDate;
  final _subtaskController = TextEditingController();
  static final _dateFmt = DateFormat('yyyy-MM-dd');

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _selectedCategoryId =
        widget.task?.categoryId ??
        (widget.categories.isNotEmpty ? widget.categories.last.id : '');
    _subtasks = List.from(widget.task?.subtasks ?? []);
    _targetDate = widget.task != null
        ? DateTime.parse(widget.task!.targetDate)
        : DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
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
              _isEditing ? '할 일 수정' : '할 일 추가',
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
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '날짜',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(DateFormat('yyyy년 M월 d일').format(_targetDate)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '세부 항목',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._subtasks.asMap().entries.map((entry) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.subdirectory_arrow_right,
                  size: 18,
                  color: Colors.grey[500],
                ),
                title: Text(entry.value),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() => _subtasks.removeAt(entry.key));
                  },
                ),
              );
            }),
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
                        'subtasks': _subtasks,
                        'targetDate': _dateFmt.format(_targetDate),
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
