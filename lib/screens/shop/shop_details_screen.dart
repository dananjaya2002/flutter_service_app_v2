import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/chat_provider.dart';
import '../chat/chat_screen.dart';

class ShopDetailsScreen extends StatefulWidget {
  final ShopModel shop;

  const ShopDetailsScreen({super.key, required this.shop});

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  bool _isLoading = true;
  bool _isFavorite = false;
  ShopModel? _shop;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadShopDetails();
  }

  Future<void> _loadShopDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final shopProvider = Provider.of<ShopProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final favoriteProvider = Provider.of<FavoriteProvider>(
        context,
        listen: false,
      );

      final shop = await shopProvider.getShopById(widget.shop.id);
      if (shop == null) {
        setState(() {
          _errorMessage = 'Shop not found';
          _isLoading = false;
        });
        return;
      }

      final userId = userProvider.user?.uid;
      bool isFavorite = false;
      if (userId != null) {
        isFavorite = await favoriteProvider.isShopFavorited(
          userId,
          widget.shop.id,
        );
      }

      if (mounted) {
        setState(() {
          _shop = shop;
          _isFavorite = isFavorite;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load shop details: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final favoriteProvider = Provider.of<FavoriteProvider>(
      context,
      listen: false,
    );
    final userId = userProvider.user?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add favorites')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isFavorite) {
        await favoriteProvider.removeFromFavorites(userId, widget.shop.id);
      } else {
        await favoriteProvider.addToFavorites(userId, widget.shop.id);
      }

      setState(() {
        _isFavorite = !_isFavorite;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating favorites: $e')));
    }
  }

  Future<void> _startChat() async {
    if (_shop == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final userId = userProvider.user?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to start a conversation')),
      );
      return;
    }

    if (userId == _shop!.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot chat with yourself')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final chatId = await chatProvider.createOrGetChat(
        _shop!.id,
        userId,
        _shop!.ownerId,
        
      );

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ChatScreen(chatId: chatId)),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error starting chat: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shop.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
            color: _isFavorite ? Colors.red : null,
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                ? _buildErrorWidget()
                : _buildShopDetails(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_errorMessage!, style: TextStyle(color: Colors.red.shade700)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadShopDetails,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildShopDetails() {
    final shop = _shop!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shop Image or Placeholder
        shop.imageUrl != null
            ? Image.network(
              shop.imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.store, size: 50, color: Colors.white),
                );
              },
            )
            : Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.store, size: 50, color: Colors.white),
            ),
        const SizedBox(height: 16),

        // Shop Name and Rating
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                shop.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              children:
                  List.generate(
                    shop.rating.round(),
                    (index) =>
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                  ) +
                  List.generate(
                    5 - shop.rating.round(),
                    (index) => const Icon(
                      Icons.star_border,
                      color: Colors.amber,
                      size: 20,
                    ),
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '${shop.rating.toStringAsFixed(1)} (${shop.reviewCount})',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Description
        const Text(
          'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          shop.description ?? 'No description available',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),

        // Action Buttons: Call, Chat, Map, Share
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(Icons.call, 'Call', () {}),
            _buildActionButton(Icons.chat, 'Chat', _startChat),
            _buildActionButton(Icons.map, 'Map', () {}),
            _buildActionButton(Icons.share, 'Share', () {}),
          ],
        ),
        const SizedBox(height: 16),

        // Services Section
        const Text(
          'Services',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shop.services.length,
            itemBuilder:
                (context, index) => _buildServiceCard(shop.services[index]),
          ),
        ),
        const SizedBox(height: 16),

        // Reviews Section
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildReview('John Doe', 'Great service and reasonable prices!', 4),
        _buildReview('Jane Smith', 'Highly recommend this shop.', 5),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        IconButton(icon: Icon(icon, size: 30), onPressed: onPressed),
        Text(label),
      ],
    );
  }

  Widget _buildServiceCard(String serviceName) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.image, size: 50),
            ),
            const SizedBox(height: 8),
            Text(
              serviceName,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'High-quality service.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(String name, String reviewText, int rating) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 20, child: Icon(Icons.person)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: List.generate(
                      rating,
                      (index) =>
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(reviewText),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
