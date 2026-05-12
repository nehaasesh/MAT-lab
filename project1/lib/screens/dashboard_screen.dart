import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/db_helper.dart';
import '../models/shop_model.dart';
import '../services/user_provider.dart';
import '../services/location_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _inventory = [];
  bool _isLoading = true;
  Shop? _myShop;

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null || user.id == null) return;

    final db = DBHelper();
    _myShop = await db.getShopByOwner(user.id!);

    if (_myShop == null) {
      await db.insert('shops', {
        'name': '${user.username}\'s Shop',
        'address': 'Registering address...',
        'lat': 0.0,
        'lng': 0.0,
        'owner_id': user.id,
      });
      _myShop = await db.getShopByOwner(user.id!);
    }

    await _fetchInventory();
  }

  Future<void> _fetchInventory() async {
    if (_myShop == null) return;
    
    setState(() => _isLoading = true);
    final db = DBHelper();
    final database = await db.database;

    final inventory = await database.rawQuery('''
      SELECT i.id as inventory_id, p.name, i.status, i.last_updated, p.id as product_id
      FROM inventory i
      JOIN products p ON i.product_id = p.id
      WHERE i.shop_id = ?
    ''', [_myShop!.id]);

    setState(() {
      _inventory = inventory;
      _isLoading = false;
    });
  }

  Future<void> _updateLocation() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    await locationService.getCurrentLocation();
    final pos = locationService.currentPosition;

    if (pos != null && _myShop != null) {
      final db = DBHelper();
      await db.update(
        'shops',
        {'lat': pos.latitude, 'lng': pos.longitude, 'address': 'Current GPS Location'},
        'id = ?',
        [_myShop!.id],
      );
      _myShop = await db.getShopByOwner(_myShop!.ownerId);
      
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shop location updated to current GPS!')),
      );
    }
  }

  Future<void> _updateStock(int inventoryId, String newStatus) async {
    final db = DBHelper();
    await db.update(
      'inventory',
      {
        'status': newStatus,
        'last_updated': DateTime.now().toIso8601String(),
      },
      'id = ?',
      [inventoryId],
    );
    _fetchInventory();
  }

  void _showAddProductDialog() async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Product Name')),
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty && _myShop != null) {
                final db = DBHelper();
                int productId = await db.insert('products', {
                  'name': nameController.text,
                  'category': categoryController.text,
                  'description': 'Added by shopkeeper',
                });
                await db.insert('inventory', {
                  'shop_id': _myShop!.id,
                  'product_id': productId,
                  'status': 'Available',
                  'last_updated': DateTime.now().toIso8601String(),
                });
                
                if (!mounted) return;
                Navigator.pop(context);
                _fetchInventory();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_myShop?.name ?? 'Shop Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_searching),
            tooltip: 'Update Shop Location',
            onPressed: _updateLocation,
          ),
          IconButton(
            icon: const Icon(Icons.logout), 
            onPressed: () => Navigator.pushReplacementNamed(context, '/login')
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_myShop?.lat == 0.0)
                  Container(
                    width: double.infinity,
                    color: Colors.orange.shade100,
                    padding: const EdgeInsets.all(8),
                    child: const Text(
                      'Warning: Shop location not set. Tap the GPS icon above to set it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                    ),
                  ),
                Expanded(
                  child: _inventory.isEmpty
                      ? const Center(child: Text('Inventory is empty. Tap + to add.'))
                      : ListView.builder(
                          itemCount: _inventory.length,
                          itemBuilder: (context, index) {
                            final item = _inventory[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: ListTile(
                                title: Text(item['name']),
                                subtitle: Text('Updated: ${DateFormat.yMMMd().format(DateTime.parse(item['last_updated']))}'),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (val) => _updateStock(item['inventory_id'], val),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(value: 'Available', child: Text('Available', style: TextStyle(color: Colors.green))),
                                    const PopupMenuItem(value: 'Limited', child: Text('Limited', style: TextStyle(color: Colors.orange))),
                                    const PopupMenuItem(value: 'Out of Stock', child: Text('Out of Stock', style: TextStyle(color: Colors.red))),
                                  ],
                                  child: Chip(
                                    label: Text(item['status'], style: const TextStyle(fontSize: 10)),
                                    backgroundColor: _getStatusColor(item['status']).withOpacity(0.1),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProductDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available': return Colors.green;
      case 'Limited': return Colors.orange;
      case 'Out of Stock': return Colors.red;
      default: return Colors.grey;
    }
  }
}
