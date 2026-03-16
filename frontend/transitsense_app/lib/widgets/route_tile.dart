import 'package:flutter/material.dart';

class RouteTile extends StatelessWidget {

  final String routeName;
  final String start;
  final String end;
  final VoidCallback onTap;

  const RouteTile({
    super.key,
    required this.routeName,
    required this.start,
    required this.end,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),

      child: ListTile(
        leading: const Icon(Icons.directions_bus),
        title: Text(routeName),
        subtitle: Text("$start → $end"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}