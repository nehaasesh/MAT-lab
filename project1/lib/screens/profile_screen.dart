import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              user?.username ?? 'Guest User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              user?.role == 'shopkeeper' ? 'Shopkeeper Account' : 'Customer Account',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _profileOption(Icons.shopping_bag_outlined, 'My Orders', () {}),
            _profileOption(Icons.location_on_outlined, 'Saved Addresses', () {}),
            _profileOption(Icons.payment_outlined, 'Payment Methods', () {}),
            _profileOption(Icons.settings_outlined, 'Settings', () {}),
            _profileOption(Icons.help_outline, 'Help & Support', () {}),
            const Divider(),
            _profileOption(Icons.logout, 'Logout', () {
              Provider.of<UserProvider>(context, listen: false).logout();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            }, textColor: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _profileOption(IconData icon, String title, VoidCallback onTap, {Color? textColor}) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
