// Bid model for waste bidding system
// Processors place bids on waste posts by farmers

class BidModel {
  final String id;
  final String wastePostId; // Reference to WasteModel
  final String bidderId; // Processor ID
  final String bidderName;
  final String bidderPhone;
  final double bidAmount; // Price per kg
  final double totalBidAmount; // bidAmount * quantity
  final String message; // Bidder's message/offer details
  final String status; // 'active', 'accepted', 'rejected', 'cancelled'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? respondedAt;

  BidModel({
    required this.id,
    required this.wastePostId,
    required this.bidderId,
    required this.bidderName,
    required this.bidderPhone,
    required this.bidAmount,
    required this.totalBidAmount,
    required this.message,
    this.status = 'active',
    required this.createdAt,
    this.updatedAt,
    this.respondedAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wastePostId': wastePostId,
      'bidderId': bidderId,
      'bidderName': bidderName,
      'bidderPhone': bidderPhone,
      'bidAmount': bidAmount,
      'totalBidAmount': totalBidAmount,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  // Create from Firestore JSON
  factory BidModel.fromJson(Map<String, dynamic> json) {
    return BidModel(
      id: json['id'] ?? '',
      wastePostId: json['wastePostId'] ?? '',
      bidderId: json['bidderId'] ?? '',
      bidderName: json['bidderName'] ?? '',
      bidderPhone: json['bidderPhone'] ?? '',
      bidAmount: (json['bidAmount'] ?? 0).toDouble(),
      totalBidAmount: (json['totalBidAmount'] ?? 0).toDouble(),
      message: json['message'] ?? '',
      status: json['status'] ?? 'active',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'])
          : null,
    );
  }

  // Copy with method for creating updated instances
  BidModel copyWith({
    String? id,
    String? wastePostId,
    String? bidderId,
    String? bidderName,
    String? bidderPhone,
    double? bidAmount,
    double? totalBidAmount,
    String? message,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? respondedAt,
  }) {
    return BidModel(
      id: id ?? this.id,
      wastePostId: wastePostId ?? this.wastePostId,
      bidderId: bidderId ?? this.bidderId,
      bidderName: bidderName ?? this.bidderName,
      bidderPhone: bidderPhone ?? this.bidderPhone,
      bidAmount: bidAmount ?? this.bidAmount,
      totalBidAmount: totalBidAmount ?? this.totalBidAmount,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
