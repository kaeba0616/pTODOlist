import 'package:flutter/material.dart';

class StatsView extends StatelessWidget {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
      ),
      body: const Center(
        child: Text(
          '달성률 통계',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
