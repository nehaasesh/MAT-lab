import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NotificationTile(
            title: 'Stock Alert: Milk',
            message: 'Fresh Mart just updated their Milk stock to "Available"!',
            time: 'Just now',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
          NotificationTile(
            title: 'Limited Stock!',
            message: 'Only a few units of "Bread" left at Fresh Mart. Hurry!',
            time: '2 hours ago',
            icon: Icons.warning,
            color: Colors.orange,
          ),
          NotificationTile(
            title: 'New Shop Nearby',
            message: '"Daily Needs" is now listed on LocalStock Finder.',
            time: 'Yesterday',
            icon: Icons.store,
            color: Colors.blue,
          ),
          NotificationTile(
            title: 'Price Drop?',
            message: 'Check out the new descriptions for Fruits at City Grocers.',
            time: '2 days ago',
            icon: Icons.info,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;

  const NotificationTile({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message),
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
