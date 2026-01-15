import 'package:flutter/material.dart';

class SpinnerEditPage extends StatefulWidget {
  final String title;
  final List<String> items;

  const SpinnerEditPage({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  State<SpinnerEditPage> createState() => _SpinnerEditPageState();
}

class _SpinnerEditPageState extends State<SpinnerEditPage> {
  late TextEditingController _titleController;
  final List<TextEditingController> _itemControllers = [];
  final List<FocusNode> _itemFocusNodes = [];
  final List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    if (widget.items.isNotEmpty) {
      _items.addAll(widget.items);
      // Create controllers and focus nodes for each item
      for (var item in _items) {
        _itemControllers.add(TextEditingController(text: item));
        _itemFocusNodes.add(FocusNode());
      }
    } else {
      // Add one default item so it doesn't look empty
      _items.add('');
      _itemControllers.add(TextEditingController());
      _itemFocusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    for (var focusNode in _itemFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _addNewItem() {
    setState(() {
      _items.add('');
      _itemControllers.add(TextEditingController());
      _itemFocusNodes.add(FocusNode());
    });
    // Focus on the newly added field after the widget rebuilds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemFocusNodes.isNotEmpty) {
        _itemFocusNodes.last.requestFocus();
      }
    });
  }

  void _removeItem(int index) {
    setState(() {
      _itemControllers[index].dispose();
      _itemFocusNodes[index].dispose();
      _itemControllers.removeAt(index);
      _itemFocusNodes.removeAt(index);
      _items.removeAt(index);
    });
  }

  void _saveChanges() {
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

    // Check for duplicate names (case-insensitive)
    final seenNames = <String>{};
    for (var item in updatedItems) {
      final lowerItem = item.toLowerCase();
      if (seenNames.contains(lowerItem)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Duplicate item name: "$item". Please use unique names.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      seenNames.add(lowerItem);
    }

    // Return updated data to previous page
    Navigator.of(context).pop({
      'title': _titleController.text.trim().isEmpty
          ? 'Random Picker'
          : _titleController.text.trim(),
      'items': updatedItems,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent so gradient shows through
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header with back button and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Back button - left aligned
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                  // Title - centered on screen
                  const Text(
                    'Edit Spinner',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                      textCapitalization: TextCapitalization.words,
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
                    const Text(
                      'Spinner Items',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
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
                                focusNode: _itemFocusNodes[index],
                                textCapitalization: TextCapitalization.words,
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
                    const SizedBox(height: 12),
                    // Add Item button at bottom
                    TextButton.icon(
                      onPressed: _addNewItem,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text(
                        'Add Item',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Save Button
            ElevatedButton(
              onPressed: _saveChanges,
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
                'Save Changes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

