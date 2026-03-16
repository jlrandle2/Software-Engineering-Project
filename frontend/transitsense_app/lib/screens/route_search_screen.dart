import 'package:flutter/material.dart';

class RouteSearchScreen extends StatefulWidget {
  const RouteSearchScreen({super.key});

  @override
  State<RouteSearchScreen> createState() => _RouteSearchScreenState();
}

class _RouteSearchScreenState extends State<RouteSearchScreen> {

  final List<String> routes = [
    "Bus 12 - Downtown",
    "Train A - Airport",
    "Bus 24 - Midtown",
    "Metro Red Line",
    "Bus 5 - City Center"
  ];

  String searchText = "";

  @override
  Widget build(BuildContext context) {

    List<String> filteredRoutes = routes
        .where((route) =>
            route.toLowerCase().contains(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Routes"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            /// SEARCH BAR
            TextField(
              decoration: InputDecoration(
                hintText: "Search route or stop...",
                prefixIcon: const Icon(Icons.search),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),

            const SizedBox(height: 20),

            /// RESULTS
            Expanded(
              child: ListView.builder(
                itemCount: filteredRoutes.length,

                itemBuilder: (context, index) {

                  final route = filteredRoutes[index];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),

                    child: ListTile(
                      leading: const Icon(
                        Icons.directions_bus,
                        color: Colors.blue,
                      ),

                      title: Text(route),

                      trailing: const Icon(Icons.arrow_forward_ios),

                      onTap: () {

                        /// Later you will navigate to map screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Selected: $route"),
                          ),
                        );

                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}