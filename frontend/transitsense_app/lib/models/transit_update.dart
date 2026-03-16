class TransitUpdate {
  final String id;
  final String routeId;
  final String message;
  final DateTime timestamp;

  TransitUpdate({
    required this.id,
    required this.routeId,
    required this.message,
    required this.timestamp,
  });

  factory TransitUpdate.fromJson(Map<String, dynamic> json) {
    return TransitUpdate(
      id: json['id'],
      routeId: json['routeId'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeId': routeId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}