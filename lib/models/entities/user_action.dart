class UserAction {
  final String action;
  final String userId;
  final int propertyId;
  final DateTime timestamp;

  UserAction({
    required this.action,
    required this.userId,
    required this.propertyId,
    required this.timestamp,
  });

  // Factory method to create a UserAction object from JSON
  factory UserAction.fromJson(Map<String, dynamic> json) {
    return UserAction(
      action: json['action'],
      userId: json['user_id'],
      propertyId: json['property_id'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // Method to convert UserAction object to JSON
  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'user_id': userId,
      'property_id': propertyId,
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
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
