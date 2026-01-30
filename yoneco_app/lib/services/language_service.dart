import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  String _currentLanguage = 'en'; // Default to English

  String get currentLanguage => _currentLanguage;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    notifyListeners();
  }

  String translate(String key) {
    return _translations[_currentLanguage]?[key] ?? key;
  }

  // Translations
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Splash Screen
      'splash_welcome': 'Welcome to',
      'splash_yoneco': 'Tithandizane Helpline',
      'splash_subtitle': 'Mental Health Support',
      'splash_tagline': 'We are here for you 24/7',
      
      // Language Selection
      'select_language': 'Select Language',
      'select_language_subtitle': 'Choose your preferred language',
      'continue': 'Continue',
      
      // Welcome Screen
      'welcome_title': 'Welcome to Tithandizane',
      'welcome_subtitle': 'Mental Health Support 24/7',
      'welcome_message': 'You are not alone. We are here to listen and support you.',
      'get_started': 'Get Started',
      'about_us': 'About Us',
      
      // Issues Screen
      'issues_title': 'How can we help?',
      'issues_subtitle': 'Select the issue you\'re facing',
      'depression': 'Depression',
      'anxiety': 'Anxiety',
      'stress': 'Stress',
      'trauma': 'Trauma',
      'relationship': 'Relationship Issues',
      'addiction': 'Addiction',
      'grief': 'Grief & Loss',
      'suicide_prevention': 'Suicide Prevention',
      'stress_management': 'Stress Management',
      'trauma_ptsd': 'Trauma & PTSD',
      'relationship_issues': 'Relationship Issues',
      'family_problems': 'Family Problems',
      'substance_abuse': 'Substance Abuse',
      'grief_loss': 'Grief & Loss',
      'self_harm': 'Self-Harm',
      'eating_disorders': 'Eating Disorders',
      'sleep_problems': 'Sleep Problems',
      'work_stress': 'Work Stress',
      'academic_pressure': 'Academic Pressure',
      'other_issues': 'Other Issues',
      'tap_to_get_help': 'Tap to get help',
      
      // Chat Screen
      'chat_title': 'Counsellor Chat',
      'issue_label': 'Issue',
      'waiting_counsellor': 'Waiting for counsellor to join...',
      'no_messages': 'No messages yet. Start the conversation!',
      'type_message': 'Type a message...',
      'you': 'You',
      'counsellor': 'Counsellor',
      'counsellor_typing': 'Counsellor is typing...',
      
      // Session Messages
      'counsellor_joined': 'A counsellor has joined the session!',
      'session_closed': 'Session has been closed',
      'connection_error': 'Connection error',
      'connection_closed': 'Connection closed',
      'send_failed': 'Failed to send message',
      
      // Counsellor Screen
      'counsellor_connect': 'Counsellor Connect',
      'connect_counsellor': 'Connect with a professional counsellor',
      'counsellor_will_join': 'A counsellor will join you shortly. Please enter your name to begin.',
      'your_name': 'Your Name',
      'enter_name': 'Enter your name',
      'please_enter_name': 'Please enter your name',
      'start_live_chat': 'Start Live Chat',
      'support_available': '24/7 Support Available',
      'failed_to_start_chat': 'Failed to start chat',
      
      // Waiting Screen
      'connecting': 'Connecting you to a counsellor...',
      'please_wait': 'Please wait while we find someone to help you',
      'session_created': 'Session created successfully!',
      'creating_session': 'Creating session...',
    },
    'ny': { // Chichewa
      // Splash Screen
      'splash_welcome': 'Takulandirani ku',
      'splash_yoneco': 'Tithandizane Helpline',
      'splash_subtitle': 'Chithandizo cha Thanzi la M\'maganizo',
      'splash_tagline': 'Tili nanu masiku onse 24/7',
      
      // Language Selection
      'select_language': 'Sankhani Chilankhulo',
      'select_language_subtitle': 'Sankhani chilankhulo chomwe mukufuna',
      'continue': 'Pitirizani',
      
      // Welcome Screen
      'welcome_title': 'Takulandirani ku Tithandizane',
      'welcome_subtitle': 'Chithandizo cha Thanzi la M\'maganizo 24/7',
      'welcome_message': 'Simuli okha. Tili pano kukumverani ndi kukuthandizani.',
      'get_started': 'Yambani',
      'about_us': 'Za Ife',
      
      // Issues Screen
      'issues_title': 'Tingakuthandizeni bwanji?',
      'issues_subtitle': 'Sankhani vuto lomwe mukukumana nalo',
      'depression': 'Kukhumudwa',
      'anxiety': 'Nkhawa',
      'stress': 'Kupsinjika maganizo',
      'trauma': 'Zowawa zamtima',
      'relationship': 'Mavuto aubwenzi',
      'addiction': 'Zolakalaka',
      'grief': 'Chisoni ndi Kutaya',
      'suicide_prevention': 'Kuletsa Kudzipha',
      'stress_management': 'Kupsinjika Maganizo',
      'trauma_ptsd': 'Zowawa Zamtima',
      'relationship_issues': 'Mavuto Aubwenzi',
      'family_problems': 'Mavuto Abanja',
      'substance_abuse': 'Zolakalaka',
      'grief_loss': 'Chisoni ndi Kutaya',
      'self_harm': 'Kudzivulaza',
      'eating_disorders': 'Mavuto Akudya',
      'sleep_problems': 'Mavuto Agono',
      'work_stress': 'Kupsinjika Pantchito',
      'academic_pressure': 'Kupsinjika Pasukulu',
      'social_anxiety': 'Nkhawa Yaanthu',
      'other_issues': 'Zina',
      'tap_to_get_help': 'Dinani kuti muthandizidwe',
      
      // Chat Screen
      'chat_title': 'Kulankhulana ndi Mlangizi',
      'issue_label': 'Vuto',
      'waiting_counsellor': 'Tikudikirira mlangizi...',
      'no_messages': 'Palibe mauthenga. Yambani kulankhulana!',
      'type_message': 'Lembani uthenga...',
      'you': 'Inu',
      'counsellor': 'Mlangizi',
      'counsellor_typing': 'Mlangizi akulemba...',
      
      // Session Messages
      'counsellor_joined': 'Mlangizi walowa m\'nkhaniyi!',
      'session_closed': 'Nkhaniyi yatsekedwa',
      'connection_error': 'Cholakwika pa kulumikizana',
      'connection_closed': 'Kulumikizana kwatha',
      'send_failed': 'Kutumiza uthenga kwalephera',
      
      // Counsellor Screen
      'counsellor_connect': 'Kulumikizana ndi Mlangizi',
      'connect_counsellor': 'Lumikizanani ndi mlangizi wachidziwitso',
      'counsellor_will_join': 'Mlangizi adzalowa posachedwa. Chonde lowetsani dzina lanu kuti muyambe.',
      'your_name': 'Dzina Lanu',
      'enter_name': 'Lowetsani dzina lanu',
      'please_enter_name': 'Chonde lowetsani dzina lanu',
      'start_live_chat': 'Yambani Kulankhulana',
      'support_available': 'Chithandizo Chilipo 24/7',
      'failed_to_start_chat': 'Kulankhulana kwalephera',
      
      // Waiting Screen
      'connecting': 'Tikulumikizani ndi mlangizi...',
      'please_wait': 'Chonde dikirani pomwe tikupezani wothandiza',
      'session_created': 'Nkhani yakhazikitsidwa!',
      'creating_session': 'Tikulemba nkhani...',
    },
  };
}
