import 'package:flutter/material.dart';
import 'package:ptodolist/core/utils/color_utils.dart';
import 'package:ptodolist/features/category/models/category.dart';

class CategoryTile extends StatelessWidget {
  final Category category;
  final int itemCount;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const CategoryTile({
    super.key,
    required this.category,
    this.itemCount = 0,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(category.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        if (category.name == '기타') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("'기타' 카테고리는 삭제할 수 없습니다")),
          );
          return false;
        }
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('카테고리 삭제'),
            content: Text(
              "'${category.name}' 카테고리를 삭제하면\n이 카테고리의 루틴과 할 일이 '기타'로 이동됩니다.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('삭제', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        leading: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: parseHexColor(category.color),
            shape: BoxShape.circle,
          ),
        ),
        title: Text(category.name),
        trailing: Text(
          '$itemCount개',
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.grey),
        ),
        onTap: onTap,
      ),
    );
  }
}
