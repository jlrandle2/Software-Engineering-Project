import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {

  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  List<dynamic> stations = [];
  int? selectedStationId;
  bool isLoadingStations = true;
  @override
  void initState() {
    super.initState();
    fetchStations();
  }
  void fetchStations() async {
    try {
      var data = await ApiService.getStations();
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

  String selectedIssue = "Delay";

  final List<String> issueTypes = [
    "Delay",
    "Broken Bus Stop",
    "Safety Concern",
    "Accessibility Issue",
    "Other"
  ];

  void submitReport() async {

  if (selectedStationId == null ||
    descriptionController.text.isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  try {

    await ApiService.createAlert(
      stationId: 1, // TEMP — we’ll fix this next
      alertType: selectedIssue,
      description: descriptionController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Issue reported successfully")),
    );

    Navigator.pop(context); // go back to home

  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Error submitting report")),
    );
  }
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Report Issue"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Report a Transit Issue",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            /// ISSUE TYPE
            const Text(
              "Issue Type",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField(
              value: selectedIssue,
              items: issueTypes.map((issue) {
                return DropdownMenuItem(
                  value: issue,
                  child: Text(issue),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedIssue = value!;
                });
              },

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// LOCATION
            const Text(
              "Location",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            isLoadingStations
              ? const CircularProgressIndicator()
              : DropdownButtonFormField<int>(
                  value: selectedStationId,
                  hint: const Text("Select a station"),
                  items: stations.map((station) {
                    return DropdownMenuItem<int>(
                      value: station['station_id'],
                      child: Text(station['station_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStationId = value!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

            const SizedBox(height: 20),

            /// DESCRIPTION
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe the issue...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// SUBMIT BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: submitReport,

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                child: const Text(
                  "Submit Report",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}