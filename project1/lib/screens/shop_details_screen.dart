import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/shop_model.dart';
import 'package:intl/intl.dart';

class ShopDetailsScreen extends StatefulWidget {
  final int? shopId;
  const ShopDetailsScreen({super.key, this.shopId});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  Shop? _shop;
  List<Map<String, dynamic>> _inventory = [];
  bool _isLoading = true;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
  }

  Future<void> _fetchShopDetails() async {
    if (widget.shopId == null) return;
    
    final db = DBHelper();
    final database = await db.database;

    final shops = await database.query('shops', where: 'id = ?', whereArgs: [widget.shopId]);
    if (shops.isNotEmpty) {
      _shop = Shop.fromMap(shops.first);
    }

    final inventory = await database.rawQuery('''
      SELECT p.name, i.status, i.last_updated
      FROM inventory i
      JOIN products p ON i.product_id = p.id
      WHERE i.shop_id = ?
    ''', [widget.shopId]);

    final isFav = await db.isFavorite(widget.shopId!);

    setState(() {
      _inventory = inventory;
      _isFavorite = isFav;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite() async {
    if (widget.shopId == null) return;
    final db = DBHelper();
    await db.toggleFavorite(widget.shopId!);
    final isFav = await db.isFavorite(widget.shopId!);
    setState(() {
      _isFavorite = isFav;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isFavorite ? 'Added to favorites' : 'Removed from favorites')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_shop == null) return const Scaffold(body: Center(child: Text('Shop not found')));

    return Scaffold(
      appBar: AppBar(
        title: Text(_shop!.name),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? Colors.red : null,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchShopDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_shop!.address, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 20),
              Text('Stock Status', style: Theme.of(context).textTheme.titleLarge),
              const Divider(),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _inventory.length,
                itemBuilder: (context, index) {
                  final item = _inventory[index];
                  final lastUpdated = DateTime.parse(item['last_updated']);
                  final isOutdated = DateTime.now().difference(lastUpdated).inDays > 7;

                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(
                      isOutdated 
                        ? 'Possibly outdated (Updated: ${DateFormat.yMMMd().format(lastUpdated)})' 
                        : 'Updated: ${DateFormat.yMMMd().add_jm().format(lastUpdated)}',
                      style: TextStyle(color: isOutdated ? Colors.redAccent : Colors.grey),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item['status']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item['status'],
                        style: TextStyle(color: _getStatusColor(item['status']), fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // This could open the map screen focused on this shop
                  Navigator.pushNamed(context, '/map');
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Show on Map'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
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
