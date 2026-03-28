import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {

  static const String baseUrl = "http://localhost:8000";

  static Future<List<dynamic>> getAlerts(int stationId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alerts?station_id=$stationId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load alerts');
    }
  }

  static Future<void> createAlert({
    required int stationId,
    required String alertType,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alerts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "station_id": stationId,
        "alert_type": alertType,
        "description": description,
        "reported_by": null,
        "is_active": true
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to create alert');
    }
  }

  static Future<List<dynamic>> getStations() async {
  final response = await http.get(Uri.parse('$baseUrl/stations'));

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load stations');
  }
}

  static Future<void> updatePreferredStation(int stationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/1'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "preferred_station_id": stationId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update preferred station');
    }
  }

}