import 'package:flutter/material.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          PaymentMethodTile(
            icon: Icons.credit_card,
            label: 'Visa ending in 1234',
            expiry: 'Expires 12/25',
          ),
          PaymentMethodTile(
            icon: Icons.account_balance_wallet,
            label: 'Google Pay',
            expiry: 'Connected',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        label: const Text('Add Method'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String expiry;

  const PaymentMethodTile({
    super.key,
    required this.icon,
    required this.label,
    required this.expiry,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: Colors.green),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(expiry),
        trailing: const Icon(Icons.more_vert),
      ),
    );
  }
}
