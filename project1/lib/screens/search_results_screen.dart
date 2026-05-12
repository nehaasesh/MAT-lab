import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../database/db_helper.dart';
import '../services/location_service.dart';
import 'shop_details_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;
  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = true;
  String _sortBy = 'distance'; // 'distance' or 'status'

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() => _isLoading = true);
    final db = DBHelper();
    final database = await db.database;
    final userPos = Provider.of<LocationService>(context, listen: false).currentPosition;

    final List<Map<String, dynamic>> rawResults = await database.rawQuery('''
      SELECT p.name as product_name, s.name as shop_name, s.address, s.lat, s.lng, 
             i.status, i.last_updated, s.id as shop_id
      FROM products p
      JOIN inventory i ON p.id = i.product_id
      JOIN shops s ON i.shop_id = s.id
      WHERE p.name LIKE ? OR p.category LIKE ?
    ''', ['%${widget.query}%', '%${widget.query}%']);

    // Map and add distance
    List<Map<String, dynamic>> processedResults = rawResults.map((item) {
      double distance = 0;
      if (userPos != null) {
        distance = Geolocator.distanceBetween(
          userPos.latitude,
          userPos.longitude,
          item['lat'] as double,
          item['lng'] as double,
        );
      }
      var mutableItem = Map<String, dynamic>.from(item);
      mutableItem['distance'] = distance;
      return mutableItem;
    }).toList();

    // Sort results
    if (_sortBy == 'distance') {
      processedResults.sort((a, b) => a['distance'].compareTo(b['distance']));
    }

    setState(() {
      _results = processedResults;
      _isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available': return Colors.green;
      case 'Limited': return Colors.orange;
      case 'Out of Stock': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.query}"'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (val) {
              setState(() => _sortBy = val);
              _search();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'distance', child: Text('Sort by Distance')),
              const PopupMenuItem(value: 'status', child: Text('Sort by Availability')),
            ],
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _results.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final item = _results[index];
                    final distanceKm = (item['distance'] / 1000).toStringAsFixed(1);

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(item['shop_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['address']),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                Text(' $distanceKm km away', style: TextStyle(color: Colors.grey[600])),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(item['status']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item['status'],
                                    style: TextStyle(color: _getStatusColor(item['status']), fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ShopDetailsScreen(shopId: item['shop_id']),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('No shops found with this product.', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
