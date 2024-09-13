class StudentComplex {
  final String id;
  final String name;
  final double rating;
  final String address;

  StudentComplex({
    required this.id,
    required this.name,
    required this.rating,
    required this.address,
  });

  // Factory method to create a StudentComplex object from JSON
  factory StudentComplex.fromJson(Map<String, dynamic> json) {
    return StudentComplex(
      id: json['id'],
      name: json['name'],
      rating: json['rating'].toDouble(),
      address: json['address'],
    );
  }

  // Method to convert StudentComplex object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rating': rating,
      'address': address,
    };
  }

  // Method to update a StudentComplex object
  StudentComplex copyWith({
    String? id,
    String? name,
    double? rating,
    String? address,
  }) {
    return StudentComplex(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      address: address ?? this.address,
    );
  }
}
