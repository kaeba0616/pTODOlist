import 'package:flutter/material.dart';

class IconPreset {
  final String label;
  final IconData icon;

  const IconPreset(this.label, this.icon);
}

const routineIconPresets = [
  IconPreset('운동', Icons.fitness_center),
  IconPreset('독서', Icons.menu_book),
  IconPreset('물', Icons.water_drop),
  IconPreset('코딩', Icons.computer),
  IconPreset('음악', Icons.music_note),
  IconPreset('시간', Icons.alarm),
  IconPreset('명상', Icons.self_improvement),
  IconPreset('글쓰기', Icons.edit_note),
  IconPreset('쇼핑', Icons.shopping_cart),
  IconPreset('목표', Icons.gps_fixed),
  IconPreset('근력', Icons.sports_martial_arts),
  IconPreset('수면', Icons.bedtime),
  IconPreset('식사', Icons.restaurant),
  IconPreset('청소', Icons.cleaning_services),
  IconPreset('약', Icons.medication),
  IconPreset('이메일', Icons.email),
  IconPreset('창작', Icons.palette),
  IconPreset('알림', Icons.notifications),
  IconPreset('중요', Icons.star),
  IconPreset('집', Icons.home),
  IconPreset('연락', Icons.phone),
  IconPreset('산책', Icons.directions_walk),
  IconPreset('학습', Icons.psychology),
  IconPreset('기본', Icons.check_circle),
];
