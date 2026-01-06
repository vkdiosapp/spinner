import 'package:flutter/material.dart';
import 'spinner_wheel_page.dart';

class SpinnerConfigPage extends StatefulWidget {
  final String? initialTitle;
  final List<String>? initialItems;

  const SpinnerConfigPage({
    super.key,
    this.initialTitle,
    this.initialItems,
  });

  @override
  State<SpinnerConfigPage> createState() => _SpinnerConfigPageState();
}

class _SpinnerConfigPageState extends State<SpinnerConfigPage> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _itemControllers = [];
  final List<String> _items = [];

  @override
  void initState() {
    super.initState();
    // Set initial values if provided, otherwise use defaults
    _titleController.text = widget.initialTitle ?? 'Random Picker';
    if (widget.initialItems != null) {
      _items.addAll(widget.initialItems!);
      // Create controllers for each item
      for (var item in _items) {
        _itemControllers.add(TextEditingController(text: item));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewItem() {
    setState(() {
      _items.add('');
      _itemControllers.add(TextEditingController());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemControllers[index].dispose();
      _itemControllers.removeAt(index);
      _items.removeAt(index);
    });
  }

  void _startSpinner() {
    // Update items from controllers
    final updatedItems = <String>[];
    for (var controller in _itemControllers) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        updatedItems.add(text);
      }
    }

    if (updatedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SpinnerWheelPage(
          title: _titleController.text.trim().isEmpty
              ? 'Random Picker'
              : _titleController.text.trim(),
          items: updatedItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D44),
      appBar: AppBar(
        title: const Text(
          'Configure Spinner',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6C5CE7),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Input Section
            Card(
              color: const Color(0xFF3D3D5C),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spinner Title',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter spinner title',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                        filled: true,
                        fillColor: const Color(0xFF2D2D44),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Items List Section
            Card(
              color: const Color(0xFF3D3D5C),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Spinner Items',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addNewItem,
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add Item',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_items.length, (index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _itemControllers[index],
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Enter item name',
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                                  filled: true,
                                  fillColor: const Color(0xFF2D2D44),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () => _removeItem(index),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                                size: 28,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    if (_items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No items. Click "Add Item" to add items.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            const SizedBox(height: 32),
            
            // Start Spinner Button
            ElevatedButton(
              onPressed: _startSpinner,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C5CE7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Start Spinner',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

