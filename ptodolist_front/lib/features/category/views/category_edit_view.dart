import 'package:flutter/material.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/mocks/category_mock.dart';
import 'package:ptodolist/features/category/widgets/color_picker.dart';

class CategoryEditView extends StatefulWidget {
  final Category? category; // null이면 추가, 있으면 수정

  const CategoryEditView({super.key, this.category});

  @override
  State<CategoryEditView> createState() => _CategoryEditViewState();
}

class _CategoryEditViewState extends State<CategoryEditView> {
  late final TextEditingController _nameController;
  late String _selectedColor;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _selectedColor = widget.category?.color ?? categoryColorPresets.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
          Text(
            _isEditing ? '카테고리 수정' : '카테고리 추가',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            maxLength: 20,
            decoration: const InputDecoration(
              labelText: '이름',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Text('색상', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ColorPicker(
            selectedColor: _selectedColor,
            onColorSelected: (color) => setState(() => _selectedColor = color),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _nameController.text.trim().isEmpty
                ? null
                : () {
                    Navigator.pop(context, {
                      'name': _nameController.text.trim(),
                      'color': _selectedColor,
                    });
                  },
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }
}
