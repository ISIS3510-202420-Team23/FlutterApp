import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'property.g.dart';

@HiveType(typeId: 0)
class Property {
  @HiveField(0)
  int id;

  @HiveField(1)
  String address;

  @HiveField(2)
  String complex_name;

  @HiveField(3)
  String? description;

  @HiveField(4)
  GeoPoint location;

  @HiveField(5)
  List<String> photos;

  @HiveField(6)
  String title;

  @HiveField(7)
  double minutesFromCampus;

  // Constructor
  Property({
    required this.id,
    required this.address,
    required this.complex_name,
    required this.description,
    required this.location,
    required this.photos,
    required this.title,
    required this.minutesFromCampus,
  });

  // Factory method to create a Property object from Firebase data (JSON)
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int,
      address: json['address'] as String,
      description: json['description'] as String,
      complex_name: json['complex_name'] as String,
      location: json['location'] as GeoPoint, // Change to GeoPoint
      photos: List<String>.from(json['photos'] as List<dynamic>),
      title: json['title'] as String,
      minutesFromCampus: json['minutes_from_campus'] as double,
    );
  }

  // Method to convert a Property object to JSON format for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'description': description,
      'complex_name': complex_name,
      'location': location, // Change to GeoPoint
      'photos': photos,
      'title': title,
      'minutes_from_campus': minutesFromCampus,
    };
  }

  @override
  String toString() {
    return 'Property{id: $id, address: $address, complex_name: $complex_name, description: $description, location: $location, photos: $photos, title: $title, minutesFromCampus: $minutesFromCampus}';
  }

  // Getter method to return the location as a GeoPoint object
  GeoPoint getLocation() {
    return location;
  }
}
