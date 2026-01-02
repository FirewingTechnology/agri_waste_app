import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/app_strings.dart';
import '../core/localization/language_provider.dart';

// Create a language selection screen in Flutter
// Two buttons: English and Hindi
// Save selected language using shared preferences
// Navigate to login screen

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String selectedLanguage = 'English';

  Future<void> _selectLanguage(String language) async {
    setState(() {
      selectedLanguage = language;
    });

    // Update language in provider
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    await languageProvider.setLanguage(language);

    // Navigate to login screen after short delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryGreen,
              AppTheme.darkGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon/Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.eco,
                    size: 80,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 40),

                // App Title
                Text(
                  AppStrings.getTranslation(AppStrings.agriWasteToFertilizer, 'en'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.getTranslation(AppStrings.sustainableAgriculture, 'en'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 60),

                // Language Selection Title
                Text(
                  AppStrings.getTranslation(AppStrings.selectLanguage, 'en'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // English Button
                _LanguageButton(
                  language: 'English',
                  nativeText: 'English',
                  icon: '🇬🇧',
                  isSelected: selectedLanguage == 'English',
                  onTap: () => _selectLanguage('English'),
                ),
                const SizedBox(height: 16),

                // Hindi Button
                _LanguageButton(
                  language: 'Hindi',
                  nativeText: 'हिंदी',
                  icon: '🇮🇳',
                  isSelected: selectedLanguage == 'Hindi',
                  onTap: () => _selectLanguage('Hindi'),
                ),
                const SizedBox(height: 16),

                // Marathi Button
                _LanguageButton(
                  language: 'Marathi',
                  nativeText: 'मराठी',
                  icon: '🇮🇳',
                  isSelected: selectedLanguage == 'Marathi',
                  onTap: () => _selectLanguage('Marathi'),
                ),
                const SizedBox(height: 60),

                // Footer
                Text(
                  AppStrings.getTranslation(AppStrings.empoweringFarmers, 'en'),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String language;
  final String nativeText;
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.language,
    required this.nativeText,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.accentOrange : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                nativeText,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppTheme.primaryGreen : AppTheme.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppTheme.accentOrange,
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
