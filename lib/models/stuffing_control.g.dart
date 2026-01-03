// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stuffing_control.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StuffingControlAdapter extends TypeAdapter<StuffingControl> {
  @override
  final int typeId = 2;

  @override
  StuffingControl read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StuffingControl(
      checkingListId: fields[0] as String,
      stuffedPallets: (fields[1] as List?)?.cast<Pallet>(),
    );
  }

  @override
  void write(BinaryWriter writer, StuffingControl obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.checkingListId)
      ..writeByte(1)
      ..write(obj.stuffedPallets);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StuffingControlAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
