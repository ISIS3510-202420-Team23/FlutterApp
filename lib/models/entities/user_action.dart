import 'package:cloud_firestore/cloud_firestore.dart';

class UserAction {
  final String action;
  final int property_id;
  final Timestamp timestamp;

  UserAction({
    required this.action,
    required this.property_id,
    required this.timestamp,
  });

  // Factory method to create a UserAction object from JSON
  factory UserAction.fromJson(Map<String, dynamic> json) {
    return UserAction(
      action: json['action'],
      property_id: json['property_id'],
      timestamp: json['timestamp'],
    );
  }

  // Method to convert UserAction object to JSON
  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'property_id': property_id,
      'timestamp': timestamp.toDate(),
    };
  }

  // Method to update a UserAction object
  UserAction copyWith({
    String? action,
    int? propertyId,
    Timestamp? timestamp,
  }) {
    return UserAction(
      action: action ?? this.action,
      property_id: propertyId ?? property_id,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
