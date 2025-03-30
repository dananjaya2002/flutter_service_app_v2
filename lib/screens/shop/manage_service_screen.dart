import 'package:flutter/material.dart';

class ManageServicesScreen extends StatefulWidget {
  final List<String> services;
  final Function(List<String>) onSave;

  const ManageServicesScreen({
    Key? key,
    required this.services,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  late List<String> _services;
  final TextEditingController _serviceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _services = List.from(widget.services); // Copy the services list
  }

  @override
  void dispose() {
    _serviceController.dispose();
    super.dispose();
  }

  void _addService() {
    if (_serviceController.text.trim().isNotEmpty) {
      setState(() {
        _services.add(_serviceController.text.trim());
      });
      _serviceController.clear();
    }
  }

  void _editService(int index) {
    _serviceController.text = _services[index];
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
              controller: _serviceController,
              decoration: const InputDecoration(
                labelText: 'Add or Edit a Service',
                border: OutlineInputBorder(),
              ),
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
                    title: Text(_services[index]),
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