import 'package:flutter/material.dart';

class TransitMapScreen extends StatelessWidget {
  const TransitMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transit Map"),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ROUTE TITLE
              const Text(
                "Bus 12 - Downtown",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// MAP PLACEHOLDER
              Container(
                height: 250,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Center(
                  child: Text(
                    "Map View (Google Maps Coming Soon)",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// ROUTE STOPS TITLE
              const Text(
                "Upcoming Stops",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// STOPS LIST
              _stopTile("North Ave Station"),
              _stopTile("Tech Square"),
              _stopTile("Midtown Station"),
              _stopTile("Arts Center"),
              _stopTile("Downtown Terminal"),

              const SizedBox(height: 24),

              /// LIVE STATUS
              Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: const [

                    Icon(
                      Icons.directions_bus,
                      color: Colors.blue,
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        "Next bus arriving in 6 minutes",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// STOP TILE WIDGET
  Widget _stopTile(String stopName) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 10),

      child: ListTile(
        leading: const Icon(Icons.location_on),
        title: Text(stopName),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}