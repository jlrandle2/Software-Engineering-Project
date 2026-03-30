import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://localhost:8000";

  // =========================
  // GET ALERTS
  // =========================
  static Future<List<dynamic>> getAlerts([int? stationId]) async {
    String url = '$baseUrl/alerts';

    if (stationId != null) {
      url += '?station_id=$stationId';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load alerts');
    }
  }

  // =========================
  // CREATE ALERT (UPDATED)
  // =========================
  static Future<void> createAlert({
    required int stationId,
    required String routeName,
    required String direction,
    required String alertType,
    required String description,
    required bool isOfficial,
    required int reportedBy,

  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alerts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "station_id": stationId,
        "route_name": routeName,
        "direction": direction,
        "alert_type": alertType,
        "description": description,
        "is_official": isOfficial,
        "reported_by": reportedBy,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      print("CREATE ALERT ERROR: ${response.statusCode}");
      print(response.body);
      throw Exception('Failed to create alert');
    }
  }

  // =========================
  // DELETE ALERT (NEW)
  // =========================
  static Future<void> deleteAlert(int alertId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/alerts/$alertId'),
    );

    if (response.statusCode != 200) {
      print("DELETE ERROR: ${response.statusCode}");
      print(response.body);
      throw Exception('Failed to delete alert');
    }
  }

  // =========================
  // GET STATIONS
  // =========================
  static Future<List<dynamic>> getStations() async {
    final response = await http.get(Uri.parse('$baseUrl/stations'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load stations');
    }
  }

  // =========================
  // GET STATIONS FOR LINE
  // =========================
  static Future<List<dynamic>> getStationsForLine(String line) async {
    final res = await http.get(Uri.parse('$baseUrl/lines/$line/stations'));
    return jsonDecode(res.body);
  }

  // =========================
  // GET DIRECTIONS
  // =========================
  static Future<List<dynamic>> getDirections(String line, int stationId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/lines/$line/stations/$stationId/directions'),
    );
    return jsonDecode(res.body);
  }


  // =========================
  // CREATE USER
  // =========================
  static Future<Map<String, dynamic>?> createUser(String username, String email, String role, String password) async {
  final response = await http.post(
    Uri.parse("$baseUrl/users"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "username": username,
      "email": email,
      "password": password, 
      "role": role,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return jsonDecode(response.body);
  } else {
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    throw Exception("Create user failed");
  }
}


// GET SAVED USER ID

  static Future<int?> getSavedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("user_id");
  }

  // LOGIN 

  static Future<Map<String, dynamic>?> login(
  String username,
  String password,
) async {
  final response = await http.post(
    Uri.parse("$baseUrl/login"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      "username": username,
      "password": password,
    }),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    print("LOGIN ERROR: ${response.body}");
    return null;
  }


  
}
}