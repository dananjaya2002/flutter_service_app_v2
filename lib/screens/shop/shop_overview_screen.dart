import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/shop_model.dart';
import '../../providers/shop_provider.dart';
import '../../providers/user_provider.dart';

class ShopOverviewScreen extends StatefulWidget {
  const ShopOverviewScreen({super.key});

  @override
  State<ShopOverviewScreen> createState() => _ShopOverviewScreenState();
}

class _ShopOverviewScreenState extends State<ShopOverviewScreen> {
  bool _isLoading = true;
  ShopModel? _shop;
  List<Map<String, dynamic>> _ratings = []; // Store ratings with user details
  int _agreementsCount = 0;
  int _unreadMessagesCount = 0;

  @override
  void initState() {
    super.initState();
    _loadShopData().then((_) {
      if (_shop != null) {
        _loadRatings();
        _loadAgreementsCount();
        _loadUnreadMessagesCount();
      }
    });
  }

  Future<void> _loadShopData() async {
    final userId = Provider.of<UserProvider>(context, listen: false).user!.uid;
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);

    try {
      final shop = await shopProvider.getShopByOwnerId(userId);
      setState(() {
        _shop = shop;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading shop data: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRatings() async {
    try {
      final ratingsSnapshot =
          await FirebaseFirestore.instance
              .collection('ratings')
              .where('shopId', isEqualTo: _shop!.id)
              .get();

      final List<Map<String, dynamic>> ratings = [];

      for (var doc in ratingsSnapshot.docs) {
        final ratingData = doc.data();
        final chatId = ratingData['chatId'];

        final chatSnapshot =
            await FirebaseFirestore.instance
                .collection('chats')
                .doc(chatId)
                .get();

        final chatData = chatSnapshot.data();
        final customerId = chatData?['customerId'];

        if (customerId != null) {
          final userSnapshot =
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(customerId)
                  .get();

          final userData = userSnapshot.data();
          ratings.add({
            'name': userData?['name'] ?? 'Anonymous',
            'profileImage': userData?['profileImage'],
            'rating': ratingData['rating'],
            'comment': ratingData['comment'],
          });
        }
      }

      setState(() {
        _ratings = ratings;
      });
    } catch (e) {
      print('Error loading ratings: $e');
    }
  }

  Future<void> _loadAgreementsCount() async {
    try {
      final agreementsSnapshot =
          await FirebaseFirestore.instance
              .collection('agreements')
              .where('ownerId', isEqualTo: _shop!.ownerId)
              .get();

      setState(() {
        _agreementsCount = agreementsSnapshot.docs.length;
      });
    } catch (e) {
      print('Error loading agreements count: $e');
    }
  }

  Future<void> _loadUnreadMessagesCount() async {
    try {
      final messagesSnapshot =
          await FirebaseFirestore.instance
              .collection('messages')
              .where('shopId', isEqualTo: _shop!.id)
              .where('isRead', isEqualTo: false)
              .get();

      setState(() {
        _unreadMessagesCount = messagesSnapshot.docs.length;
      });
    } catch (e) {
      print('Error loading unread messages count: $e');
    }
  }

  double _calculateAverageRating() {
    if (_ratings.isEmpty) return 0.0;

    final totalRating = _ratings.fold<double>(
      0.0,
      (sum, rating) => sum + (rating['rating'] as int),
    );

    return totalRating / _ratings.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_shop == null) {
      return const Scaffold(
        body: Center(child: Text('No shop found. Please create a shop first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_shop!.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShopDetails(),
            _buildShopOverview(),
            _buildEditButtons(),
            _buildServiceList(),
            _buildReviews(),
          ],
        ),
      ),
    );
  }

  Widget _buildShopDetails() {
    final shop = _shop!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              children: [
                ...List.generate(5, (index) {
                  final averageRating = _calculateAverageRating();
                  return Icon(
                    index < averageRating.floor()
                        ? Icons.star
                        : (index < averageRating
                            ? Icons.star_half
                            : Icons.star_border),
                    color: Colors.amber,
                    size: 20,
                  );
                }),
              ],
            ),
            const SizedBox(width: 8),
            Text(
              '${_calculateAverageRating().toStringAsFixed(1)} (${_ratings.length})',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }

  Widget _buildShopOverview() {
    final List<Map<String, String>> overviewItems = [
      {'label': 'Agreements', 'count': _agreementsCount.toString()},
      {
        'label': 'Avg Ratings',
        'count': _calculateAverageRating().toStringAsFixed(1),
      },
      {'label': 'Messages', 'count': _unreadMessagesCount.toString()},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue[50],
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
        ),
        itemCount: overviewItems.length,
        itemBuilder: (context, index) {
          final item = overviewItems[index];
          return _buildOverviewItem(item['label']!, item['count']!);
        },
      ),
    );
  }

  Widget _buildOverviewItem(String label, String count) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _showEditShopPopup,
            child: const Text('Edit Shop'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Services Offered',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: _showManageServicesPopup,
                child: const Text('Manage Services'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _shop!.services.length,
            itemBuilder: (context, index) {
              final service = _shop!.services[index];
              return _buildServiceItem(service);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(String service) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.3 * 255).toInt()),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build, size: 50, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              service,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Text(
            'Reviews',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        if (_ratings.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('No reviews yet.', style: TextStyle(fontSize: 16)),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ratings.length,
            itemBuilder: (context, index) {
              final rating = _ratings[index];
              return _buildReview(
                rating['name'],
                rating['comment'],
                rating['rating'],
                rating['profileImage'],
              );
            },
          ),
      ],
    );
  }

  Widget _buildReview(
    String name,
    String comment,
    int rating,
    String? profileImage,
  ) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage:
            profileImage != null ? NetworkImage(profileImage) : null,
        child: profileImage == null ? const Icon(Icons.person) : null,
      ),
      title: Text(name),
      subtitle: Text(comment),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.amber),
          const SizedBox(width: 4),
          Text(rating.toString()),
        ],
      ),
    );
  }

  void _showEditShopPopup() {
    final nameController = TextEditingController(text: _shop?.name);
    final descriptionController = TextEditingController(
      text: _shop?.description,
    );
    final imageUrlController = TextEditingController(text: _shop?.imageUrl);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Shop Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: imageUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Image URL',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'imageUrl': imageUrlController.text.trim(),
                };

                try {
                  await Provider.of<ShopProvider>(
                    context,
                    listen: false,
                  ).updateShop(_shop!.id, updatedData, null);

                  setState(() {
                    _shop = _shop!.copyWith(
                      name: updatedData['name'],
                      description: updatedData['description'],
                      imageUrl: updatedData['imageUrl'],
                    );
                  });

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shop details updated!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update shop: $e')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showManageServicesPopup() {
    final servicesController = TextEditingController();
    final List<String> services = List.from(_shop!.services);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Manage Services'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: servicesController,
                      decoration: const InputDecoration(
                        labelText: 'Add or Edit a Service',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(services[index]),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    servicesController.text = services[index];
                                    setState(() {
                                      services.removeAt(index);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      services.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (servicesController.text.trim().isNotEmpty) {
                      setState(() {
                        services.add(servicesController.text.trim());
                      });
                      servicesController.clear();
                    }

                    try {
                      await Provider.of<ShopProvider>(
                        context,
                        listen: false,
                      ).updateServices(_shop!.id, services);

                      setState(() {
                        _shop = _shop!.copyWith(services: services);
                      });

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Services updated!')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update services: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
