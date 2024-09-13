class UserAction {
  final String action;
  final String user_id;
  final int property_id;
  final DateTime timestamp;

  UserAction({
    required this.action,
    required this.user_id,
    required this.property_id,
    required this.timestamp,
  });

  // Factory method to create a UserAction object from JSON
  factory UserAction.fromJson(Map<String, dynamic> json) {
    return UserAction(
      action: json['action'],
      user_id: json['user_id'],
      property_id: json['property_id'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Method to convert UserAction object to JSON
  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'user_id': user_id,
      'property_id': property_id,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Method to update a UserAction object
  UserAction copyWith({
    String? action,
    String? userId,
    int? propertyId,
    DateTime? timestamp,
  }) {
    return UserAction(
      action: action ?? this.action,
      user_id: userId ?? user_id,
      property_id: propertyId ?? property_id,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
