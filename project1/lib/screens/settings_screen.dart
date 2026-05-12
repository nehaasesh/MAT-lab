import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Get alerts about stock updates'),
            value: _notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
            secondary: const Icon(Icons.notifications_outlined, color: Colors.green),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkMode,
            onChanged: (bool value) {
              setState(() {
                _darkMode = value;
              });
            },
            secondary: const Icon(Icons.dark_mode_outlined, color: Colors.green),
          ),
          const ListTile(
            title: Text('Account Security'),
            leading: Icon(Icons.security, color: Colors.green),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('Privacy Policy'),
            leading: Icon(Icons.privacy_tip_outlined, color: Colors.green),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
