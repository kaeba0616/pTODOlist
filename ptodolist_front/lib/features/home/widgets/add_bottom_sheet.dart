import 'package:flutter/material.dart';

enum AddType { routine, task }

class AddBottomSheet extends StatelessWidget {
  const AddBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 32,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.repeat),
            title: const Text('루틴 추가'),
            subtitle: const Text('매일 반복하는 할 일'),
            onTap: () => Navigator.pop(context, AddType.routine),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: const Text('할 일 추가'),
            subtitle: const Text('오늘만 할 일'),
            onTap: () => Navigator.pop(context, AddType.task),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
