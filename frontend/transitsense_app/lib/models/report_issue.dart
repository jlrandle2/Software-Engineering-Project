class ReportIssue {
  final String id;
  final String userId;
  final String description;
  final String location;
  final DateTime createdAt;

  ReportIssue({
    required this.id,
    required this.userId,
    required this.description,
    required this.location,
    required this.createdAt,
  });

  factory ReportIssue.fromJson(Map<String, dynamic> json) {
    return ReportIssue(
      id: json['id'],
      userId: json['userId'],
      description: json['description'],
      location: json['location'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'location': location,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}