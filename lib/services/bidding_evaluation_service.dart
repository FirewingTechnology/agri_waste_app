import '../models/bid_model.dart';
import '../models/user_model.dart';
import '../models/waste_model.dart';
import '../core/constants/app_constants.dart';

/// Enhanced Bidding Service with Rating-Based Evaluation
/// Evaluates bids based on price and manufacturer rating
class BiddingEvaluationService {
  /// Calculate a bid score based on multiple factors
  /// Higher score = better bid
  /// 
  /// Factors:
  /// 1. Bid Amount (40% weight) - Lower is better for farmer
  /// 2. Manufacturer Rating (40% weight) - Higher is better
  /// 3. Response Time (20% weight) - Faster is better
  double calculateBidScore({
    required BidModel bid,
    required UserModel manufacturer,
    required WasteModel wastePost,
  }) {
    // 1. Price Score (0-40 points)
    // Lower bid amount = higher score
    double maxPrice = (wastePost.pricePerKg ?? 0) * 1.5; // 150% of expected price
    double minPrice = (wastePost.pricePerKg ?? 0) * 0.5; // 50% of expected price
    
    double priceScore = 0;
    if (maxPrice > minPrice) {
      // Normalize price to 0-40 scale (inverted: lower price = higher score)
      double normalizedPrice = (maxPrice - bid.bidAmount) / (maxPrice - minPrice);
      priceScore = normalizedPrice * 40;
    }

    // 2. Rating Score (0-40 points)
    // Higher rating = higher score (rating is 0-5, multiply by 8 to get 0-40)
    double ratingScore = (manufacturer.rating / 5.0) * 40;

    // 3. Response Time Score (0-20 points)
    // Faster response = higher score
    Duration responseTime = bid.createdAt.difference(wastePost.createdAt);
    double hoursSincePosted = responseTime.inHours.toDouble();
    
    double responseScore = 20;
    if (hoursSincePosted > 0) {
      // Decay response score over time (full score in first hour, decays to 5 after 24h)
      responseScore = 20 - (hoursSincePosted / 24) * 15;
      responseScore = responseScore.clamp(5, 20); // Min 5, Max 20
    }

    // Total Score (0-100)
    return priceScore + ratingScore + responseScore;
  }

  /// Rank all bids for a waste post
  /// Returns sorted list with highest score first
  Future<List<BidWithScore>> evaluateAndRankBids({
    required List<BidModel> bids,
    required Map<String, UserModel> manufacturers,
    required WasteModel wastePost,
  }) async {
    List<BidWithScore> scoredBids = [];

    for (var bid in bids) {
      UserModel? manufacturer = manufacturers[bid.bidderId];
      
      if (manufacturer != null) {
        double score = calculateBidScore(
          bid: bid,
          manufacturer: manufacturer,
          wastePost: wastePost,
        );

        scoredBids.add(BidWithScore(
          bid: bid,
          manufacturer: manufacturer,
          score: score,
        ));
      }
    }

    // Sort by score (highest first)
    scoredBids.sort((a, b) => b.score.compareTo(a.score));

    return scoredBids;
  }

  /// Get bid recommendation with reasoning
  BidRecommendation getRecommendation(BidWithScore topBid) {
    String reason = '';
    List<String> strengths = [];
    List<String> considerations = [];

    // Analyze the top bid
    if (topBid.manufacturer.rating >= 4.0) {
      strengths.add('Highly rated manufacturer (${topBid.manufacturer.rating.toStringAsFixed(1)}⭐)');
    } else if (topBid.manufacturer.rating >= 3.0) {
      considerations.add('Average manufacturer rating (${topBid.manufacturer.rating.toStringAsFixed(1)}⭐)');
    } else {
      considerations.add('Lower manufacturer rating (${topBid.manufacturer.rating.toStringAsFixed(1)}⭐)');
    }

    if (topBid.manufacturer.ratingCount > 10) {
      strengths.add('Experienced with ${topBid.manufacturer.ratingCount}+ orders');
    }

    if (topBid.manufacturer.verified) {
      strengths.add('Verified manufacturer ✓');
    } else {
      considerations.add('Manufacturer not yet verified');
    }

    // Build reason
    if (strengths.isNotEmpty) {
      reason = 'Recommended: ${strengths.join(', ')}';
      if (considerations.isNotEmpty) {
        reason += '. Note: ${considerations.join(', ')}';
      }
    } else {
      reason = 'Consider: ${considerations.join(', ')}';
    }

    return BidRecommendation(
      bidWithScore: topBid,
      isRecommended: topBid.score >= 60 && topBid.manufacturer.verified,
      reason: reason,
      strengths: strengths,
      considerations: considerations,
    );
  }

  /// Calculate delivery charge based on distance
  double calculateDeliveryCharge(double distanceKm) {
    if (distanceKm > AppConstants.maxDeliveryDistance) {
      throw Exception('Delivery distance exceeds maximum ${AppConstants.maxDeliveryDistance} km');
    }

    double charge = distanceKm * AppConstants.deliveryChargePerKm;
    
    // Apply minimum charge
    if (charge < AppConstants.minDeliveryCharge) {
      charge = AppConstants.minDeliveryCharge;
    }

    return charge;
  }

  /// Validate bid amount
  bool isBidAmountValid(double bidAmount, WasteModel wastePost) {
    double? expectedPrice = wastePost.pricePerKg;
    
    if (expectedPrice == null) {
      return true; // No price expectation, any bid is valid
    }

    // Bid should be within reasonable range (50% to 150% of expected price)
    double minValid = expectedPrice * 0.5;
    double maxValid = expectedPrice * 1.5;

    return bidAmount >= minValid && bidAmount <= maxValid;
  }

  /// Check if manufacturer is eligible to bid
  bool isManufacturerEligibleToBid(UserModel manufacturer) {
    // Must be verified to place bids
    if (!manufacturer.verified) {
      return false;
    }

    // Must have Manufacturer role
    if (manufacturer.role != AppConstants.manufacturerRole && 
        manufacturer.role != AppConstants.processorRole) {
      return false;
    }

    return true;
  }
}

/// Helper class to hold bid with calculated score
class BidWithScore {
  final BidModel bid;
  final UserModel manufacturer;
  final double score;

  BidWithScore({
    required this.bid,
    required this.manufacturer,
    required this.score,
  });

  String get scoreGrade {
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  String get scoreDescription {
    if (score >= 80) return 'Excellent';
    if (score >= 70) return 'Very Good';
    if (score >= 60) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Poor';
  }
}

/// Bid recommendation with reasoning
class BidRecommendation {
  final BidWithScore bidWithScore;
  final bool isRecommended;
  final String reason;
  final List<String> strengths;
  final List<String> considerations;

  BidRecommendation({
    required this.bidWithScore,
    required this.isRecommended,
    required this.reason,
    required this.strengths,
    required this.considerations,
  });
}
