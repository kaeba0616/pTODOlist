import 'package:flutter/material.dart';
import 'package:ptodolist/features/category/models/category.dart';

class TaskFormView extends StatefulWidget {
  final List<Category> categories;

  const TaskFormView({super.key, required this.categories});

  @override
  State<TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<TaskFormView> {
  late final TextEditingController _titleController;
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _selectedCategoryId =
        widget.categories.isNotEmpty ? widget.categories.last.id : '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 7) buffer.write('FF');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
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
          Text('할 일 추가', style: Theme.of(context).textTheme.titleLarge),
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
                        color: _parseColor(c.color),
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
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _titleController.text.trim().isEmpty
                ? null
                : () {
                    Navigator.pop(context, {
                      'title': _titleController.text.trim(),
                      'categoryId': _selectedCategoryId,
                    });
                  },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
