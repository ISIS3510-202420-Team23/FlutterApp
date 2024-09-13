class User {
  final String email;
  final bool isAndes;
  final String name;
  final int phone;
  final String typeUser;
  final List<int>? favoriteOffers;

  User({
    required this.email,
    required this.isAndes,
    required this.name,
    required this.phone,
    required this.typeUser,
    this.favoriteOffers,
  });

  // Factory method to create a User object from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      isAndes: json['is_andes'],
      name: json['name'],
      phone: json['phone'],
      typeUser: json['type_user'],
      favoriteOffers: json['favorite_offers'] != null
          ? List<int>.from(json['favorite_offers'])
          : null,
    );
  }

  // Method to convert User object to JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'is_andes': isAndes,
      'name': name,
      'phone': phone,
      'type_user': typeUser,
      'favorite_offers': favoriteOffers,
    };
  }

  // Method to update a User object
  User copyWith({
    String? email,
    bool? isAndes,
    String? name,
    int? phone,
    String? typeUser,
    List<int>? favoriteOffers,
  }) {
    return User(
      email: email ?? this.email,
      isAndes: isAndes ?? this.isAndes,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      typeUser: typeUser ?? this.typeUser,
      favoriteOffers: favoriteOffers ?? this.favoriteOffers,
    );
  }
}
