import 'package:flutter/material.dart';
import '../services/language_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final LanguageService _languageService = LanguageService();
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = null;
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
  }

  Future<void> _continue() async {
    if (_selectedLanguage == null) return;
    await _languageService.setLanguage(_selectedLanguage!);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.language,
                size: 80,
                color: Color(0xFF0A3D0A),
              ),
              const SizedBox(height: 30),
              const Text(
                'Select Language\nSankhani Chilankhulo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A3D0A),
                ),
              ),
              const SizedBox(height: 50),
              
              // English Option
              _buildLanguageCard(
                'English',
                'en',
                Icons.check_circle,
              ),
              const SizedBox(height: 16),
              
              // Chichewa Option
              _buildLanguageCard(
                'Chichewa',
                'ny',
                Icons.check_circle,
              ),
              
              const SizedBox(height: 40),
              
              // Continue Button
              ElevatedButton(
                onPressed: _selectedLanguage != null ? _continue : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue / Pitirizani',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(String language, String code, IconData icon) {
    final isSelected = _selectedLanguage == code && _selectedLanguage != null;
    
    return GestureDetector(
      onTap: () => _selectLanguage(code),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A3D0A).withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF0A3D0A) : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF0A3D0A) : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Text(
              language,
              style: TextStyle(
                fontSize: 20,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFF0A3D0A) : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check,
                color: Color(0xFF0A3D0A),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
