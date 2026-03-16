import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  const SettingsScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),

        children: [

          /// NOTIFICATIONS
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: SwitchListTile(
              title: const Text("Enable Notifications"),
              subtitle: const Text("Receive alerts about delays and updates"),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          /// DARK MODE
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: SwitchListTile(
              title: const Text("Dark Mode"),
              subtitle: const Text("Toggle dark theme"),
              value: widget.isDarkMode,

              onChanged: (value) {
                widget.toggleTheme(value);
              },
            ),
          ),

          const SizedBox(height: 12),

          /// LANGUAGE
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Language"),
              subtitle: const Text("English"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Language settings coming soon"),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          /// ABOUT
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About TransitSense"),
              subtitle: const Text("Learn more about the app"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "TransitSense",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2026 TransitSense",
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          const Center(
            child: Text(
              "Version 1.0.0",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}