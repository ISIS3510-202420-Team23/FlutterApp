import 'package:hive/hive.dart';

part 'offer.g.dart';

@HiveType(typeId: 1)
class Offer {
  @HiveField(0)
  final DateTime final_date;

  @HiveField(1)
  final String user_id;

  @HiveField(2)
  final int property_id;

  @HiveField(3)
  final DateTime initial_date;

  @HiveField(4)
  final bool is_active;

  @HiveField(5)
  final int num_baths;

  @HiveField(6)
  final int num_beds;

  @HiveField(7)
  final int num_rooms;

  @HiveField(8)
  final bool only_andes;

  @HiveField(9)
  final double price_per_month;

  @HiveField(10)
  final int roommates;

  @HiveField(11)
  final String type;

  @HiveField(12)
  final int offerId;

  Offer({
    required this.final_date,
    required this.user_id,
    required this.property_id,
    required this.initial_date,
    required this.is_active,
    required this.num_baths,
    required this.num_beds,
    required this.num_rooms,
    required this.only_andes,
    required this.price_per_month,
    required this.roommates,
    required this.type,
    required this.offerId,
  });

  // Factory method to create an Offer object from JSON
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      final_date: json['final_date'],
      user_id: json['user_id'],
      property_id: json['id_property'],
      initial_date: json['initial_date'],
      is_active: json['is_active'],
      num_baths: json['num_baths'],
      num_beds: json['num_beds'],
      num_rooms: json['num_rooms'],
      only_andes: json['only_andes'],
      price_per_month: json['price_per_month'],
      roommates: json['roommates'],
      type: json['type'],
      offerId: json['offerId'],
    );
  }

  // Method to convert Offer object to JSON
  Map<String, dynamic> toJson() {
    return {
      'final_date': final_date,
      'user_id': user_id,
      'id_property': property_id,
      'initial_date': initial_date,
      'is_active': is_active,
      'num_baths': num_baths,
      'num_beds': num_beds,
      'num_rooms': num_rooms,
      'only_andes': only_andes,
      'price_per_month': price_per_month,
      'roommates': roommates,
      'type': type,
      'offerId': offerId,
    };
  }

  // Method to update an Offer object
  Offer copyWith({
    DateTime? finalDate,
    String? userId,
    int? propertyId,
    DateTime? initialDate,
    bool? isActive,
    int? numBaths,
    int? numBeds,
    int? numRooms,
    bool? onlyAndes,
    double? pricePerMonth,
    int? roommates,
    String? type,
    int? offerId,
  }) {
    return Offer(
      final_date: finalDate ?? final_date,
      user_id: userId ?? user_id,
      property_id: propertyId ?? property_id,
      initial_date: initialDate ?? initial_date,
      is_active: isActive ?? is_active,
      num_baths: numBaths ?? num_baths,
      num_beds: numBeds ?? num_beds,
      num_rooms: numRooms ?? num_rooms,
      only_andes: onlyAndes ?? only_andes,
      price_per_month: pricePerMonth ?? price_per_month,
      roommates: roommates ?? this.roommates,
      type: type ?? this.type,
      offerId: offerId ?? this.offerId,
    );
  }
}
