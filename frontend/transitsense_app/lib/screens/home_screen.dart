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

List<dynamic> alerts = [];
bool isLoadingAlerts = true;
bool showAlerts = true;

List<dynamic> stations = [];
int? selectedStationId;
bool isLoadingStations = true;

TextEditingController searchController = TextEditingController();
List<dynamic> filteredStations = [];

@override
void initState() {
  super.initState();
  fetchStations();
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

void fetchAlerts() async {
  try {
    if (selectedStationId == null) return;

    var data = await ApiService.getAlerts(selectedStationId!);
    print("ALERTS: $data"); // 👈 ADD THIS

    setState(() {
      alerts = data;
      isLoadingAlerts = false;
    });
  } catch (e) {
    print("ALERT ERROR: $e");
    setState(() {
      isLoadingAlerts = false;
    });
  }
}

void fetchStations() async {
  try {
    var data = await ApiService.getStations();
    setState(() {
      stations = data;
      filteredStations = stations;
      isLoadingStations = false;

      // set default if not selected yet
      if (selectedStationId == null && stations.isNotEmpty) {
        selectedStationId = stations[0]['station_id'];
      }
    });
  } catch (e) {
    print("STATION ERROR: $e");
    setState(() {
      isLoadingStations = false;
    });
  }
}


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: AppColors.primaryBlue,
      title: const Text("TransitSense"),
      actions: const [
        Icon(Icons.person),
        SizedBox(width: 12),
      ],
    ),


    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Home",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(height: 12),


            /// STATION SEARCH
            TextField(
              controller: searchController,
              onChanged: filterStations,
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

            /// SEARCH RESULTS
            if (searchController.text.isNotEmpty)
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

            GestureDetector(
                  onTap: () {
                    setState(() {
                      showAlerts = !showAlerts;
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Live Alerts",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        showAlerts ? Icons.expand_less : Icons.expand_more,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        if (showAlerts)
          isLoadingAlerts
            ? const CircularProgressIndicator()
            : alerts.isEmpty
                ? const Text("No alerts right now")
                : Column(
                    children: alerts.map((alert) {
                      return Card(
                        color: Colors.red[50],
                        child: ListTile(
                          leading: const Icon(Icons.warning, color: Colors.red),
                          title: Text(alert['alert_type']),
                          subtitle: Text(alert['description'] ?? "No description"),
                        ),
                      );
                    }).toList(),
                  ),

          const SizedBox(height: 24),

            const Text(
              "Map",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),


            const SizedBox(height: 10),


            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransitMapScreen(),
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
                  child: Text(
                    "Map Preview\nTap to open map",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),


    /// STICKY CTA BUTTON
    bottomSheet: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
          )
        ],
      ),


      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          try {


            await TransitService.startTrip(
              route: "Red Line",
              startStation: "North Ave",
              destination: "Midtown",
            );


            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Trip tracking started")),
            );


            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RouteSearchScreen(),
              ),
            );


          } catch (e) {


            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error starting trip")),
            );


          }


        },
        child: const Text(
          "Plan Route",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ),


    /// BOTTOM NAVIGATION
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,


      onTap: (index) async {


        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransitMapScreen(),
            ),
          );
        }


        if (index == 2) {
          await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReportIssueScreen(),
          ),
        );

        fetchAlerts(); //
        }


        if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsScreen(
                toggleTheme: widget.toggleTheme,
                isDarkMode: widget.isDarkMode,
              ),
            ),
          );
        }
      },


      items: const [


        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),


        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: "Map",
        ),


        BottomNavigationBarItem(
          icon: Icon(Icons.report),
          label: "Report",
        ),


        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Settings",
        ),
      ],
    ),
  );
}


Widget _recentTripTile() {
  return Card(
    color: AppColors.cardBackground,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: const ListTile(
      leading: Icon(Icons.directions_bus),
      title: Text("North Ave → Midtown"),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
    ),
  );
}
}

