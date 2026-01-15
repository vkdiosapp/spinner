import 'package:flutter/material.dart';
import 'dart:ui';
import 'spinner_wheel_page.dart';
import 'ad_helper.dart';
import 'app_localizations_helper.dart';
import 'animated_gradient_background.dart';

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

  // Helper widget for glossy card effect
  Widget _buildGlossyCard({
    required Widget child,
    double borderRadius = 24,
    EdgeInsets? padding,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.45),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1F2687).withOpacity(0.07),
                blurRadius: 32,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              child,
              // Glossy overlay effect - ignore pointer events so taps pass through
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.4),
                          Colors.white.withOpacity(0),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(borderRadius),
                        topRight: Radius.circular(borderRadius),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for vibrant button
  Widget _buildVibrantButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Shine effect
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 20,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSpinner() {
    final l10n = AppLocalizationsHelper.of(context);

    // Validate spinner title is mandatory
    final titleText = _titleController.text.trim();
    if (titleText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter spinner title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
            content: Text(l10n.duplicateItemName(item)),
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
        builder: (context) =>
            SpinnerWheelPage(title: titleText, items: updatedItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);

    return AnimatedGradientBackground(
      child: Scaffold(
        backgroundColor:
            Colors.transparent, // Transparent so gradient shows through
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Back button - left aligned with frosted glass effect
                      Align(
                        alignment: Alignment.centerLeft,
                        child: GestureDetector(
                          onTap: () => BackArrowAd.handleBackButton(
                            context: context,
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                  blurStyle: BlurStyle.inner,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 16,
                                  sigmaY: 16,
                                ),
                                child: const Icon(
                                  Icons.arrow_back,
                                  color: Color(0xFF475569),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Title - centered
                      Text(
                        l10n.spinner,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      // Start button - right aligned
                      Align(
                        alignment: Alignment.centerRight,
                        child: _buildVibrantButton(
                          text: l10n.start,
                          onTap: _startSpinner,
                        ),
                      ),
                    ],
                  ),
              ),
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      // Title Input Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                              bottom: 12,
                            ),
                            child: Text(
                              l10n.spinnerTitle.toUpperCase(),
                              style: TextStyle(
                                color: const Color(0xFF475569),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildGlossyCard(
                            borderRadius: 24,
                            padding: const EdgeInsets.all(20),
                            child: TextField(
                              controller: _titleController,
                              textCapitalization: TextCapitalization.words,
                              style: const TextStyle(
                                color: Color(0xFF1E293B),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.3),
                                hintText: l10n.enterSpinnerTitle,
                                hintStyle: TextStyle(
                                  color: const Color(0xFF64748B),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: const Color(0xFF6366F1).withOpacity(0.6),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Items List Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 4,
                              bottom: 12,
                            ),
                            child: Text(
                              l10n.spinnerItems.toUpperCase(),
                              style: TextStyle(
                                color: const Color(0xFF475569),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          _buildGlossyCard(
                            borderRadius: 32,
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
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
                                              color: Color(0xFF1E293B),
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white.withOpacity(0.3),
                                              hintText: l10n.enterItemName,
                                              hintStyle: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 16,
                                                    vertical: 14,
                                                  ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: Colors.white.withOpacity(0.4),
                                                  width: 1,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: Colors.white.withOpacity(0.4),
                                                  width: 1,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                borderSide: BorderSide(
                                                  color: const Color(0xFF6366F1).withOpacity(0.6),
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () => _removeItem(index),
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.red.withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                              size: 20,
                                            ),
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
                                          color: const Color(0xFF64748B),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                // Add Item button at bottom
                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _addNewItem,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.add,
                                          color: const Color(0xFF6366F1),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          l10n.addItem,
                                          style: TextStyle(
                                            color: const Color(0xFF1E293B),
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              // Bottom indicator
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  width: 128,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[400]?.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
