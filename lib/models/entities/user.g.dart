// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 5;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      email: fields[0] as String,
      is_andes: fields[1] as bool,
      name: fields[2] as String,
      phone: fields[3] as int,
      photo: fields[5] as String,
      type_user: fields[4] as String,
      favorite_offers: (fields[6] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.is_andes)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.phone)
      ..writeByte(4)
      ..write(obj.type_user)
      ..writeByte(5)
      ..write(obj.photo)
      ..writeByte(6)
      ..write(obj.favorite_offers);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
