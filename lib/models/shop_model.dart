import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? phoneNumber;
  final GeoPoint? location;
  final List<String> categories;
  final double rating;
  final int reviewCount;
  final Timestamp createdAt;
  final bool isVerified;
  final bool isPublished;
  final List<String> services;

  ShopModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.imageUrl,
    this.phoneNumber,
    this.location,
    required this.categories,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.createdAt,
    this.isVerified = false,
    this.isPublished = true,
    this.services = const [],
  });

  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      imageUrl: map['imageUrl'],
      phoneNumber: map['phoneNumber'],
      location: map['location'],
      categories: List<String>.from(map['categories'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      createdAt: map['createdAt'] ?? Timestamp.now(),
      isVerified: map['isVerified'] ?? false,
      isPublished: map['isPublished'] ?? true,
      services: List<String>.from(map['services'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'phoneNumber': phoneNumber,
      'location': location,
      'categories': categories,
      'rating': rating,
      'reviewCount': reviewCount,
      'createdAt': createdAt,
      'isVerified': isVerified,
      'isPublished': isPublished,
      'services': services,
    };
  }

  ShopModel copyWith({
    String? name,
    String? description,
    String? imageUrl,
    String? phoneNumber,
    GeoPoint? location,
    List<String>? categories,
    double? rating,
    int? reviewCount,
    Timestamp? createdAt,
    bool? isVerified,
    bool? isPublished,
    List<String>? services,
  }) {
    return ShopModel(
      id: id,
      ownerId: ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      categories: categories ?? this.categories,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      createdAt: createdAt ?? this.createdAt,
      isVerified: isVerified ?? this.isVerified,
      isPublished: isPublished ?? this.isPublished,
      services: services ?? this.services,
    );
  }
}
