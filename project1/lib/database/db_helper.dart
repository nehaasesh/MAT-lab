import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/shop_model.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'local_stock.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT,
        password TEXT,
        role TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE shops (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        address TEXT,
        lat REAL,
        lng REAL,
        owner_id INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE inventory (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id INTEGER,
        product_id INTEGER,
        status TEXT,
        last_updated TEXT,
        FOREIGN KEY (shop_id) REFERENCES shops (id),
        FOREIGN KEY (product_id) REFERENCES products (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shop_id INTEGER,
        FOREIGN KEY (shop_id) REFERENCES shops (id)
      )
    ''');

    // Seed robust sample data immediately
    await seedData(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          shop_id INTEGER,
          FOREIGN KEY (shop_id) REFERENCES shops (id)
        )
      ''');
    }
  }

  Future<void> seedData([Database? db]) async {
    final database = db ?? await this.database;
    
    // Check if data already exists to avoid duplicates
    final List<Map<String, dynamic>> existingProducts = await database.query('products');
    if (existingProducts.isNotEmpty) return;

    // 1. Seed Diverse Products
    final products = [
      {'id': 1, 'name': 'Organic Milk', 'category': 'Dairy', 'description': '1L Fresh Whole Milk'},
      {'id': 2, 'name': 'Whole Wheat Bread', 'category': 'Bakery', 'description': 'Freshly baked brown bread'},
      {'id': 3, 'name': 'Farm Eggs', 'category': 'Dairy', 'description': 'Dozen large brown eggs'},
      {'id': 4, 'name': 'Fuji Apples', 'category': 'Fruits', 'description': 'Sweet and crispy'},
      {'id': 5, 'name': 'Cavendish Bananas', 'category': 'Fruits', 'description': 'Ripe yellow bananas'},
      {'id': 6, 'name': 'Greek Yogurt', 'category': 'Dairy', 'description': 'High protein yogurt'},
      {'id': 7, 'name': 'Fresh Spinach', 'category': 'Vegetables', 'description': 'Organic baby spinach'},
      {'id': 8, 'name': 'Basmati Rice', 'category': 'Groceries', 'description': '5kg Premium long grain rice'},
    ];
    for (var p in products) {
      await database.insert('products', p);
    }

    // 2. Seed Demo Users
    await database.insert('users', {'id': 1, 'username': 'customer', 'password': '123', 'role': 'user'});
    await database.insert('users', {'id': 2, 'username': 'shopkeeper', 'password': '123', 'role': 'shopkeeper'});

    // 3. Seed Shops near Emulator location (37.422, -122.084)
    await database.insert('shops', {
      'id': 1,
      'name': 'Green Grocery Mart', 
      'address': '1600 Amphitheatre Pkwy, Mountain View', 
      'lat': 37.422, 
      'lng': -122.084, 
      'owner_id': 2
    });
    await database.insert('shops', {
      'id': 2,
      'name': 'Healthy Bites Store', 
      'address': '2400 Charleston Rd, Mountain View', 
      'lat': 37.425, 
      'lng': -122.081, 
      'owner_id': 2
    });
    await database.insert('shops', {
      'id': 3,
      'name': 'Quick Stop Corner', 
      'address': '1200 Plymouth St, Mountain View', 
      'lat': 37.418, 
      'lng': -122.091, 
      'owner_id': 2
    });

    // 4. Seed Inventory with various statuses and "outdated" timestamps
    final now = DateTime.now();
    final tenDaysAgo = now.subtract(const Duration(days: 10)); // Triggers "outdated" warning
    final yesterday = now.subtract(const Duration(days: 1));

    // Green Grocery Mart (Shop 1)
    await database.insert('inventory', {'shop_id': 1, 'product_id': 1, 'status': 'Available', 'last_updated': now.toIso8601String()});
    await database.insert('inventory', {'shop_id': 1, 'product_id': 2, 'status': 'Limited', 'last_updated': now.toIso8601String()});
    await database.insert('inventory', {'shop_id': 1, 'product_id': 4, 'status': 'Available', 'last_updated': tenDaysAgo.toIso8601String()});

    // Healthy Bites Store (Shop 2)
    await database.insert('inventory', {'shop_id': 2, 'product_id': 1, 'status': 'Out of Stock', 'last_updated': now.toIso8601String()});
    await database.insert('inventory', {'shop_id': 2, 'product_id': 3, 'status': 'Available', 'last_updated': yesterday.toIso8601String()});
    await database.insert('inventory', {'shop_id': 2, 'product_id': 6, 'status': 'Limited', 'last_updated': now.toIso8601String()});
    
    // Quick Stop Corner (Shop 3)
    await database.insert('inventory', {'shop_id': 3, 'product_id': 7, 'status': 'Available', 'last_updated': now.toIso8601String()});
    await database.insert('inventory', {'shop_id': 3, 'product_id': 8, 'status': 'Out of Stock', 'last_updated': now.toIso8601String()});

    // 5. Pre-add a favorite for the demo
    await database.insert('favorites', {'shop_id': 1});
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await database;
    return await db.query(table);
  }

  Future<int> update(String table, Map<String, dynamic> data, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(String table, String where, List<dynamic> whereArgs) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<Shop?> getShopByOwner(int ownerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shops',
      where: 'owner_id = ?',
      whereArgs: [ownerId],
    );
    if (maps.isNotEmpty) {
      return Shop.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> isFavorite(int shopId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorites',
      where: 'shop_id = ?',
      whereArgs: [shopId],
    );
    return maps.isNotEmpty;
  }

  Future<void> toggleFavorite(int shopId) async {
    final db = await database;
    if (await isFavorite(shopId)) {
      await db.delete('favorites', where: 'shop_id = ?', whereArgs: [shopId]);
    } else {
      await db.insert('favorites', {'shop_id': shopId});
    }
  }
}
