import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 5)
class User {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final bool is_andes;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final int phone;

  @HiveField(4)
  final String type_user;

  @HiveField(5)
  final String photo;

  @HiveField(6)
  final List<int>? favorite_offers;

  User({
    required this.email,
    required this.is_andes,
    required this.name,
    required this.phone,
    required this.photo,
    required this.type_user,
    this.favorite_offers,
  });

  // Factory method to create a User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      is_andes: json['is_andes'],
      name: json['name'],
      phone: json['phone'],
      photo: json['photo'],
      type_user: json['type_user'],
      favorite_offers: json['favorite_offers'] != null
          ? List<int>.from(json['favorite_offers'])
          : null,
    );
  }

  // Method to convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'is_andes': is_andes,
      'name': name,
      'phone': phone,
      'photo': photo,
      'type_user': type_user,
      'favorite_offers': favorite_offers,
    };
  }

  // Method to update a User object
  User copyWith({
    String? email,
    bool? isAndes,
    String? name,
    int? phone,
    String? photo,
    String? typeUser,
    List<int>? favoriteOffers,
  }) {
    return User(
      email: email ?? this.email,
      is_andes: isAndes ?? is_andes,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      type_user: typeUser ?? type_user,
      favorite_offers: favoriteOffers ?? favorite_offers,
    );
  }
}
