class Offer {
  final String finalDate;
  final String userId;
  final int propertyId;
  final String initialDate;
  final bool isActive;
  final int numBaths;
  final int numBeds;
  final int numRooms;
  final bool onlyAndes;
  final int pricePerMonth;
  final int roommates;
  final String type;

  Offer({
    required this.finalDate,
    required this.userId,
    required this.propertyId,
    required this.initialDate,
    required this.isActive,
    required this.numBaths,
    required this.numBeds,
    required this.numRooms,
    required this.onlyAndes,
    required this.pricePerMonth,
    required this.roommates,
    required this.type,
  });

  // Factory method to create an Offer object from JSON
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      finalDate: json['final_date'],
      userId: json['user_id'],
      propertyId: json['id_property'],
      initialDate: json['initial_date'],
      isActive: json['is_active'],
      numBaths: json['num_baths'],
      numBeds: json['num_beds'],
      numRooms: json['num_rooms'],
      onlyAndes: json['only_andes'],
      pricePerMonth: json['price_per_month'],
      roommates: json['roommates'],
      type: json['type'],
    );
  }

  // Method to convert Offer object to JSON
  Map<String, dynamic> toJson() {
    return {
      'final_date': finalDate,
      'user_id': userId,
      'id_property': propertyId,
      'initial_date': initialDate,
      'is_active': isActive,
      'num_baths': numBaths,
      'num_beds': numBeds,
      'num_rooms': numRooms,
      'only_andes': onlyAndes,
      'price_per_month': pricePerMonth,
      'roommates': roommates,
      'type': type,
    };
  }

  // Method to update an Offer object
  Offer copyWith({
    String? finalDate,
    String? userId,
    int? propertyId,
    String? initialDate,
    bool? isActive,
    int? numBaths,
    int? numBeds,
    int? numRooms,
    bool? onlyAndes,
    int? pricePerMonth,
    int? roommates,
    String? type,
  }) {
    return Offer(
      finalDate: finalDate ?? this.finalDate,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      initialDate: initialDate ?? this.initialDate,
      isActive: isActive ?? this.isActive,
      numBaths: numBaths ?? this.numBaths,
      numBeds: numBeds ?? this.numBeds,
      numRooms: numRooms ?? this.numRooms,
      onlyAndes: onlyAndes ?? this.onlyAndes,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      roommates: roommates ?? this.roommates,
      type: type ?? this.type,
    );
  }
}
