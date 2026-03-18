import 'package:hive/hive.dart';
import 'package:ptodolist/features/routine/models/routine.dart';

class RoutineAdapter extends TypeAdapter<Routine> {
  @override
  final int typeId = 1;

  @override
  Routine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Routine(
      id: fields[0] as String,
      title: fields[1] as String,
      categoryId: fields[2] as String,
      createdAt: fields[3] as DateTime,
      isActive: fields[4] as bool,
      order: fields[5] as int,
      subtasks: fields.containsKey(6)
          ? List<String>.from(fields[6] as List)
          : const [],
    );
  }

  @override
  void write(BinaryWriter writer, Routine obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.order)
      ..writeByte(6)
      ..write(obj.subtasks);
  }
}
