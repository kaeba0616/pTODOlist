import 'package:flutter/material.dart';
import 'package:ptodolist/features/category/models/category.dart';
import 'package:ptodolist/features/category/repos/category_repo.dart';
import 'package:ptodolist/features/category/views/category_edit_view.dart';
import 'package:ptodolist/features/category/widgets/category_tile.dart';

class CategoryListView extends StatefulWidget {
  final CategoryRepository repository;

  const CategoryListView({super.key, required this.repository});

  @override
  State<CategoryListView> createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  List<Category> get _categories => widget.repository.getAll();

  Future<void> _showEditSheet({Category? category}) async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => CategoryEditView(category: category),
    );

    if (result != null && mounted) {
      if (category != null) {
        await widget.repository.update(
          category.copyWith(name: result['name']!, color: result['color']!),
        );
      } else {
        await widget.repository.add(
            name: result['name']!, color: result['color']!);
      }
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('카테고리 관리')),
      body: Column(
        children: [
          Expanded(
            child: _categories.isEmpty
                ? const Center(child: Text('카테고리가 없습니다'))
                : ListView.separated(
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return CategoryTile(
                        category: category,
                        onTap: () => _showEditSheet(category: category),
                        onDelete: () async {
                          await widget.repository.delete(category.id);
                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: () => _showEditSheet(),
              icon: const Icon(Icons.add),
              label: const Text('카테고리 추가'),
            ),
          ),
        ],
      ),
    );
  }
}
