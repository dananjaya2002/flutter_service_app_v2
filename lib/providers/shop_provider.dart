import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_model.dart';
import '../models/category_model.dart';
import '../models/comment_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';
import 'package:flutter/foundation.dart';

class ShopProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();
  final LocationService _locationService = LocationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ShopModel> _shops = [];
  List<CategoryModel> _categories = [];
  List<ShopModel> _filteredShops = [];
  String _selectedCategoryId = '';
  bool _isLoading = false;
  GeoPoint? _currentLocation;
  double _maxDistance = 10.0; // 10 km by default
  String? _errorMessage;

  List<ShopModel> get shops => _shops;
  List<CategoryModel> get categories => _categories;
  List<ShopModel> get filteredShops => _filteredShops;
  String get selectedCategoryId => _selectedCategoryId;
  bool get isLoading => _isLoading;
  GeoPoint? get currentLocation => _currentLocation;
  double get maxDistance => _maxDistance;
  String? get errorMessage => _errorMessage;

  // Initialize shop data
  void initialize() {
    _loadCategories();
    _loadShops();
  }

  // Load categories from Firestore
  void _loadCategories() {
    _databaseService.getCategories().listen((categories) {
      _categories = categories;
      notifyListeners();
    });
  }

  // Load shops from Firestore
  void _loadShops() {
    _isLoading = true;
    notifyListeners();

    _databaseService.getShops().listen((shops) {
      _shops = shops;
      _applyFilters();

      _isLoading = false;
      notifyListeners();
    });
  }

  // Filter shops by category
  void filterByCategory(String categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilters();
    notifyListeners();
  }

  // Filter shops by location
  Future<void> filterByCurrentLocation() async {
    try {
      _isLoading = true;
      notifyListeners();

      final position = await _locationService.getCurrentPosition();
      _currentLocation = _locationService.latLngToGeoPoint(
        _locationService.positionToLatLng(position),
      );

      _applyFilters();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error getting current location: $e');
      // Rethrow to allow UI to handle the error
      rethrow;
    }
  }

  // Set custom location
  void setCustomLocation(GeoPoint location) {
    _currentLocation = location;
    _applyFilters();
    notifyListeners();
  }

  // Set max distance for location filtering
  void setMaxDistance(double distance) {
    _maxDistance = distance;
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters (category and location)
  void _applyFilters() {
    List<ShopModel> result = List.from(_shops);

    // Apply category filter
    if (_selectedCategoryId.isNotEmpty) {
      result =
          result
              .where((shop) => shop.categories.contains(_selectedCategoryId))
              .toList();
    }

    // Apply location filter
    if (_currentLocation != null) {
      result = _filterShopsByDistance(result, _currentLocation!, _maxDistance);
    }

    _filteredShops = result;
  }

  // Helper method to filter shops by distance
  List<ShopModel> _filterShopsByDistance(
    List<ShopModel> shops,
    GeoPoint center,
    double maxDistance,
  ) {
    return shops.where((shop) {
      if (shop.location == null) return false;

      // Simple distance calculation
      final distance = _calculateDistanceBetween(center, shop.location!);
      return distance <= maxDistance;
    }).toList();
  }

  // Create a new shop
  Future<String> createShop(
    String name,
    String description,
    List<String> categories,
    GeoPoint location,
    String ownerId,
    File? imageFile,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Create shop with default values
      ShopModel shop = ShopModel(
        id: '',
        ownerId: ownerId,
        name: name,
        description: description,
        location: location,
        categories: categories,
        createdAt: Timestamp.now(),
      );

      // Upload shop image if provided
      String? imageUrl;
      if (imageFile != null) {
        // We need the shop ID first to organize storage, so save first, then update
        String shopId = await _databaseService.createShop(shop);

        imageUrl = await _storageService.uploadShopImage(imageFile, shopId);

        // Update shop with image URL
        await _databaseService.updateShop(shopId, {'imageUrl': imageUrl});

        _isLoading = false;
        notifyListeners();

        return shopId;
      } else {
        // Save shop without image
        String shopId = await _databaseService.createShop(shop);

        _isLoading = false;
        notifyListeners();

        return shopId;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error creating shop: $e');
      rethrow;
    }
  }

  // Update shop details
  Future<void> updateShop(
    String shopId,
    Map<String, dynamic> data,
    File? newImageFile,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Upload new image if provided
      if (newImageFile != null) {
        String imageUrl = await _storageService.uploadShopImage(
          newImageFile,
          shopId,
        );
        data['imageUrl'] = imageUrl;
      }

      await _databaseService.updateShop(shopId, data);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error updating shop: $e');
      rethrow;
    }
  }

  // Publish shop (make visible to customers)
  Future<void> publishShop(String shopId, bool isPublished) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _databaseService.updateShop(shopId, {'isPublished': isPublished});

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error publishing shop: $e');
      rethrow;
    }
  }

  // Add comment to shop
  Future<void> addComment(
    String shopId,
    String userId,
    String userName,
    String comment,
    double rating,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      CommentModel commentModel = CommentModel(
        id: '',
        shopId: shopId,
        userId: userId,
        userName: userName,
        comment: comment,
        rating: rating,
        timestamp: Timestamp.now(),
      );

      await _databaseService.addComment(commentModel);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error adding comment: $e');
      rethrow;
    }
  }

  // Get shop comments
  Stream<List<CommentModel>> getShopComments(String shopId) {
    return _databaseService.getShopComments(shopId);
  }

  // Get shop by ID
  Future<ShopModel?> getShopById(String shopId) async {
    try {
      return await _databaseService.getShopById(shopId);
    } catch (e) {
      print('Error getting shop by id: $e');
      return null;
    }
  }

  // Get shops owned by a user
  Stream<List<ShopModel>> getUserShops(String userId) {
    return _databaseService.getUserShops(userId);
  }

  // Load shops from Firestore
  Future<void> loadShops() async {
    try {
      final snapshot = await _firestore.collection('shops').get();
      _shops =
          snapshot.docs
              .map((doc) => ShopModel.fromMap({...doc.data(), 'id': doc.id}))
              .toList();
      notifyListeners();
    } catch (e) {
      print('Error loading shops: $e');
      rethrow;
    }
  }

  // Alias for loadShops to maintain compatibility
  Future<void> fetchShops() async {
    return loadShops();
  }

  // Load categories from Firestore
  Future<void> loadCategories() async {
    _setLoading(true);

    try {
      final categoriesData = await _databaseService.getCollection('categories');
      _categories =
          categoriesData.map((data) => CategoryModel.fromMap(data)).toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load categories: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  // Get category by ID
  CategoryModel? getCategoryById(String id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filter shops by category
  List<ShopModel> filterShopsByCategory(String categoryId) {
    return _shops
        .where((shop) => shop.categories.contains(categoryId))
        .toList();
  }

  // Filter shops by location
  List<ShopModel> filterShopsByLocation(
    GeoPoint userLocation,
    double maxDistance,
  ) {
    // This is a simplified distance calculation
    // For a real app, you would use a proper distance calculation algorithm
    return _shops.where((shop) {
      if (shop.location == null) return false;

      // Simplified distance calculation (not accurate for long distances)
      final lat1 = userLocation.latitude;
      final lon1 = userLocation.longitude;
      final lat2 = shop.location!.latitude;
      final lon2 = shop.location!.longitude;

      // Simple Euclidean distance (not accurate for real-world use)
      final distance = _calculateDistance(lat1, lon1, lat2, lon2);

      return distance <= maxDistance;
    }).toList();
  }

  // Search shops by name or description
  List<ShopModel> searchShops(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _shops.where((shop) {
      return shop.name.toLowerCase().contains(lowercaseQuery) ||
          (shop.description ?? '').toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Simplified distance calculation that only uses math library
  double _calculateDistanceSimple(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Simple Euclidean distance calculation (not accurate for long distances)
    double latDiff = lat1 - lat2;
    double lonDiff = lon1 - lon2;

    // Approximate distance in km (very rough estimate)
    return math.sqrt(latDiff * latDiff + lonDiff * lonDiff) * 111.0;
  }

  // Helper method for simple distance calculation
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Use the simplified method instead
    return _calculateDistanceSimple(lat1, lon1, lat2, lon2);
  }

  // Calculate distance between two GeoPoints in kilometers
  double _calculateDistanceBetween(GeoPoint point1, GeoPoint point2) {
    return _calculateDistanceSimple(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  // Initialize default categories if none exist
  Future<void> initializeDefaultCategories() async {
    try {
      final categories = await _databaseService.getCollection('categories');
      if (categories.isEmpty) {
        final defaultCategories = [
          {
            'name': 'Electrician',
            'description': 'Professional electrical services and repairs',
            'imageUrl': 'https://example.com/electrician.jpg',
            'sortOrder': 1,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Plumber',
            'description': 'Expert plumbing services and maintenance',
            'imageUrl': 'https://example.com/plumber.jpg',
            'sortOrder': 2,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Carpenter',
            'description': 'Custom woodwork and furniture repairs',
            'imageUrl': 'https://example.com/carpenter.jpg',
            'sortOrder': 3,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Painter',
            'description': 'Professional painting services',
            'imageUrl': 'https://example.com/painter.jpg',
            'sortOrder': 4,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'AC Repair',
            'description': 'Air conditioning maintenance and repairs',
            'imageUrl': 'https://example.com/ac-repair.jpg',
            'sortOrder': 5,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
          {
            'name': 'Cleaning',
            'description': 'Professional cleaning services',
            'imageUrl': 'https://example.com/cleaning.jpg',
            'sortOrder': 6,
            'isActive': true,
            'createdAt': Timestamp.now(),
          },
        ];

        for (var category in defaultCategories) {
          await _databaseService.addDocument('categories', category);
        }

        // Reload categories after adding
        await loadCategories();
      }
    } catch (e) {
      debugPrint('Error initializing default categories: $e');
    }
  }

  Future<void> addShop(ShopModel shop) async {
    try {
      final docRef = await _firestore.collection('shops').add(shop.toMap());
      final newShop = ShopModel.fromMap({...shop.toMap(), 'id': docRef.id});
      _shops.add(newShop);
      notifyListeners();
    } catch (e) {
      print('Error adding shop: $e');
      rethrow;
    }
  }

  Future<ShopModel?> getShopByOwnerId(String ownerId) async {
    try {
      final snapshot =
          await _firestore
              .collection('shops')
              .where('ownerId', isEqualTo: ownerId)
              .get();

      if (snapshot.docs.isEmpty) return null;

      return ShopModel.fromMap({
        ...snapshot.docs.first.data(),
        'id': snapshot.docs.first.id,
      });
    } catch (e) {
      print('Error getting shop by owner ID: $e');
      rethrow;
    }
  }

  Future<void> updateServices(String shopId, List<String> services) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Reference to the services subcollection
      final servicesRef = FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .collection('services');

      // Clear existing services
      final existingServices = await servicesRef.get();
      for (var doc in existingServices.docs) {
        await doc.reference.delete();
      }

      // Add updated services
      for (var service in services) {
        await servicesRef.add({'name': service, 'createdAt': Timestamp.now()});
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error updating services: $e');
      rethrow;
    }
  }

  Future<String?> getShopNameById(String shopId) async {
  try {
    final shopDoc = await FirebaseFirestore.instance
        .collection('shops')
        .doc(shopId)
        .get();

    if (shopDoc.exists) {
      return shopDoc.data()?['name'] as String?;
    }
    return null;
  } catch (e) {
    print('Error fetching shop name: $e');
    return null;
  }
}
}
