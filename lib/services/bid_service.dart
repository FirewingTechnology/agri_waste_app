// Bid Service for managing bids in Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bid_model.dart';

class BidService {
  static const String _bidsCollection = 'bids';
  static const String _wasteCollection = 'waste_posts';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== CREATE OPERATIONS ==========

  /// Place a new bid on a waste post
  Future<String> placeBid({
    required String wastePostId,
    required String bidderId,
    required String bidderName,
    required String bidderPhone,
    required double bidAmount,
    required double totalBidAmount,
    required String message,
  }) async {
    try {
      final docRef = _firestore.collection(_bidsCollection).doc();
      final bidId = docRef.id;

      final bid = BidModel(
        id: bidId,
        wastePostId: wastePostId,
        bidderId: bidderId,
        bidderName: bidderName,
        bidderPhone: bidderPhone,
        bidAmount: bidAmount,
        totalBidAmount: totalBidAmount,
        message: message,
        status: 'active',
        createdAt: DateTime.now(),
      );

      await docRef.set(bid.toJson());
      return bidId;
    } catch (e) {
      throw Exception('Error placing bid: $e');
    }
  }

  // ========== READ OPERATIONS ==========

  /// Get all bids for a specific waste post
  Future<List<BidModel>> getBidsForWastePost(String wastePostId) async {
    try {
      final query = await _firestore
          .collection(_bidsCollection)
          .where('wastePostId', isEqualTo: wastePostId)
          .where('status', isEqualTo: 'active')
          .orderBy('bidAmount', descending: true)
          .get();

      return query.docs.map((doc) => BidModel.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Error fetching bids: $e');
    }
  }

  /// Get all bids for a specific waste post (including rejected/accepted)
  Future<List<BidModel>> getAllBidsForWastePost(String wastePostId) async {
    try {
      final query = await _firestore
          .collection(_bidsCollection)
          .where('wastePostId', isEqualTo: wastePostId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => BidModel.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Error fetching all bids: $e');
    }
  }

  /// Get all bids placed by a specific processor (bidder)
  Future<List<BidModel>> getBidsByProcessor(String processorId) async {
    try {
      final query = await _firestore
          .collection(_bidsCollection)
          .where('bidderId', isEqualTo: processorId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) => BidModel.fromJson(doc.data())).toList();
    } catch (e) {
      throw Exception('Error fetching processor bids: $e');
    }
  }

  /// Get a single bid by ID
  Future<BidModel> getBidById(String bidId) async {
    try {
      final doc = await _firestore.collection(_bidsCollection).doc(bidId).get();
      if (!doc.exists) {
        throw Exception('Bid not found');
      }
      return BidModel.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Error fetching bid: $e');
    }
  }

  /// Get active bids (count) for a waste post
  Future<int> getActiveBidCount(String wastePostId) async {
    try {
      final query = await _firestore
          .collection(_bidsCollection)
          .where('wastePostId', isEqualTo: wastePostId)
          .where('status', isEqualTo: 'active')
          .count()
          .get();

      return query.count ?? 0;
    } catch (e) {
      throw Exception('Error fetching bid count: $e');
    }
  }

  // ========== UPDATE OPERATIONS ==========

  /// Accept a bid (respond to bid)
  Future<void> acceptBid({
    required String bidId,
    required String wastePostId,
  }) async {
    try {
      // Update the bid status
      await _firestore.collection(_bidsCollection).doc(bidId).update({
        'status': 'accepted',
        'updatedAt': DateTime.now().toIso8601String(),
        'respondedAt': DateTime.now().toIso8601String(),
      });

      // Update waste post status to sold
      await _firestore.collection(_wasteCollection).doc(wastePostId).update({
        'status': 'sold',
        'updatedAt': DateTime.now().toIso8601String(),
        'soldAt': DateTime.now().toIso8601String(),
      });

      // Reject all other bids for this waste post
      await rejectOtherBids(wastePostId, bidId);
    } catch (e) {
      throw Exception('Error accepting bid: $e');
    }
  }

  /// Reject a bid
  Future<void> rejectBid(String bidId) async {
    try {
      await _firestore.collection(_bidsCollection).doc(bidId).update({
        'status': 'rejected',
        'updatedAt': DateTime.now().toIso8601String(),
        'respondedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error rejecting bid: $e');
    }
  }

  /// Reject all other bids for a waste post (when one is accepted)
  Future<void> rejectOtherBids(String wastePostId, String acceptedBidId) async {
    try {
      final query = await _firestore
          .collection(_bidsCollection)
          .where('wastePostId', isEqualTo: wastePostId)
          .where('status', isEqualTo: 'active')
          .get();

      for (final doc in query.docs) {
        if (doc.id != acceptedBidId) {
          await doc.reference.update({
            'status': 'rejected',
            'updatedAt': DateTime.now().toIso8601String(),
            'respondedAt': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      throw Exception('Error rejecting other bids: $e');
    }
  }

  /// Cancel a bid (bidder can cancel before acceptance)
  Future<void> cancelBid(String bidId) async {
    try {
      await _firestore.collection(_bidsCollection).doc(bidId).update({
        'status': 'cancelled',
        'updatedAt': DateTime.now().toIso8601String(),
        'respondedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error cancelling bid: $e');
    }
  }

  /// Update bid amount and message (for active bids only)
  Future<void> updateBid({
    required String bidId,
    required double bidAmount,
    required double totalBidAmount,
    required String message,
  }) async {
    try {
      await _firestore.collection(_bidsCollection).doc(bidId).update({
        'bidAmount': bidAmount,
        'totalBidAmount': totalBidAmount,
        'message': message,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error updating bid: $e');
    }
  }

  // ========== DELETE OPERATIONS ==========

  /// Delete a bid (usually for rejected/cancelled bids)
  Future<void> deleteBid(String bidId) async {
    try {
      await _firestore.collection(_bidsCollection).doc(bidId).delete();
    } catch (e) {
      throw Exception('Error deleting bid: $e');
    }
  }

  // ========== STREAM OPERATIONS ==========

  /// Stream of all active bids for a waste post
  Stream<List<BidModel>> streamBidsForWastePost(String wastePostId) {
    try {
      return _firestore
          .collection(_bidsCollection)
          .where('wastePostId', isEqualTo: wastePostId)
          .where('status', isEqualTo: 'active')
          .orderBy('bidAmount', descending: true)
          .snapshots()
          .map((query) =>
              query.docs.map((doc) => BidModel.fromJson(doc.data())).toList());
    } catch (e) {
      throw Exception('Error streaming bids: $e');
    }
  }

  /// Stream of all bids placed by a processor
  Stream<List<BidModel>> streamBidsByProcessor(String processorId) {
    try {
      return _firestore
          .collection(_bidsCollection)
          .where('bidderId', isEqualTo: processorId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((query) =>
              query.docs.map((doc) => BidModel.fromJson(doc.data())).toList());
    } catch (e) {
      throw Exception('Error streaming processor bids: $e');
    }
  }
}
