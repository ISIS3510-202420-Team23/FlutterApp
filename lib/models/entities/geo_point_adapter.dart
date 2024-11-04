import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeoPointAdapter extends TypeAdapter<GeoPoint> {
  @override
  final int typeId = 3; // Unique type ID for GeoPoint

  @override
  GeoPoint read(BinaryReader reader) {
    final double latitude = reader.readDouble();
    final double longitude = reader.readDouble();
    return GeoPoint(latitude, longitude);
  }

  @override
  void write(BinaryWriter writer, GeoPoint obj) {
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
  }
}
