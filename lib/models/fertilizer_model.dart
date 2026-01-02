// Fertilizer model for processed fertilizers
// Created by processors, viewed by farmers

class FertilizerModel {
  final String id;
  final String processorId;
  final String processorName;
  final String processorPhone;
  final String fertilizerName;
  final String fertilizerType;
  final double quantity; // in kg
  final double pricePerKg;
  final String description;
  final String location;
  final double? latitude;
  final double? longitude;
  final List<String> imageUrls;
  final bool deliveryAvailable;
  final String status; // 'available', 'sold', 'low_stock'
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> ingredients; // What waste was used
  final int? preparationDays; // Days to prepare
  final String? certifications; // Organic, etc.

  FertilizerModel({
    required this.id,
    required this.processorId,
    required this.processorName,
    required this.processorPhone,
    required this.fertilizerName,
    required this.fertilizerType,
    required this.quantity,
    required this.pricePerKg,
    required this.description,
    required this.location,
    this.latitude,
    this.longitude,
    this.imageUrls = const [],
    this.deliveryAvailable = true,
    this.status = 'available',
    required this.createdAt,
    this.updatedAt,
    this.ingredients = const [],
    this.preparationDays,
    this.certifications,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'processorId': processorId,
      'processorName': processorName,
      'processorPhone': processorPhone,
      'fertilizerName': fertilizerName,
      'fertilizerType': fertilizerType,
      'quantity': quantity,
      'pricePerKg': pricePerKg,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'deliveryAvailable': deliveryAvailable,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'ingredients': ingredients,
      'preparationDays': preparationDays,
      'certifications': certifications,
    };
  }

  // Create from Firestore JSON
  factory FertilizerModel.fromJson(Map<String, dynamic> json) {
    return FertilizerModel(
      id: json['id'] ?? '',
      processorId: json['processorId'] ?? '',
      processorName: json['processorName'] ?? '',
      processorPhone: json['processorPhone'] ?? '',
      fertilizerName: json['fertilizerName'] ?? '',
      fertilizerType: json['fertilizerType'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      pricePerKg: (json['pricePerKg'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      deliveryAvailable: json['deliveryAvailable'] ?? true,
      status: json['status'] ?? 'available',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      ingredients: List<String>.from(json['ingredients'] ?? []),
      preparationDays: json['preparationDays'],
      certifications: json['certifications'],
    );
  }

  // Copy with method
  FertilizerModel copyWith({
    String? id,
    String? processorId,
    String? processorName,
    String? processorPhone,
    String? fertilizerName,
    String? fertilizerType,
    double? quantity,
    double? pricePerKg,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    bool? deliveryAvailable,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? ingredients,
    int? preparationDays,
    String? certifications,
  }) {
    return FertilizerModel(
      id: id ?? this.id,
      processorId: processorId ?? this.processorId,
      processorName: processorName ?? this.processorName,
      processorPhone: processorPhone ?? this.processorPhone,
      fertilizerName: fertilizerName ?? this.fertilizerName,
      fertilizerType: fertilizerType ?? this.fertilizerType,
      quantity: quantity ?? this.quantity,
      pricePerKg: pricePerKg ?? this.pricePerKg,
      description: description ?? this.description,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      deliveryAvailable: deliveryAvailable ?? this.deliveryAvailable,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      ingredients: ingredients ?? this.ingredients,
      preparationDays: preparationDays ?? this.preparationDays,
      certifications: certifications ?? this.certifications,
    );
  }
}
