import 'package:flutter/material.dart';

class TransitCard extends StatelessWidget {

  final String routeName;
  final String startStop;
  final String endStop;
  final VoidCallback onTap;

  const TransitCard({
    super.key,
    required this.routeName,
    required this.startStop,
    required this.endStop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      child: ListTile(
        leading: const Icon(
          Icons.directions_bus,
          color: Colors.blue,
        ),

        title: Text(
          routeName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text("$startStop → $endStop"),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),

        onTap: onTap,
      ),
    );
  }
}