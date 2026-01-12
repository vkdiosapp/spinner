import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'spinner_wheel_page.dart';
import 'ad_helper.dart';
import 'app_localizations_helper.dart';

class SpinnerConfigPage extends StatefulWidget {
  final String? initialTitle;
  final List<String>? initialItems;

  const SpinnerConfigPage({super.key, this.initialTitle, this.initialItems});

  @override
  State<SpinnerConfigPage> createState() => _SpinnerConfigPageState();
}

class _SpinnerConfigPageState extends State<SpinnerConfigPage> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _itemControllers = [];
  final List<FocusNode> _itemFocusNodes = [];
  final List<String> _items = [];

  @override
  void initState() {
    super.initState();
    // Set initial values if provided, otherwise use empty
    _titleController.text = widget.initialTitle ?? '';
    if (widget.initialItems != null && widget.initialItems!.isNotEmpty) {
      _items.addAll(widget.initialItems!);
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
      // Don't auto-focus - keyboard should not open automatically
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

  void _startSpinner() {
    // Update items from controllers
    final updatedItems = <String>[];
    for (var controller in _itemControllers) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        updatedItems.add(text);
      }
    }

    final l10n = AppLocalizationsHelper.of(context);
    
    if (updatedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseAddAtLeastOneItem),
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
            content: Text(
              l10n.duplicateItemName(item),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
      seenNames.add(lowerItem);
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => SpinnerWheelPage(
          title: _titleController.text.trim().isEmpty
              ? l10n.randomPickerTitle
              : _titleController.text.trim(),
          items: updatedItems,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D44),
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
                        onPressed: () => BackArrowAd.handleBackButton(
                          context: context,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
                  // Title - centered on screen
                  Text(
                    l10n.spinner,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Start button - right aligned
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C5CE7),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _startSpinner,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Text(
                              l10n.start,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
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
                            Text(
                              l10n.spinnerTitle,
                              style: const TextStyle(
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
                                hintText: l10n.enterSpinnerTitle,
                                hintStyle: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                ),
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
                            Text(
                              l10n.spinnerItems,
                              style: const TextStyle(
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
                                        textCapitalization:
                                            TextCapitalization.words,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: l10n.enterItemName,
                                          hintStyle: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.5,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFF2D2D44),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
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
                                    l10n.noItems,
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
                              label: Text(
                                l10n.addItem,
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
