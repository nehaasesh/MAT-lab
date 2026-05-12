import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://api.example.com'; // Replace with your actual backend URL

  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('\$baseUrl/products'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('API Error: \$e');
      rethrow;
    }
  }

  Future<void> updateStock(int productId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/update-stock'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'product_id': productId,
          'status': status,
        }),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update stock on server');
      }
    } catch (e) {
      print('API Error: \$e');
      rethrow;
    }
  }
}
