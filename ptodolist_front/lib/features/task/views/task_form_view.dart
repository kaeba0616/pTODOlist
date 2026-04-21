import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ptodolist/core/theme/app_theme.dart';
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
  final _subtaskFocusNode = FocusNode();
  bool _isDirty = false;
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

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
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
      _markDirty();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtaskController.dispose();
    _subtaskFocusNode.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _subtasks.add(text);
      _subtaskController.clear();
      _isDirty = true;
    });
    _subtaskFocusNode.requestFocus();
  }

  bool get _canSave => _titleController.text.trim().isNotEmpty;

  Map<String, dynamic> _buildResult() => {
        'title': _titleController.text.trim(),
        'categoryId': _selectedCategoryId,
        'subtasks': _subtasks,
        'targetDate': _dateFmt.format(_targetDate),
      };

  void _save() {
    if (!_canSave) return;
    Navigator.pop(context, _buildResult());
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('삭제'),
        content: Text("'${widget.task!.title}' 을(를) 삭제하시겠습니까?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.pop(context, {'_action': 'delete'});
    }
  }

  Future<bool> _handleExit() async {
    if (!_isDirty) return true;
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('저장하지 않은 변경사항'),
        content: const Text('편집 중인 내용이 있습니다. 저장하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'cancel'),
            child: const Text('계속 편집'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'discard'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('나가기'),
          ),
          TextButton(
            onPressed: _canSave ? () => Navigator.pop(ctx, 'save') : null,
            child: const Text('저장'),
          ),
        ],
      ),
    );
    if (!mounted) return false;
    switch (choice) {
      case 'save':
        Navigator.pop(context, _buildResult());
        return false;
      case 'discard':
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _handleExit();
        if (shouldPop && mounted) Navigator.pop(context);
      },
      child: Padding(
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? '할 일 수정' : '할 일 추가',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (_isEditing)
                    IconButton(
                      tooltip: '삭제',
                      icon: const Icon(Icons.delete_outline),
                      color: AppTheme.error,
                      onPressed: _confirmDelete,
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _titleController,
                maxLength: 30,
                decoration: const InputDecoration(
                  labelText: '제목',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() {});
                  _markDirty();
                },
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
                  if (value != null) {
                    setState(() => _selectedCategoryId = value);
                    _markDirty();
                  }
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
              if (_subtasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '세부 항목을 추가하면 할 일을 더 세분화할 수 있어요',
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
                          _markDirty();
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
                      focusNode: _subtaskFocusNode,
                      maxLength: 30,
                      textInputAction: TextInputAction.done,
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
                onPressed: _canSave ? _save : null,
                child: const Text('저장'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
