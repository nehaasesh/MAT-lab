import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../database/db_helper.dart';
import '../models/product_model.dart';
import '../widgets/product_card.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _featuredProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final db = DBHelper();
    
    // Seed some data if empty
    final existingProducts = await db.queryAll('products');
    if (existingProducts.isEmpty) {
      // 1. Seed Products
      await db.insert('products', {'name': 'Milk', 'category': 'Dairy', 'description': 'Fresh whole milk'});
      await db.insert('products', {'name': 'Bread', 'category': 'Bakery', 'description': 'Whole wheat bread'});
      await db.insert('products', {'name': 'Eggs', 'category': 'Dairy', 'description': 'Farm fresh eggs'});
      await db.insert('products', {'name': 'Apples', 'category': 'Fruits', 'description': 'Crispy red apples'});
      await db.insert('products', {'name': 'Bananas', 'category': 'Fruits', 'description': 'Ripe yellow bananas'});

      // 2. Seed Users (for Demo Dashboard)
      await db.insert('users', {'id': 1, 'username': 'admin', 'password': 'password', 'role': 'shopkeeper'});
      
      // 3. Seed Shops (Centered around emulator location 37.422, -122.084)
      await db.insert('shops', {
        'id': 1,
        'name': 'Fresh Mart',
        'address': '123 Green St',
        'lat': 37.4219999,
        'lng': -122.0840575,
        'owner_id': 1
      });
      await db.insert('shops', {
        'id': 2,
        'name': 'City Grocers',
        'address': '456 Urban Ave',
        'lat': 37.425,
        'lng': -122.080,
        'owner_id': 1
      });
      await db.insert('shops', {
        'id': 3,
        'name': 'Daily Needs',
        'address': '789 Corner Rd',
        'lat': 37.418,
        'lng': -122.090,
        'owner_id': 1
      });

      // 4. Seed Inventory with various statuses and timestamps
      final now = DateTime.now();
      final tenDaysAgo = now.subtract(const Duration(days: 10));
      final threeDaysAgo = now.subtract(const Duration(days: 3));

      // Fresh Mart
      await db.insert('inventory', {'shop_id': 1, 'product_id': 1, 'status': 'Available', 'last_updated': now.toIso8601String()});
      await db.insert('inventory', {'shop_id': 1, 'product_id': 2, 'status': 'Limited', 'last_updated': threeDaysAgo.toIso8601String()});

      // City Grocers
      await db.insert('inventory', {'shop_id': 2, 'product_id': 1, 'status': 'Out of Stock', 'last_updated': now.toIso8601String()});
      await db.insert('inventory', {'shop_id': 2, 'product_id': 4, 'status': 'Available', 'last_updated': tenDaysAgo.toIso8601String()});

      // Daily Needs
      await db.insert('inventory', {'shop_id': 3, 'product_id': 3, 'status': 'Available', 'last_updated': now.toIso8601String()});
      await db.insert('inventory', {'shop_id': 3, 'product_id': 5, 'status': 'Out of Stock', 'last_updated': now.toIso8601String()});
    }

    final products = await db.queryAll('products');
    setState(() {
      _featuredProducts = products.map((p) => Product.fromMap(p)).toList();
      _isLoading = false;
    });
    
    // Request location
    Provider.of<LocationService>(context, listen: false).getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LocalStock Finder'),
        actions: [
          IconButton(icon: const Icon(Icons.map), onPressed: () => Navigator.pushNamed(context, '/map')),
          IconButton(icon: const Icon(Icons.person), onPressed: () => Navigator.pushNamed(context, '/profile')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for products...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () {
                      if (_searchController.text.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchResultsScreen(query: _searchController.text),
                          ),
                        );
                      }
                    },
                  ),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultsScreen(query: value),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              Text('Categories', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _categoryChip('Dairy'),
                    _categoryChip('Bakery'),
                    _categoryChip('Fruits'),
                    _categoryChip('Vegetables'),
                    _categoryChip('Groceries'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Featured Products', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _featuredProducts.isEmpty
                      ? const Text('No products found.')
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _featuredProducts.length,
                          itemBuilder: (context, index) {
                            return ProductCard(product: _featuredProducts[index]);
                          },
                        ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        ],
        onTap: (index) {
          if (index == 1) Navigator.pushNamed(context, '/favorites');
          if (index == 2) Navigator.pushNamed(context, '/notifications');
        },
      ),
    );
  }

  Widget _categoryChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ActionChip(
        label: Text(label),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchResultsScreen(query: label),
            ),
          );
        },
      ),
    );
  }
}
