// User model for storing user data
// Used in Firebase Firestore and local state management

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'Farmer', 'Manufacturer', or 'Admin'
  final String? address;
  final String? location; // For delivery purposes
  final bool verified; // Admin verification status
  final double rating; // User rating (1-5)
  final int ratingCount; // Number of ratings received
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.address,
    this.location,
    this.verified = false,
    this.rating = 0.0,
    this.ratingCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'address': address,
      'location': location,
      'verified': verified ? 1 : 0,
      'rating': rating,
      'rating_count': ratingCount,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // Create from Firestore JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'Farmer',
      address: json['address'],
      location: json['location'],
      verified: (json['verified'] ?? 0) == 1,
      rating: (json['rating'] ?? 0.0).toDouble(),
      ratingCount: json['rating_count'] ?? json['ratingCount'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'])
          : (json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now()),
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'])
          : (json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'])
              : null),
    );
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? address,
    String? location,
    bool? verified,
    double? rating,
    int? ratingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      address: address ?? this.address,
      location: location ?? this.location,
      verified: verified ?? this.verified,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
