// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer_property.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfferPropertyAdapter extends TypeAdapter<OfferProperty> {
  @override
  final int typeId = 2;

  @override
  OfferProperty read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfferProperty(
      offer: fields[0] as Offer,
      property: fields[1] as Property,
    );
  }

  @override
  void write(BinaryWriter writer, OfferProperty obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.offer)
      ..writeByte(1)
      ..write(obj.property);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfferPropertyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
