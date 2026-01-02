// Order model for tracking transactions
// Used for both waste purchases and fertilizer sales

class OrderModel {
  final String id;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final String itemId; // Waste ID or Fertilizer ID
  final String itemType; // 'waste' or 'fertilizer'
  final String itemName;
  final double quantity;
  final double pricePerKg;
  final double totalPrice;
  final double deliveryCharge;
  final double finalAmount;
  final String status; // 'Posted', 'Accepted', 'Picked', 'Delivered', 'Completed', 'Cancelled'
  final String deliveryAddress;
  final double? distance; // in km
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.itemId,
    required this.itemType,
    required this.itemName,
    required this.quantity,
    required this.pricePerKg,
    required this.totalPrice,
    this.deliveryCharge = 0,
    required this.finalAmount,
    this.status = 'pending',
    required this.deliveryAddress,
    this.distance,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyerId': buyerId,
      'buyerName': buyerName,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'itemId': itemId,
      'itemType': itemType,
      'itemName': itemName,
      'quantity': quantity,
      'pricePerKg': pricePerKg,
      'totalPrice': totalPrice,
      'deliveryCharge': deliveryCharge,
      'finalAmount': finalAmount,
      'status': status,
      'deliveryAddress': deliveryAddress,
      'distance': distance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
    };
  }

  // Create from Firestore JSON
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      buyerId: json['buyerId'] ?? '',
      buyerName: json['buyerName'] ?? '',
      sellerId: json['sellerId'] ?? '',
      sellerName: json['sellerName'] ?? '',
      itemId: json['itemId'] ?? '',
      itemType: json['itemType'] ?? 'waste',
      itemName: json['itemName'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      pricePerKg: (json['pricePerKg'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      deliveryCharge: (json['deliveryCharge'] ?? 0).toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      deliveryAddress: json['deliveryAddress'] ?? '',
      distance: json['distance']?.toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
    );
  }

  // Copy with method for creating updated instances
  OrderModel copyWith({
    String? id,
    String? buyerId,
    String? buyerName,
    String? sellerId,
    String? sellerName,
    String? itemId,
    String? itemType,
    String? itemName,
    double? quantity,
    double? pricePerKg,
    double? totalPrice,
    double? deliveryCharge,
    double? finalAmount,
    String? status,
    String? deliveryAddress,
    double? distance,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      buyerName: buyerName ?? this.buyerName,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      itemId: itemId ?? this.itemId,
      itemType: itemType ?? this.itemType,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      totalPrice: totalPrice ?? this.totalPrice,
      deliveryCharge: deliveryCharge ?? this.deliveryCharge,
      finalAmount: finalAmount ?? this.finalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      distance: distance ?? this.distance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}
