class TransitStop {
  final String id;
  final String name;
  final double latitude;
  final double longitude;

  TransitStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory TransitStop.fromJson(Map<String, dynamic> json) {
    return TransitStop(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}