import 'package:flutter/material.dart';
import 'language_settings.dart';
import 'home_page.dart';
import 'app_localizations_helper.dart';
import 'ad_helper.dart';

class LanguageSelectionPage extends StatefulWidget {
  const LanguageSelectionPage({super.key});

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage> {
  String? _selectedLanguageCode;
  final Map<String, List<String>> _groupedLanguages = {};

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = LanguageSettings.selectedLanguageCode;
    _groupLanguages();
  }

  void _groupLanguages() {
    final languages = LanguageSettings.getSupportedLanguageCodes();
    
    for (final code in languages) {
      final name = LanguageSettings.getLanguageName(code);
      final firstLetter = name[0].toUpperCase();
      
      if (!_groupedLanguages.containsKey(firstLetter)) {
        _groupedLanguages[firstLetter] = [];
      }
      _groupedLanguages[firstLetter]!.add(code);
    }
    
    // Sort each group
    _groupedLanguages.forEach((key, value) {
      value.sort((a, b) => LanguageSettings.getLanguageName(a)
          .compareTo(LanguageSettings.getLanguageName(b)));
    });
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      _selectedLanguageCode = languageCode;
    });
  }

  Future<void> _saveAndContinue() async {
    if (_selectedLanguageCode == null) return;
    
    await LanguageSettings.setLanguage(_selectedLanguageCode!);
    
    // If this is first launch, mark it complete and navigate to home
    if (LanguageSettings.isFirstLaunch) {
      await LanguageSettings.markFirstLaunchComplete();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      // If not first launch, just pop back with result and trigger app rebuild
      if (mounted) {
        Navigator.of(context).pop(true);
        // Trigger app rebuild by navigating to a new MaterialApp
        // The app will rebuild with new locale
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizationsHelper.of(context);
    final sortedKeys = _groupedLanguages.keys.toList()..sort();
    
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent so gradient shows through
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button
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
                          onBack: () {
                            if (Navigator.of(context).canPop()) {
                              Navigator.of(context).pop();
                            } else {
                              // If no previous route, navigate to home
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const HomePage()),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  // Title - centered on screen
                  Text(
                    l10n.languages,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Language list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final letter = sortedKeys[index];
                  final languages = _groupedLanguages[letter]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: Text(
                          letter,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Language items
                      ...languages.map((code) {
                        final name = LanguageSettings.getLanguageName(code);
                        final native = LanguageSettings.getNativeLanguageName(code);
                        final isSelected = _selectedLanguageCode == code;
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3D3D5C),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(
                                    color: const Color(0xFF6C5CE7),
                                    width: 2,
                                  )
                                : null,
                          ),
                          child: RadioListTile<String>(
                            value: code,
                            groupValue: _selectedLanguageCode,
                            onChanged: (value) {
                              if (value != null) {
                                _selectLanguage(value);
                              }
                            },
                            title: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: name != native
                                ? Text(
                                    native,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  )
                                : null,
                            activeColor: const Color(0xFF6C5CE7),
                            selected: isSelected,
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
            // Continue/Save button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _selectedLanguageCode != null ? _saveAndContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedLanguageCode != null
                        ? const Color(0xFF6C5CE7)
                        : const Color(0xFF3D3D5C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    LanguageSettings.isFirstLaunch ? l10n.continueButton : l10n.save,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
