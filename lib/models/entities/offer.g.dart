// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfferAdapter extends TypeAdapter<Offer> {
  @override
  final int typeId = 1;

  @override
  Offer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Offer(
      final_date: fields[0] as DateTime,
      user_id: fields[1] as String,
      property_id: fields[2] as int,
      initial_date: fields[3] as DateTime,
      is_active: fields[4] as bool,
      num_baths: fields[5] as int,
      num_beds: fields[6] as int,
      num_rooms: fields[7] as int,
      only_andes: fields[8] as bool,
      price_per_month: fields[9] as double,
      roommates: fields[10] as int,
      type: fields[11] as String,
      offerId: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Offer obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.final_date)
      ..writeByte(1)
      ..write(obj.user_id)
      ..writeByte(2)
      ..write(obj.property_id)
      ..writeByte(3)
      ..write(obj.initial_date)
      ..writeByte(4)
      ..write(obj.is_active)
      ..writeByte(5)
      ..write(obj.num_baths)
      ..writeByte(6)
      ..write(obj.num_beds)
      ..writeByte(7)
      ..write(obj.num_rooms)
      ..writeByte(8)
      ..write(obj.only_andes)
      ..writeByte(9)
      ..write(obj.price_per_month)
      ..writeByte(10)
      ..write(obj.roommates)
      ..writeByte(11)
      ..write(obj.type)
      ..writeByte(12)
      ..write(obj.offerId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfferAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
