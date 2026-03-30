import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportIssueScreen extends StatefulWidget {
  final bool isAdmin;

  const ReportIssueScreen({
    super.key,
    required this.isAdmin,
  });

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  // =========================
  // STATE
  // =========================

  // Selected line
  String? selectedLine;

  // Stations for the selected line
  List<dynamic> stations = [];
  int? selectedStationId;
  bool isLoadingStations = false;

  // Directions for the selected line + station
  List<String> directions = [];
  String? selectedDirection;
  bool isLoadingDirections = false;

  // Issue type
  String selectedIssue = "Delay";

  final List<String> issueTypes = [
    "Delay",
    "Broken Bus Stop",
    "Safety Concern",
    "Accessibility Issue",
    "Other",
  ];

  // Description input
  final TextEditingController descriptionController = TextEditingController();

  // =========================
  // HELPERS
  // =========================

  List<String> getAllLines() {
    return ["Red Line", "Gold Line", "Blue Line", "Green Line"];
  }

  String formatDirection(String dir) {
    if (dir.isEmpty) return dir;
    return dir[0].toUpperCase() + dir.substring(1);
  }

  // =========================
  // FETCH STATIONS FOR LINE
  // =========================

  void fetchStationsForLine(String line) async {
    try {
      setState(() {
        isLoadingStations = true;
        stations = [];
        selectedStationId = null;
        directions = [];
        selectedDirection = null;
      });

      final data = await ApiService.getStationsForLine(line);

      setState(() {
        stations = data;
        isLoadingStations = false;
      });
    } catch (e) {
      print("STATION ERROR: $e");
      setState(() {
        isLoadingStations = false;
      });
    }
  }

  // =========================
  // FETCH DIRECTIONS
  // =========================

  void fetchDirections(String line, int stationId) async {
    try {
      setState(() {
        isLoadingDirections = true;
        directions = [];
        selectedDirection = null;
      });

      final data = await ApiService.getDirections(line, stationId);

      setState(() {
        directions = List<String>.from(data);
        isLoadingDirections = false;
      });
    } catch (e) {
      print("DIRECTION ERROR: $e");
      setState(() {
        isLoadingDirections = false;
      });
    }
  }

  // =========================
  // SUBMIT
  // =========================

  void submitReport() async {
    if (selectedLine == null ||
        selectedStationId == null ||
        selectedDirection == null ||
        descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    try {
      await ApiService.createAlert(
        stationId: selectedStationId!,
        routeName: selectedLine!,
        direction: selectedDirection!,
        alertType: selectedIssue,
        description: descriptionController.text.trim(),
        isOfficial: widget.isAdmin,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Issue reported successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("SUBMIT ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error submitting report")),
      );
    }
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAdmin ? "Admin Report Issue" : "Report Issue"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isAdmin
                  ? "Create an Official Alert"
                  : "Report a Transit Issue",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ISSUE TYPE
            const Text(
              "Issue Type",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedIssue,
              items: issueTypes.map((issue) {
                return DropdownMenuItem<String>(
                  value: issue,
                  child: Text(issue),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  selectedIssue = value;
                });
              },
              decoration: _inputDecoration(),
            ),

            const SizedBox(height: 20),

            // LINE
            const Text(
              "Line",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              value: selectedLine,
              hint: const Text("Select a line"),
              items: getAllLines().map((line) {
                return DropdownMenuItem<String>(
                  value: line,
                  child: Text(line),
                );
              }).toList(),
              onChanged: (line) {
                if (line == null) return;

                setState(() {
                  selectedLine = line;
                });

                fetchStationsForLine(line);
              },
              decoration: _inputDecoration(),
            ),

            const SizedBox(height: 20),

            // STATION
            const Text(
              "Station",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            isLoadingStations
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<int>(
                    value: selectedStationId,
                    hint: const Text("Select a station"),
                    items: stations.map<DropdownMenuItem<int>>((station) {
                      return DropdownMenuItem<int>(
                        value: station['station_id'],
                        child: Text(station['station_name']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null || selectedLine == null) return;

                      setState(() {
                        selectedStationId = value;
                      });

                      fetchDirections(selectedLine!, value);
                    },
                    decoration: _inputDecoration(),
                  ),

            const SizedBox(height: 20),

            // DIRECTION
            const Text(
              "Direction",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            isLoadingDirections
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<String>(
                    value: selectedDirection,
                    hint: const Text("Select direction"),
                    items: directions.map((dir) {
                      return DropdownMenuItem<String>(
                        value: dir,
                        child: Text(formatDirection(dir)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        selectedDirection = value;
                      });
                    },
                    decoration: _inputDecoration(),
                  ),

            const SizedBox(height: 28),

            // DESCRIPTION
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: _inputDecoration(
                hint: widget.isAdmin
                    ? "Describe the official alert..."
                    : "Describe the issue...",
              ),
            ),

            const SizedBox(height: 30),

            // SUBMIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitReport,
                child: Text(
                  widget.isAdmin ? "Create Official Alert" : "Submit Report",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // INPUT STYLING
  // =========================

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}