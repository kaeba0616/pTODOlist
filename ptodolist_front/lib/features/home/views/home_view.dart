import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('오늘'),
      ),
      body: const Center(
        child: Text(
          '오늘의 할 일',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
