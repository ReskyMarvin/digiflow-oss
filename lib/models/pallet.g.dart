// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PalletAdapter extends TypeAdapter<Pallet> {
  @override
  final int typeId = 0;

  @override
  Pallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Pallet(
      batch: fields[0] as String,
      palletNo: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Pallet obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.batch)
      ..writeByte(1)
      ..write(obj.palletNo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
