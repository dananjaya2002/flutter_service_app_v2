import 'package:flutter/material.dart';

class ManageServicesScreen extends StatefulWidget {
  final List<Map<String, dynamic>>
  services; // List of services with name and description
  final Function(List<Map<String, dynamic>>) onSave;

  const ManageServicesScreen({
    Key? key,
    required this.services,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  late List<Map<String, dynamic>> _services;
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _serviceDescriptionController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _services = List.from(widget.services); // Copy the services list
  }

  @override
  void dispose() {
    _serviceNameController.dispose();
    _serviceDescriptionController.dispose();
    super.dispose();
  }

  void _addService() {
    if (_serviceNameController.text.trim().isNotEmpty) {
      setState(() {
        _services.add({
          'name': _serviceNameController.text.trim(),
          'description': _serviceDescriptionController.text.trim(),
        });
      });
      _serviceNameController.clear();
      _serviceDescriptionController.clear();
    }
  }

  void _editService(int index) {
    _serviceNameController.text = _services[index]['name'];
    _serviceDescriptionController.text = _services[index]['description'];
    setState(() {
      _services.removeAt(index); // Temporarily remove the service
    });
  }

  void _deleteService(int index) {
    setState(() {
      _services.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              widget.onSave(_services); // Pass the updated services back
              Navigator.pop(context); // Go back to the previous screen
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _serviceNameController,
              decoration: const InputDecoration(
                labelText: 'Service Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _serviceDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Service Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addService,
              child: const Text('Add Service'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_services[index]['name']),
                    subtitle: Text(_services[index]['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editService(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteService(index),
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
    );
  }
}
