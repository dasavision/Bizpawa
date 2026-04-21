// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppNoteAdapter extends TypeAdapter<AppNote> {
  @override
  final int typeId = 11;

  @override
  AppNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppNote(
      id: fields[0] as String,
      title: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AppNote obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
