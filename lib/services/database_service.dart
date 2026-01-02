import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/waste_model.dart';
import '../models/bid_model.dart';
import '../models/order_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'agri_waste.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        role TEXT NOT NULL,
        address TEXT,
        location TEXT,
        verified INTEGER DEFAULT 0,
        rating REAL DEFAULT 0.0,
        rating_count INTEGER DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    // Waste posts table
    await db.execute('''
      CREATE TABLE waste_posts (
        id TEXT PRIMARY KEY,
        farmer_id TEXT NOT NULL,
        farmer_name TEXT NOT NULL,
        waste_type TEXT NOT NULL,
        quantity REAL NOT NULL,
        price_per_kg REAL,
        location TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        description TEXT,
        image_url TEXT,
        status TEXT DEFAULT 'available',
        created_at INTEGER NOT NULL,
        FOREIGN KEY (farmer_id) REFERENCES users (id)
      )
    ''');

    // Bids table
    await db.execute('''
      CREATE TABLE bids (
        id TEXT PRIMARY KEY,
        waste_id TEXT NOT NULL,
        manufacturer_id TEXT NOT NULL,
        manufacturer_name TEXT NOT NULL,
        offered_price REAL NOT NULL,
        quantity REAL NOT NULL,
        message TEXT,
        status TEXT DEFAULT 'pending',
        created_at INTEGER NOT NULL,
        FOREIGN KEY (waste_id) REFERENCES waste_posts (id),
        FOREIGN KEY (manufacturer_id) REFERENCES users (id)
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        waste_id TEXT NOT NULL,
        bid_id TEXT,
        farmer_id TEXT NOT NULL,
        manufacturer_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        total_price REAL NOT NULL,
        delivery_charge REAL DEFAULT 0,
        pickup_location TEXT,
        delivery_location TEXT,
        status TEXT DEFAULT 'posted',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (waste_id) REFERENCES waste_posts (id),
        FOREIGN KEY (bid_id) REFERENCES bids (id),
        FOREIGN KEY (farmer_id) REFERENCES users (id),
        FOREIGN KEY (manufacturer_id) REFERENCES users (id)
      )
    ''');

    // Credentials table (for local authentication)
    await db.execute('''
      CREATE TABLE credentials (
        email TEXT PRIMARY KEY,
        password TEXT NOT NULL
      )
    ''');
  }

  // ========== USER OPERATIONS ==========

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return await db.insert(
      'users',
      user.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromJson(maps.first);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return UserModel.fromJson(maps.first);
  }

  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => UserModel.fromJson(maps[i]));
  }

  Future<List<UserModel>> getUsersByRole(String role) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: [role],
    );
    return List.generate(maps.length, (i) => UserModel.fromJson(maps[i]));
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== WASTE POST OPERATIONS ==========

  Future<int> insertWastePost(WasteModel waste) async {
    final db = await database;
    return await db.insert(
      'waste_posts',
      waste.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<WasteModel?> getWastePostById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'waste_posts',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return WasteModel.fromJson(maps.first);
  }

  Future<List<WasteModel>> getAllWastePosts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'waste_posts',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => WasteModel.fromJson(maps[i]));
  }

  Future<List<WasteModel>> getWastePostsByFarmerId(String farmerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'waste_posts',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => WasteModel.fromJson(maps[i]));
  }

  Future<List<WasteModel>> getAvailableWastePosts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'waste_posts',
      where: 'status = ?',
      whereArgs: ['available'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => WasteModel.fromJson(maps[i]));
  }

  Future<int> updateWastePost(WasteModel waste) async {
    final db = await database;
    return await db.update(
      'waste_posts',
      waste.toJson(),
      where: 'id = ?',
      whereArgs: [waste.id],
    );
  }

  Future<int> deleteWastePost(String id) async {
    final db = await database;
    return await db.delete(
      'waste_posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== BID OPERATIONS ==========

  Future<int> insertBid(BidModel bid) async {
    final db = await database;
    return await db.insert(
      'bids',
      bid.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<BidModel?> getBidById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bids',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return BidModel.fromJson(maps.first);
  }

  Future<List<BidModel>> getBidsByWasteId(String wasteId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bids',
      where: 'waste_id = ?',
      whereArgs: [wasteId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => BidModel.fromJson(maps[i]));
  }

  Future<List<BidModel>> getBidsByManufacturerId(String manufacturerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bids',
      where: 'manufacturer_id = ?',
      whereArgs: [manufacturerId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => BidModel.fromJson(maps[i]));
  }

  Future<int> updateBid(BidModel bid) async {
    final db = await database;
    return await db.update(
      'bids',
      bid.toJson(),
      where: 'id = ?',
      whereArgs: [bid.id],
    );
  }

  Future<int> deleteBid(String id) async {
    final db = await database;
    return await db.delete(
      'bids',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== ORDER OPERATIONS ==========

  Future<int> insertOrder(OrderModel order) async {
    final db = await database;
    return await db.insert(
      'orders',
      order.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<OrderModel?> getOrderById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return OrderModel.fromJson(maps.first);
  }

  Future<List<OrderModel>> getOrdersByFarmerId(String farmerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'farmer_id = ?',
      whereArgs: [farmerId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => OrderModel.fromJson(maps[i]));
  }

  Future<List<OrderModel>> getOrdersByManufacturerId(String manufacturerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'manufacturer_id = ?',
      whereArgs: [manufacturerId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => OrderModel.fromJson(maps[i]));
  }

  Future<int> updateOrder(OrderModel order) async {
    final db = await database;
    return await db.update(
      'orders',
      order.toJson(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  Future<int> deleteOrder(String id) async {
    final db = await database;
    return await db.delete(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========== AUTHENTICATION OPERATIONS ==========

  Future<int> saveCredentials(String email, String password) async {
    final db = await database;
    return await db.insert(
      'credentials',
      {'email': email, 'password': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getPassword(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'credentials',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return maps.first['password'] as String;
  }

  Future<int> updatePassword(String email, String newPassword) async {
    final db = await database;
    return await db.update(
      'credentials',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  // ========== UTILITY OPERATIONS ==========

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('users');
    await db.delete('waste_posts');
    await db.delete('bids');
    await db.delete('orders');
    await db.delete('credentials');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
