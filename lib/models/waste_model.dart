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

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'wasteType': wasteType,
      'quantity': quantity,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'pricePerKg': pricePerKg,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'processorId': processorId,
      'soldAt': soldAt?.toIso8601String(),
      'bidCount': bidCount,
      'isBiddingEnabled': isBiddingEnabled,
    };
  }

  // Create from Firestore JSON
  factory WasteModel.fromJson(Map<String, dynamic> json) {
    return WasteModel(
      id: json['id'] ?? '',
      farmerId: json['farmerId'] ?? '',
      farmerName: json['farmerName'] ?? '',
      farmerPhone: json['farmerPhone'] ?? '',
      wasteType: json['wasteType'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      pricePerKg: json['pricePerKg']?.toDouble(),
      status: json['status'] ?? 'available',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      processorId: json['processorId'],
      soldAt: json['soldAt'] != null
          ? DateTime.parse(json['soldAt'])
          : null,
      bidCount: json['bidCount'] ?? 0,
      isBiddingEnabled: json['isBiddingEnabled'] ?? true,
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
