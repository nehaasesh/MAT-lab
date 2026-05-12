import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/shop_model.dart';
import 'shop_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Shop> _favoriteShops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    setState(() => _isLoading = true);
    final db = DBHelper();
    final database = await db.database;

    final List<Map<String, dynamic>> result = await database.rawQuery('''
      SELECT s.*
      FROM shops s
      JOIN favorites f ON s.id = f.shop_id
    ''');

    setState(() {
      _favoriteShops = result.map((s) => Shop.fromMap(s)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteShops.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No favorites added yet.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _favoriteShops.length,
                  itemBuilder: (context, index) {
                    final shop = _favoriteShops[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Icon(Icons.store, color: Colors.white),
                        ),
                        title: Text(shop.name),
                        subtitle: Text(shop.address),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShopDetailsScreen(shopId: shop.id),
                            ),
                          );
                          _fetchFavorites(); // Refresh when coming back
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
