import 'dart:convert';
import 'package:http/http.dart' as http;

class TransitService {

  static const String baseUrl = "http://10.0.2.2:5000";

  static Future<void> startTrip({
    required String route,
    required String startStation,
    required String destination,
  }) async {

    final response = await http.post(
      Uri.parse("$baseUrl/trackTrip"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "route": route,
        "start_station": startStation,
        "destination": destination,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Failed to start trip");
    }
  }
}