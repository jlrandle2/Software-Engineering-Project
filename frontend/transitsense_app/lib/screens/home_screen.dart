// SAME IMPORTS (unchanged)
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'route_search_screen.dart';
import 'transit_map_screen.dart';
import 'settings_screen.dart';
import 'report_issue_screen.dart';
import '../services/transit_service.dart';
import '../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool isAdmin = false;

  List<dynamic> alerts = [];
  bool isLoadingAlerts = true;
  bool showAlerts = true;

  List<dynamic> stations = [];
  List<dynamic> filteredStations = [];

  int? selectedStationId;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStations();
  }

  void fetchStations() async {
    try {
      final data = await ApiService.getStations();

      setState(() {
        stations = data;
        filteredStations = data;
      });

      fetchAlerts();

    } catch (e) {
      print("STATION ERROR: $e");
    }
  }

  void fetchAlerts() async {
    try {
      setState(() => isLoadingAlerts = true);

      final data = await ApiService.getAlerts(selectedStationId);

      setState(() {
        alerts = data;
        isLoadingAlerts = false;
      });

    } catch (e) {
      print("ALERT ERROR: $e");
      setState(() => isLoadingAlerts = false);
    }
  }

  void filterStations(String query) {
    setState(() {
      filteredStations = stations.where((station) {
        return station['station_name']
            .toLowerCase()
            .contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        title: const Text("TransitSense"),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                "Home",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 16),

              // MODE TOGGLE
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Mode:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Text("Rider"),
                      Switch(
                        value: isAdmin,
                        onChanged: (val) {
                          setState(() {
                            isAdmin = val;
                          });
                        },
                      ),
                      const Text("Admin"),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // SEARCH
              TextField(
                controller: searchController,
                onChanged: (value) {
                  filterStations(value);

                  if (value.isEmpty) {
                    selectedStationId = null;
                    fetchAlerts();
                  }
                },
                decoration: InputDecoration(
                  hintText: "Search station",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              if (filteredStations.isNotEmpty && searchController.text.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filteredStations.length,
                    itemBuilder: (context, index) {

                      final station = filteredStations[index];

                      return ListTile(
                        title: Text(station['station_name']),
                        onTap: () {
                          setState(() {
                            selectedStationId = station['station_id'];
                            searchController.text = station['station_name'];
                            filteredStations = [];
                          });

                          fetchAlerts();
                        },
                      );
                    },
                  ),
                ),

              const SizedBox(height: 16),

              // ALERT HEADER
              GestureDetector(
                onTap: () => setState(() => showAlerts = !showAlerts),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Live Alerts",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Icon(showAlerts ? Icons.expand_less : Icons.expand_more),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // ALERTS
              if (showAlerts)
                isLoadingAlerts
                    ? const CircularProgressIndicator()
                    : alerts.isEmpty
                        ? const Text("No alerts right now")
                        : Column(
                            children: alerts.map((alert) {

                              final isOfficial = alert['is_official'] == true;

                              return Card(
                                color: isOfficial ? Colors.blue[50] : Colors.red[50],

                                child: ListTile(

                                  leading: Icon(
                                    isOfficial ? Icons.verified : Icons.warning,
                                    color: isOfficial ? Colors.blue : Colors.red,
                                  ),

                                  trailing: isAdmin
                                      ? IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () async {
                                            await ApiService.deleteAlert(alert['alert_id']);
                                            fetchAlerts();
                                          },
                                        )
                                      : null,

                                  title: Text(alert['alert_type'] ?? "Alert"),

                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      if (isOfficial)
                                        const Text(
                                          "Official Alert",
                                          style: TextStyle(fontSize: 11, color: Colors.blue),
                                        ),

                                      Text(alert['description'] ?? "No description"),

                                      if (alert['station_name'] != null)
                                        Text("📍 ${alert['station_name']}"),

                                      if (alert['route_name'] != null &&
                                          alert['direction'] != null)
                                        Text(
                                          "🚆 ${alert['route_name']} • ${formatDirection(alert['direction'])}",
                                        ),

                                      if (alert['created_at'] != null)
                                        Text(
                                          formatTime(alert['created_at']),
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                    ],
                                  ),
                                ),
                              );

                            }).toList(),
                          ),

              const SizedBox(height: 24),

              const Text(
                "Map",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransitMapScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text("Map Preview\nTap to open map"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomSheet: _buildCTA(),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () async {
          try {
            await TransitService.startTrip(
              route: "Red Line",
              startStation: "North Ave",
              destination: "Midtown",
            );

            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RouteSearchScreen()),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error starting trip")),
            );
          }
        },
        child: const Text("Plan Route"),
      ),
    );
  }

  Widget _buildNavBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.primaryBlue,
      type: BottomNavigationBarType.fixed,
      onTap: (index) async {

        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const TransitMapScreen()));
        }

        if (index == 2) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ReportIssueScreen(isAdmin: isAdmin),
            ),
          );
          fetchAlerts();
        }

        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SettingsScreen(
                toggleTheme: widget.toggleTheme,
                isDarkMode: widget.isDarkMode,
              ),
            ),
          );
        }
      },

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
        BottomNavigationBarItem(icon: Icon(Icons.report), label: "Report"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
      ],
    );
  }

  String formatDirection(String dir) {
    return dir[0].toUpperCase() + dir.substring(1);
  }

  String formatTime(String timestamp) {
    final dateTime = DateTime.parse(timestamp).toLocal();
    final diff = DateTime.now().difference(dateTime);

    if (diff.inMinutes < 1) return "just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hr ago";

    return "${dateTime.month}/${dateTime.day}";
  }
}