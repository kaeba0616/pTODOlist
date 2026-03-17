import 'package:hive/hive.dart';
import 'package:ptodolist/features/task/models/additional_task.dart';

class AdditionalTaskAdapter extends TypeAdapter<AdditionalTask> {
  @override
  final int typeId = 2;

  @override
  AdditionalTask read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AdditionalTask(
      id: fields[0] as String,
      title: fields[1] as String,
      categoryId: fields[2] as String,
      createdAt: fields[3] as DateTime,
      targetDate: fields[4] as String,
      isCompleted: fields[5] as bool,
      order: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AdditionalTask obj) {
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
      ..write(obj.targetDate)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.order);
  }
}
