import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';
import '../database/db_helper.dart';
import '../models/shop_model.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  List<Marker> _markers = [];
  bool _isLoadingShops = true;

  @override
  void initState() {
    super.initState();
    _loadShopMarkers();
  }

  Future<void> _loadShopMarkers() async {
    final db = DBHelper();
    final database = await db.database;
    
    // Fetch shops with an aggregated status (prioritizing Out of Stock/Limited)
    final List<Map<String, dynamic>> shopsWithStatus = await database.rawQuery('''
      SELECT s.*, 
        (SELECT status FROM inventory WHERE shop_id = s.id ORDER BY 
          CASE status 
            WHEN 'Out of Stock' THEN 1 
            WHEN 'Limited' THEN 2 
            WHEN 'Available' THEN 3 
            ELSE 4 
          END ASC LIMIT 1) as aggregate_status
      FROM shops s
    ''');

    setState(() {
      _markers = shopsWithStatus.map((data) {
        final shop = Shop.fromMap(data);
        final status = data['aggregate_status'] ?? 'Unknown';
        
        return Marker(
          point: LatLng(shop.lat, shop.lng),
          width: 60,
          height: 60,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/shop_details', arguments: shop.id);
            },
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
                  ),
                  child: Text(
                    shop.name,
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.location_on,
                  color: _getStatusColor(status),
                  size: 35,
                ),
              ],
            ),
          ),
        );
      }).toList();
      _isLoadingShops = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available': return Colors.green;
      case 'Limited': return Colors.orange;
      case 'Out of Stock': return Colors.red;
      default: return Colors.blue; // Default for shops with no inventory yet
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationService = Provider.of<LocationService>(context);
    final currentPos = locationService.currentPosition;

    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Shops')),
      body: currentPos == null || _isLoadingShops
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(currentPos.latitude, currentPos.longitude),
                initialZoom: 14.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.project1',
                ),
                MarkerLayer(markers: _markers),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(currentPos.latitude, currentPos.longitude),
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blueAccent,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => locationService.getCurrentLocation(),
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
