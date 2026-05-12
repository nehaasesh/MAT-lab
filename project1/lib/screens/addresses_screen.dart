import 'package:flutter/material.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Addresses')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          AddressCard(
            label: 'Home',
            address: '123 Maple Avenue, Springfield',
            isDefault: true,
          ),
          AddressCard(
            label: 'Work',
            address: '456 Business Park, North Sector',
            isDefault: false,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}

class AddressCard extends StatelessWidget {
  final String label;
  final String address;
  final bool isDefault;

  const AddressCard({
    super.key,
    required this.label,
    required this.address,
    required this.isDefault,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.green),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(address),
        trailing: isDefault 
          ? const Chip(label: Text('Default', style: TextStyle(fontSize: 10))) 
          : null,
      ),
    );
  }
}
