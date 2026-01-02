// Bid Service for managing bids in SQLite Database
import '../models/bid_model.dart';
import 'database_service.dart';

class BidService {
  final DatabaseService _db = DatabaseService();

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
      final bid = BidModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
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

      await _db.insertBid(bid);
      return bid.id;
    } catch (e) {
      throw Exception('Error placing bid: $e');
    }
  }

  // ========== READ OPERATIONS ==========

  /// Get all bids for a specific waste post
  Future<List<BidModel>> getBidsForWastePost(String wastePostId) async {
    try {
      final allBids = await _db.getBidsByWasteId(wastePostId);
      return allBids.where((bid) => bid.status == 'active').toList()
        ..sort((a, b) => b.bidAmount.compareTo(a.bidAmount));
    } catch (e) {
      throw Exception('Error fetching bids: $e');
    }
  }

  /// Get all bids for a specific waste post (including rejected/accepted)
  Future<List<BidModel>> getAllBidsForWastePost(String wastePostId) async {
    try {
      final bids = await _db.getBidsByWasteId(wastePostId);
      return bids..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Error fetching all bids: $e');
    }
  }

  /// Get all bids placed by a specific processor (bidder)
  Future<List<BidModel>> getBidsByProcessor(String processorId) async {
    try {
      final bids = await _db.getBidsByManufacturerId(processorId);
      return bids..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Error fetching processor bids: $e');
    }
  }

  /// Get a single bid by ID
  Future<BidModel> getBidById(String bidId) async {
    try {
      final bid = await _db.getBidById(bidId);
      if (bid == null) {
        throw Exception('Bid not found');
      }
      return bid;
    } catch (e) {
      throw Exception('Error fetching bid: $e');
    }
  }

  /// Get active bids (count) for a waste post
  Future<int> getActiveBidCount(String wastePostId) async {
    try {
      final allBids = await _db.getBidsByWasteId(wastePostId);
      return allBids.where((bid) => bid.status == 'active').length;
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
      final bid = await _db.getBidById(bidId);
      if (bid != null) {
        final updatedBid = bid.copyWith(
          status: 'accepted',
          respondedAt: DateTime.now(),
        );
        await _db.updateBid(updatedBid);
      }

      // Update waste post status to sold
      final wastePost = await _db.getWastePostById(wastePostId);
      if (wastePost != null) {
        final updatedPost = wastePost.copyWith(
          status: 'sold',
          soldAt: DateTime.now(),
        );
        await _db.updateWastePost(updatedPost);
      }

      // Reject all other bids for this waste post
      await rejectOtherBids(wastePostId, bidId);
    } catch (e) {
      throw Exception('Error accepting bid: $e');
    }
  }

  /// Reject a bid
  Future<void> rejectBid(String bidId) async {
    try {
      final bid = await _db.getBidById(bidId);
      if (bid != null) {
        final updatedBid = bid.copyWith(
          status: 'rejected',
          respondedAt: DateTime.now(),
        );
        await _db.updateBid(updatedBid);
      }
    } catch (e) {
      throw Exception('Error rejecting bid: $e');
    }
  }

  /// Reject all other bids for a waste post (when one is accepted)
  Future<void> rejectOtherBids(String wastePostId, String acceptedBidId) async {
    try {
      final allBids = await _db.getBidsByWasteId(wastePostId);
      for (final bid in allBids) {
        if (bid.id != acceptedBidId && bid.status == 'active') {
          final updatedBid = bid.copyWith(
            status: 'rejected',
            respondedAt: DateTime.now(),
          );
          await _db.updateBid(updatedBid);
        }
      }
    } catch (e) {
      throw Exception('Error rejecting other bids: $e');
    }
  }

  /// Cancel a bid (bidder can cancel before acceptance)
  Future<void> cancelBid(String bidId) async {
    try {
      final bid = await _db.getBidById(bidId);
      if (bid != null) {
        final updatedBid = bid.copyWith(
          status: 'cancelled',
          respondedAt: DateTime.now(),
        );
        await _db.updateBid(updatedBid);
      }
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
      final bid = await _db.getBidById(bidId);
      if (bid != null) {
        final updatedBid = bid.copyWith(
          bidAmount: bidAmount,
          totalBidAmount: totalBidAmount,
          message: message,
        );
        await _db.updateBid(updatedBid);
      }
    } catch (e) {
      throw Exception('Error updating bid: $e');
    }
  }

  // ========== DELETE OPERATIONS ==========

  /// Delete a bid (usually for rejected/cancelled bids)
  Future<void> deleteBid(String bidId) async {
    try {
      await _db.deleteBid(bidId);
    } catch (e) {
      throw Exception('Error deleting bid: $e');
    }
  }
}

