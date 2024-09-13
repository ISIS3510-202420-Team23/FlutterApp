class Property {
  String id;
  String name;
  String address;
  String studentComplexId;
  double price;
  String offerType; // e.g., "entire_place"
  String description;
  int bedrooms;
  int bathrooms;
  double rating;
  bool available;
  String dateAdded; // Format: "dd-mm-yyyy"

  // Constructor
  Property({
    required this.id,
    required this.name,
    required this.address,
    required this.studentComplexId,
    required this.price,
    required this.offerType,
    required this.description,
    required this.bedrooms,
    required this.bathrooms,
    required this.rating,
    required this.available,
    required this.dateAdded,
  });

  // Factory method to create a Property object from Firebase data (JSON)
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      studentComplexId: json['studentComplexId'] as String,
      price: json['price'] as double,
      offerType: json['offerType'] as String,
      description: json['description'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      rating: json['rating'] as double,
      available: json['available'] as bool,
      dateAdded: json['dateAdded'] as String,
    );
  }

  // Method to convert a Property object to JSON format for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'studentComplexId': studentComplexId,
      'price': price,
      'offerType': offerType,
      'description': description,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'rating': rating,
      'available': available,
      'dateAdded': dateAdded,
    };
  }

  @override
  String toString() {
    return 'Property{id: $id, name: $name, address: $address, studentComplexId: $studentComplexId, price: $price, offerType: $offerType, description: $description, bedrooms: $bedrooms, bathrooms: $bathrooms, rating: $rating, available: $available, dateAdded: $dateAdded}';
  }
}
