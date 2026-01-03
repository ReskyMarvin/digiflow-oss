// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checking_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheckingListAdapter extends TypeAdapter<CheckingList> {
  @override
  final int typeId = 1;

  @override
  CheckingList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckingList(
      name: fields[0] as String,
      pallets: (fields[1] as List).cast<Pallet>(),
      id: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CheckingList obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.pallets)
      ..writeByte(2)
      ..write(obj.id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckingListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
