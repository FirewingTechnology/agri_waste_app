// Local Storage Service - Using SharedPreferences
// This can be easily replaced with Firestore later
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/waste_model.dart';
import '../models/bid_model.dart';
import '../models/order_model.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  late SharedPreferences _prefs;

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  // Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ========== USER OPERATIONS ==========

  /// Save user data locally
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _prefs.setString('user_${user.id}', userJson);
      // Also save current user
      await _prefs.setString('current_user_id', user.id);
    } catch (e) {
      throw Exception('Error saving user: $e');
    }
  }

  /// Get user data
  Future<UserModel?> getUser(String userId) async {
    try {
      final userJson = _prefs.getString('user_$userId');
      if (userJson == null) return null;
      
      return UserModel.fromJson(jsonDecode(userJson));
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  /// Get current logged-in user
  Future<UserModel?> getCurrentUser() async {
    try {
      final userId = _prefs.getString('current_user_id');
      if (userId == null) return null;
      
      return getUser(userId);
    } catch (e) {
      throw Exception('Error getting current user: $e');
    }
  }

  /// Set current user ID
  Future<void> setCurrentUserId(String userId) async {
    try {
      await _prefs.setString('current_user_id', userId);
    } catch (e) {
      throw Exception('Error setting current user ID: $e');
    }
  }

  /// Get string from SharedPreferences
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Set string in SharedPreferences
  Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  /// Get all keys from SharedPreferences
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  /// Update user data
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      final user = await getUser(userId);
      if (user == null) throw Exception('User not found');

      // Merge updates with existing user data
      final updatedUser = user.copyWith(
        name: updates['name'] ?? user.name,
        phone: updates['phone'] ?? user.phone,
        address: updates['address'] ?? user.address,
        location: updates['location'] ?? user.location,
      );

      await saveUser(updatedUser);
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  // ========== WASTE POSTS OPERATIONS ==========

  /// Create a new waste post
  Future<String> createWastePost(WasteModel waste) async {
    try {
      final wasteWithId = waste.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString());
      final wasteJson = jsonEncode(wasteWithId.toJson());
      await _prefs.setString('waste_${wasteWithId.id}', wasteJson);

      // Add to waste list
      List<String> wasteIds = _prefs.getStringList('waste_list') ?? [];
      wasteIds.add(wasteWithId.id);
      await _prefs.setStringList('waste_list', wasteIds);

      return wasteWithId.id;
    } catch (e) {
      throw Exception('Error creating waste post: $e');
    }
  }

  /// Get all waste posts
  Future<List<WasteModel>> getAllWastePosts() async {
    try {
      final wasteIds = _prefs.getStringList('waste_list') ?? [];
      final wastePosts = <WasteModel>[];

      for (final id in wasteIds) {
        final wasteJson = _prefs.getString('waste_$id');
        if (wasteJson != null) {
          final waste = WasteModel.fromJson(jsonDecode(wasteJson));
          // Only return available posts
          if (waste.status == 'available') {
            wastePosts.add(waste);
          }
        }
      }

      // Sort by creation date (newest first)
      wastePosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return wastePosts;
    } catch (e) {
      throw Exception('Error fetching waste posts: $e');
    }
  }

  /// Get waste posts by farmer
  Future<List<WasteModel>> getWastePostsByFarmer(String farmerId) async {
    try {
      final allPosts = await getAllWastePosts();
      return allPosts.where((post) => post.farmerId == farmerId).toList();
    } catch (e) {
      throw Exception('Error fetching farmer waste posts: $e');
    }
  }

  /// Get single waste post
  Future<WasteModel?> getWastePost(String postId) async {
    try {
      final wasteJson = _prefs.getString('waste_$postId');
      if (wasteJson == null) return null;

      return WasteModel.fromJson(jsonDecode(wasteJson));
    } catch (e) {
      throw Exception('Error fetching waste post: $e');
    }
  }

  /// Update waste post
  Future<void> updateWastePost(String postId, Map<String, dynamic> updates) async {
    try {
      final waste = await getWastePost(postId);
      if (waste == null) throw Exception('Waste post not found');

      final updatedWaste = waste.copyWith(
        status: updates['status'] ?? waste.status,
        pricePerKg: updates['pricePerKg'] ?? waste.pricePerKg,
        processorId: updates['processorId'] ?? waste.processorId,
        updatedAt: DateTime.now(),
      );

      final wasteJson = jsonEncode(updatedWaste.toJson());
      await _prefs.setString('waste_$postId', wasteJson);
    } catch (e) {
      throw Exception('Error updating waste post: $e');
    }
  }

  /// Delete waste post
  Future<void> deleteWastePost(String postId) async {
    try {
      await _prefs.remove('waste_$postId');

      List<String> wasteIds = _prefs.getStringList('waste_list') ?? [];
      wasteIds.remove(postId);
      await _prefs.setStringList('waste_list', wasteIds);
    } catch (e) {
      throw Exception('Error deleting waste post: $e');
    }
  }

  // ========== BIDS OPERATIONS ==========

  /// Place a new bid
  Future<String> placeBid(BidModel bid) async {
    try {
      final bidWithId = bid.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      final bidJson = jsonEncode(bidWithId.toJson());
      await _prefs.setString('bid_${bidWithId.id}', bidJson);

      // Add to bids list
      List<String> bidIds = _prefs.getStringList('bid_list') ?? [];
      bidIds.add(bidWithId.id);
      await _prefs.setStringList('bid_list', bidIds);

      return bidWithId.id;
    } catch (e) {
      throw Exception('Error placing bid: $e');
    }
  }

  /// Get bids for waste post
  Future<List<BidModel>> getBidsForWastePost(String wastePostId) async {
    try {
      final bidIds = _prefs.getStringList('bid_list') ?? [];
      final bids = <BidModel>[];

      for (final id in bidIds) {
        final bidJson = _prefs.getString('bid_$id');
        if (bidJson != null) {
          final bid = BidModel.fromJson(jsonDecode(bidJson));
          if (bid.wastePostId == wastePostId && bid.status == 'active') {
            bids.add(bid);
          }
        }
      }

      // Sort by bid amount (highest first)
      bids.sort((a, b) => b.bidAmount.compareTo(a.bidAmount));
      return bids;
    } catch (e) {
      throw Exception('Error fetching bids: $e');
    }
  }

  /// Get bids by processor
  Future<List<BidModel>> getBidsByProcessor(String processorId) async {
    try {
      final bidIds = _prefs.getStringList('bid_list') ?? [];
      final bids = <BidModel>[];

      for (final id in bidIds) {
        final bidJson = _prefs.getString('bid_$id');
        if (bidJson != null) {
          final bid = BidModel.fromJson(jsonDecode(bidJson));
          if (bid.bidderId == processorId) {
            bids.add(bid);
          }
        }
      }

      return bids;
    } catch (e) {
      throw Exception('Error fetching processor bids: $e');
    }
  }

  /// Update bid
  Future<void> updateBid(String bidId, Map<String, dynamic> updates) async {
    try {
      final bidJson = _prefs.getString('bid_$bidId');
      if (bidJson == null) throw Exception('Bid not found');

      final bid = BidModel.fromJson(jsonDecode(bidJson));
      final updatedBid = bid.copyWith(
        status: updates['status'] ?? bid.status,
        bidAmount: updates['bidAmount'] ?? bid.bidAmount,
        totalBidAmount: updates['totalBidAmount'] ?? bid.totalBidAmount,
        message: updates['message'] ?? bid.message,
        updatedAt: DateTime.now(),
      );

      final updatedBidJson = jsonEncode(updatedBid.toJson());
      await _prefs.setString('bid_$bidId', updatedBidJson);
    } catch (e) {
      throw Exception('Error updating bid: $e');
    }
  }

  /// Accept bid (reject all others for same waste post)
  Future<void> acceptBid(String bidId, String wastePostId) async {
    try {
      // Update accepted bid
      await updateBid(bidId, {'status': 'accepted', 'respondedAt': DateTime.now()});

      // Update waste post to sold
      await updateWastePost(wastePostId, {'status': 'sold'});

      // Reject all other bids for this waste post
      final bidIds = _prefs.getStringList('bid_list') ?? [];
      for (final id in bidIds) {
        if (id != bidId) {
          final bidJson = _prefs.getString('bid_$id');
          if (bidJson != null) {
            final bid = BidModel.fromJson(jsonDecode(bidJson));
            if (bid.wastePostId == wastePostId && bid.status == 'active') {
              await updateBid(id, {'status': 'rejected', 'respondedAt': DateTime.now()});
            }
          }
        }
      }
    } catch (e) {
      throw Exception('Error accepting bid: $e');
    }
  }

  /// Reject bid
  Future<void> rejectBid(String bidId) async {
    try {
      await updateBid(bidId, {'status': 'rejected', 'respondedAt': DateTime.now()});
    } catch (e) {
      throw Exception('Error rejecting bid: $e');
    }
  }

  /// Cancel bid
  Future<void> cancelBid(String bidId) async {
    try {
      await updateBid(bidId, {'status': 'cancelled', 'respondedAt': DateTime.now()});
    } catch (e) {
      throw Exception('Error cancelling bid: $e');
    }
  }

  // ========== ORDERS OPERATIONS ==========

  /// Create order
  Future<String> createOrder(OrderModel order) async {
    try {
      final orderWithId = order.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      final orderJson = jsonEncode(orderWithId.toJson());
      await _prefs.setString('order_${orderWithId.id}', orderJson);

      // Add to orders list
      List<String> orderIds = _prefs.getStringList('order_list') ?? [];
      orderIds.add(orderWithId.id);
      await _prefs.setStringList('order_list', orderIds);

      return orderWithId.id;
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  /// Get orders by user (buyer or seller)
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      final orderIds = _prefs.getStringList('order_list') ?? [];
      final orders = <OrderModel>[];

      for (final id in orderIds) {
        final orderJson = _prefs.getString('order_$id');
        if (orderJson != null) {
          final order = OrderModel.fromJson(jsonDecode(orderJson));
          if (order.buyerId == userId || order.sellerId == userId) {
            orders.add(order);
          }
        }
      }

      return orders;
    } catch (e) {
      throw Exception('Error fetching user orders: $e');
    }
  }

  /// Update order
  Future<void> updateOrder(String orderId, Map<String, dynamic> updates) async {
    try {
      final orderJson = _prefs.getString('order_$orderId');
      if (orderJson == null) throw Exception('Order not found');

      final order = OrderModel.fromJson(jsonDecode(orderJson));
      final updatedOrder = order.copyWith(
        status: updates['status'] ?? order.status,
        updatedAt: DateTime.now(),
      );

      final updatedOrderJson = jsonEncode(updatedOrder.toJson());
      await _prefs.setString('order_$orderId', updatedOrderJson);
    } catch (e) {
      throw Exception('Error updating order: $e');
    }
  }

  // ========== UTILITY OPERATIONS ==========

  /// Clear all data (for testing/logout)
  Future<void> clearAllData() async {
    try {
      await _prefs.clear();
    } catch (e) {
      throw Exception('Error clearing data: $e');
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _prefs.remove('current_user_id');
    } catch (e) {
      throw Exception('Error logging out: $e');
    }
  }

  /// Get data size (for debugging)
  int getDataSize() {
    return _prefs.getKeys().length;
  }
}
