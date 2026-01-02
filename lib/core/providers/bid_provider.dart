// Bid Provider for state management
import 'package:flutter/material.dart';
import '../../models/bid_model.dart';
import '../../services/bid_service.dart';

class BidProvider extends ChangeNotifier {
  final BidService _bidService = BidService();

  // State variables
  List<BidModel> _bidsForWastePost = [];
  List<BidModel> _myBids = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<BidModel> get bidsForWastePost => _bidsForWastePost;
  List<BidModel> get myBids => _myBids;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ========== FETCH OPERATIONS ==========

  /// Load all active bids for a waste post
  Future<void> fetchBidsForWastePost(String wastePostId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bidsForWastePost =
          await _bidService.getBidsForWastePost(wastePostId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all bids (active, rejected, accepted) for a waste post
  Future<void> fetchAllBidsForWastePost(String wastePostId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bidsForWastePost =
          await _bidService.getAllBidsForWastePost(wastePostId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load all bids placed by the current processor
  Future<void> fetchMyBids(String processorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _myBids = await _bidService.getBidsByProcessor(processorId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ========== ACTION OPERATIONS ==========

  /// Place a new bid on a waste post
  Future<bool> placeBid({
    required String wastePostId,
    required String bidderId,
    required String bidderName,
    required String bidderPhone,
    required double bidAmount,
    required double totalBidAmount,
    required String message,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final bidId = await _bidService.placeBid(
        wastePostId: wastePostId,
        bidderId: bidderId,
        bidderName: bidderName,
        bidderPhone: bidderPhone,
        bidAmount: bidAmount,
        totalBidAmount: totalBidAmount,
        message: message,
      );

      // Add the new bid to the list
      _bidsForWastePost.add(
        BidModel(
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
        ),
      );

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Accept a bid
  Future<bool> acceptBid({
    required String bidId,
    required String wastePostId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bidService.acceptBid(bidId: bidId, wastePostId: wastePostId);

      // Update the bid in the list
      final index = _bidsForWastePost.indexWhere((b) => b.id == bidId);
      if (index != -1) {
        _bidsForWastePost[index] =
            _bidsForWastePost[index].copyWith(status: 'accepted');
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Reject a bid
  Future<bool> rejectBid(String bidId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bidService.rejectBid(bidId);

      // Update the bid in the list
      final index = _bidsForWastePost.indexWhere((b) => b.id == bidId);
      if (index != -1) {
        _bidsForWastePost[index] =
            _bidsForWastePost[index].copyWith(status: 'rejected');
      }

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Cancel a bid (bidder can cancel)
  Future<bool> cancelBid(String bidId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bidService.cancelBid(bidId);

      // Remove from myBids list
      _myBids.removeWhere((b) => b.id == bidId);

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  /// Update an active bid
  Future<bool> updateBid({
    required String bidId,
    required double bidAmount,
    required double totalBidAmount,
    required String message,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _bidService.updateBid(
        bidId: bidId,
        bidAmount: bidAmount,
        totalBidAmount: totalBidAmount,
        message: message,
      );

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  // ========== UTILITY OPERATIONS ==========

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _bidsForWastePost = [];
    _myBids = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Get highest bid
  BidModel? getHighestBid() {
    if (_bidsForWastePost.isEmpty) return null;
    _bidsForWastePost.sort((a, b) => b.bidAmount.compareTo(a.bidAmount));
    return _bidsForWastePost.first;
  }

  /// Get bid count
  int getBidCount(String wastePostId) {
    return _bidsForWastePost.where((b) => b.wastePostId == wastePostId).length;
  }
}
