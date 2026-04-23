import 'package:flutter/material.dart';

class TransitMapScreen extends StatelessWidget {
  const TransitMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transit Map"),
      ),

      body: SizedBox.expand(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 6,
              boundaryMargin: const EdgeInsets.all(200),

              child: Stack(
                children: [

                  /// MAP (FULL SCREEN, NO CROPPING)
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: Image.asset(
                      'assets/images/MARTA-train-map.png',
                      fit: BoxFit.contain, // ✅ KEEP THIS
                    ),
                  ),

                  /// STATIONS
                  ..._buildStations(context, constraints),

                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🔴 STATIONS
  List<Widget> _buildStations(BuildContext context, BoxConstraints constraints) {

    final stations = [

      {"name": "Lindbergh", "x": 0.543, "y": 0.375},
      {"name": "Arts Center", "x": 0.507, "y": 0.45},
      {"name": "Midtown", "x": 0.507, "y": 0.48},
      {"name": "North Ave", "x": 0.507, "y": 0.510},
      {"name": "Civic Center", "x": 0.507, "y": 0.543},
      {"name": "Peachtree Center", "x": 0.507, "y": 0.583},
      {"name": "Five Points", "x": 0.515, "y": 0.64},
      {"name": "Garnett", "x": 0.485, "y": 0.670},

      {"name": "Georgia State", "x": 0.547, "y": 0.633},
      {"name": "King Memorial", "x": 0.585, "y": 0.633},
      {"name": "Inman Park", "x": 0.620, "y": 0.633},
      {"name": "Edgewood", "x": 0.658, "y": 0.633},
      {"name": "East Lake", "x": 0.697, "y": 0.64},
      {"name": "Decatur", "x": 0.74, "y": 0.64},
      {"name": "Avondale", "x": 0.78, "y": 0.64},
      {"name": "Kensington", "x": 0.82, "y": 0.64},
      {"name": "Indian Creek", "x": 0.8625, "y": 0.6415},

      {"name": "Hamilton E. Holmes", "x": 0.245, "y": 0.640},
      {"name": "GWCC/CNN Center", "x": 0.455, "y": 0.633},
      {"name": "Vine City", "x": 0.415, "y": 0.633},
      {"name": "Ashby", "x": 0.38, "y": 0.633},
      {"name": "West Lake", "x": 0.34, "y": 0.640},
      {"name": "Bankhead", "x": 0.32, "y": 0.576},

      {"name": "West End", "x": 0.45, "y": 0.728},
      {"name": "Oakland City", "x": 0.45, "y": 0.760},
      {"name": "Lakewood", "x": 0.45, "y": 0.792},
      {"name": "East Point", "x": 0.45, "y": 0.824},
      {"name": "College Park", "x": 0.45, "y": 0.875},
      {"name": "Airport", "x": 0.495, "y": 0.959},

      {"name": "Buckhead", "x": 0.57, "y": 0.30},
      {"name": "Medical Center", "x": 0.5955, "y": 0.185},
      {"name": "Dunwoody", "x": 0.61, "y": 0.140},
      {"name": "Sandy Springs", "x": 0.590, "y": 0.08},
      {"name": "North Springs", "x": 0.57, "y": 0.03},

      {"name": "Lenox", "x": 0.605, "y": 0.32},
      {"name": "Brookhaven", "x": 0.636, "y": 0.285},
      {"name": "Chamblee", "x": 0.666, "y": 0.25},
      {"name": "Doraville", "x": 0.7, "y": 0.215},
    ];

    return stations.map((station) {

      final isFivePoints = station["name"] == "Five Points";
      final size = isFivePoints ? 28.0 : 16.0;

      return Positioned(
        left: constraints.maxWidth * (station["x"] as double) - (isFivePoints ? size / 2 : 0),
        top: constraints.maxHeight * (station["y"] as double) - (isFivePoints ? size / 2 : 0),

        child: GestureDetector(
          onTap: () => _showAlerts(context, station["name"] as String),

          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.85),
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }).toList();
  }

  /// ALERTS
  void _showAlerts(BuildContext context, String station) {
    final alerts = _getFakeAlerts(station);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                station,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              if (alerts.isEmpty)
                const Text("No alerts right now"),

              ...alerts.map((a) => Text("🚨 $a")),

            ],
          ),
        );
      },
    );
  }

  List<String> _getFakeAlerts(String station) {
    switch (station) {
      case "Midtown":
        return ["Fake Alert - Delay on Red Line"];
      case "Five Points":
        return ["Fake Alert - Heavy congestion", "Fake Alert - Transfer delays"];
      case "Airport":
        return ["Fake Alert - Train arriving in 2 minutes"];
      case "Decatur":
        return ["Fake Alert - Minor delay on Blue Line"];
      default:
        return [];
    }
  }
}