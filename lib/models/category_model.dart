import 'dart:convert';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
  });

  static List<CategoryModel> get defaultCategories => [
    CategoryModel(
      id: '1',
      name: 'Electrician',
      description: 'Professional electrical services and repairs',
      imageUrl: 'assets/icons/electrician.png',
      sortOrder: 1,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '2',
      name: 'Plumber',
      description: 'Expert plumbing services and maintenance',
      imageUrl: 'assets/icons/plumber.png',
      sortOrder: 2,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '3',
      name: 'Carpenter',
      description: 'Custom woodwork and furniture repairs',
      imageUrl: 'assets/icons/carpenter.png',
      sortOrder: 3,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '4',
      name: 'Painter',
      description: 'Professional painting services',
      imageUrl: 'assets/icons/painter.png',
      sortOrder: 4,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '5',
      name: 'AC Repair',
      description: 'Air conditioning maintenance and repairs',
      imageUrl: 'assets/icons/ac-repair.png',
      sortOrder: 5,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '6',
      name: 'Cleaning',
      description: 'Professional cleaning services',
      imageUrl: 'assets/icons/cleaning.png',
      sortOrder: 6,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    CategoryModel(
      id: '7',
      name: 'Gardening',
      description: 'Expert gardening and landscaping services',
      imageUrl: 'assets/icons/gardening.png',
      sortOrder: 7,
      isActive: true,
      createdAt: DateTime.now(),
    ),    
    CategoryModel(
      id: '8',
      name: 'Mason',
      description: 'Professional masonry services',
      imageUrl: 'assets/icons/mason.png',
      sortOrder: 8,
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];

  factory CategoryModel.fromJson(String str) =>
      CategoryModel.fromMap(json.decode(str) as Map<String, dynamic>);

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      imageUrl: map['imageUrl'] as String,
      sortOrder: map['sortOrder'] as int,
      isActive: map['isActive'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
