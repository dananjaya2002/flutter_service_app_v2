import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadShopData();
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
      appBar: AppBar(
        title: Text(_shop!.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditShopPopup,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoreHeader(),
            _buildShopOverview(),
            _buildEditButtons(),
            _buildServiceList(),
            _buildReviews(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader() {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageWidth = screenWidth * 0.95;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_shop!.imageUrl != null)
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _shop!.imageUrl!,
                width: imageWidth,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: imageWidth,
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Icon(
                      Icons.store,
                      size: 50,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          )
        else
          Center(
            child: Container(
              width: imageWidth,
              height: 200,
              color: Colors.grey.shade300,
              child: const Icon(Icons.store, size: 50, color: Colors.white),
            ),
          ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _shop!.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '${_shop!.rating.toStringAsFixed(1)} (${_shop!.reviewCount})',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _shop!.description ?? 'No description available',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildShopOverview() {
    final List<Map<String, String>> overviewItems = [
      {'label': 'Waiting', 'count': '95'},
      {'label': 'Completed', 'count': '95'},
      {'label': 'Items', 'count': '95'},
      {'label': 'Agreements', 'count': '95'},
      {'label': 'Avg Ratings', 'count': '95'},
      {'label': 'Messages', 'count': '95'},
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
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3, // Example number of reviews
          itemBuilder: (context, index) {
            return ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('Nethmina Wickramasinghe'),
              subtitle: const Text(
                'Great service and reasonable prices! Highly recommend.',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.star, color: Colors.amber),
                  SizedBox(width: 4),
                  Text('4'),
                ],
              ),
            );
          },
        ),
      ],
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
                // Prepare the updated data
                final updatedData = {
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                  'imageUrl': imageUrlController.text.trim(),
                };

                try {
                  // Call the updateShop method with the correct arguments
                  await Provider.of<ShopProvider>(
                    context,
                    listen: false,
                  ).updateShop(
                    _shop!.id, // Pass the shop ID
                    updatedData, // Pass the updated data
                    null, // No new image file provided
                  );

                  // Update the local state
                  setState(() {
                    _shop = _shop!.copyWith(
                      name: updatedData['name'],
                      description: updatedData['description'],
                      imageUrl: updatedData['imageUrl'],
                    );
                  });

                  Navigator.pop(context); // Close the dialog
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
                    // Input field to add a new service
                    TextFormField(
                      controller: servicesController,
                      decoration: const InputDecoration(
                        labelText: 'Add a Service',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // List of existing services with delete functionality
                    SizedBox(
                      height: 200, // Provide a fixed height for the ListView
                      child: ListView.builder(
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(services[index]),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  services.removeAt(
                                    index,
                                  ); // Remove the service
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Cancel button to close the dialog
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                // Save button to update the services
                ElevatedButton(
                  onPressed: () async {
                    // Add the new service if the input is not empty
                    if (servicesController.text.trim().isNotEmpty) {
                      setState(() {
                        services.add(servicesController.text.trim());
                      });
                      servicesController.clear();
                    }

                    try {
                      // Update the services in the database
                      await Provider.of<ShopProvider>(
                        context,
                        listen: false,
                      ).updateServices(_shop!.id, services);

                      // Update the local state
                      setState(() {
                        _shop = _shop!.copyWith(services: services);
                      });

                      Navigator.pop(context); // Close the dialog
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
