class TransitRoute {
  final String id;
  final String name;
  final String startStop;
  final String endStop;
  final List<String> stops;

  TransitRoute({
    required this.id,
    required this.name,
    required this.startStop,
    required this.endStop,
    required this.stops,
  });

  factory TransitRoute.fromJson(Map<String, dynamic> json) {
    return TransitRoute(
      id: json['id'],
      name: json['name'],
      startStop: json['startStop'],
      endStop: json['endStop'],
      stops: List<String>.from(json['stops']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startStop': startStop,
      'endStop': endStop,
      'stops': stops,
    };
  }
}