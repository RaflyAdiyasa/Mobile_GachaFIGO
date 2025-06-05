// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GachaCardAdapter extends TypeAdapter<GachaCard> {
  @override
  final int typeId = 1;

  @override
  GachaCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GachaCard(
      id: fields[0] as String,
      urlImg: fields[1] as String,
      rarity: fields[2] as int,
      name: fields[3] as String,
      coordinates: fields[4] as String,
      time: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, GachaCard obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.urlImg)
      ..writeByte(2)
      ..write(obj.rarity)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.coordinates)
      ..writeByte(5)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GachaCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
