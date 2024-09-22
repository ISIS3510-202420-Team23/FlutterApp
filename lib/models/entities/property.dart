class Property {
  String id;
  String address;
  String complex_name;
  String description;
  String location;
  List<String> photos;
  String title;

  // Constructor
  Property({
    required this.id,
    required this.address,
    required this.complex_name,
    required this.description,
    required this.location,
    required this.photos,
    required this.title,
  });

  // Factory method to create a Property object from Firebase data (JSON)
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      address: json['address'] as String,
      description: json['description'] as String,
      complex_name: json['complex_name'] as String,
      location: json['location'] as String,
      photos: List<String>.from(json['photos'] as List<dynamic>),
      title: json['title'] as String,
    );
  }

  // Method to convert a Property object to JSON format for Firebase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'description': description,
      'complex_name': complex_name,
      'location': location,
      'photos': photos,
      'title': title,
    };
  }

  @override
  String toString() {
    return 'Property{id: $id, address: $address, complex_name: $complex_name, description: $description, location: $location, photos: $photos, title: $title}';
  }
}
