import 'package:hive/hive.dart';
import 'package:ptodolist/features/home/models/daily_record.dart';

class DailyRecordAdapter extends TypeAdapter<DailyRecord> {
  @override
  final int typeId = 3;

  @override
  DailyRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyRecord(
      date: fields[0] as String,
      routineCompletions: Map<String, bool>.from(fields[1] as Map),
    );
  }

  @override
  void write(BinaryWriter writer, DailyRecord obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.routineCompletions);
  }
}
