// Waste model for agricultural waste posts
// Created by farmers, viewed by processors

class WasteModel {
  final String id;
  final String farmerId;
  final String farmerName;
  final String farmerPhone;
  final String wasteType;
  final double quantity; // in kg
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;
  final double? pricePerKg;
  final String status; // 'available', 'sold', 'processing'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? processorId; // Who bought it
  final DateTime? soldAt;
  final int bidCount; // Number of active bids
  final bool isBiddingEnabled; // Allow bidding on this post

  WasteModel({
    required this.id,
    required this.farmerId,
    required this.farmerName,
    required this.farmerPhone,
    required this.wasteType,
    required this.quantity,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
    this.pricePerKg,
    this.status = 'available',
    required this.createdAt,
    this.updatedAt,
    this.processorId,
    this.soldAt,
    this.bidCount = 0,
    this.isBiddingEnabled = true,
  });

  // Convert to JSON for Database (SQLite uses snake_case)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmer_id': farmerId,
      'farmer_name': farmerName,
      'waste_type': wasteType,
      'quantity': quantity,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'image_url': imageUrls.isNotEmpty ? imageUrls.first : null, // Store first image
      'price_per_kg': pricePerKg,
      'status': status,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Create from Firestore JSON
  factory WasteModel.fromJson(Map<String, dynamic> json) {
    return WasteModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? json['farmer_id'] ?? '',
      farmerName: json['farmerName'] ?? json['farmer_name'] ?? '',
      farmerPhone: json['farmerPhone'] ?? json['farmer_phone'] ?? '',
      wasteType: json['wasteType'] ?? json['waste_type'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrls: json['imageUrls'] is String
          ? (json['imageUrls'] as String).split(',').where((s) => s.isNotEmpty).toList()
          : List<String>.from(json['imageUrls'] ?? json['image_url'] != null ? [json['image_url']] : []),
      pricePerKg: json['pricePerKg'] != null 
          ? (json['pricePerKg'] as num).toDouble()
          : json['price_per_kg'] != null 
              ? (json['price_per_kg'] as num).toDouble()
              : null,
      status: json['status'] ?? 'available',
      createdAt: json['createdAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['createdAt'])
          : (json['created_at'] is int
              ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
              : (json['createdAt'] != null
                  ? DateTime.parse(json['createdAt'])
                  : DateTime.now())),
      updatedAt: json['updatedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'])
          : (json['updated_at'] is int && json['updated_at'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'])
              : (json['updatedAt'] != null
                  ? DateTime.parse(json['updatedAt'])
                  : null)),
      processorId: json['processorId'] ?? json['processor_id'],
      soldAt: json['soldAt'] is int && json['soldAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['soldAt'])
          : (json['sold_at'] is int && json['sold_at'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['sold_at'])
              : (json['soldAt'] != null
                  ? DateTime.parse(json['soldAt'])
                  : null)),
      bidCount: json['bidCount'] ?? json['bid_count'] ?? 0,
      isBiddingEnabled: json['isBiddingEnabled'] is int
          ? json['isBiddingEnabled'] == 1
          : (json['is_bidding_enabled'] is int
              ? json['is_bidding_enabled'] == 1
              : (json['isBiddingEnabled'] ?? true)),
    );
  }

  // Copy with method
  WasteModel copyWith({
    String? id,
    String? farmerId,
    String? farmerName,
    String? farmerPhone,
    String? wasteType,
    double? quantity,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    double? pricePerKg,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? processorId,
    DateTime? soldAt,
    int? bidCount,
    bool? isBiddingEnabled,
  }) {
    return WasteModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      wasteType: wasteType ?? this.wasteType,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      processorId: processorId ?? this.processorId,
      soldAt: soldAt ?? this.soldAt,
      bidCount: bidCount ?? this.bidCount,
      isBiddingEnabled: isBiddingEnabled ?? this.isBiddingEnabled,
    );
  }
}
