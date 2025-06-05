// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topup_bundle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TopUpBundleAdapter extends TypeAdapter<TopUpBundle> {
  @override
  final int typeId = 2;

  @override
  TopUpBundle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TopUpBundle(
      id: fields[0] as String,
      credits: fields[1] as int,
      usdPrice: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, TopUpBundle obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.credits)
      ..writeByte(2)
      ..write(obj.usdPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TopUpBundleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
