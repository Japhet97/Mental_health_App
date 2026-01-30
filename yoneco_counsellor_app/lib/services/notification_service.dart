import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _initializePlayer();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;
  
  Future<void> _initializePlayer() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      await _audioPlayer.setVolume(1.0);
      // Preload the notification sound for instant playback
      await _audioPlayer.setSource(AssetSource('notification.mp3'));
      _isInitialized = true;
      debugPrint('Notification sound preloaded successfully');
    } catch (e) {
      debugPrint('Error initializing notification sound: $e');
    }
  }
  
  Future<void> playNotificationSound() async {
    try {
      if (!_isInitialized) {
        await _initializePlayer();
      }
      
      // Stop any currently playing sound
      await _audioPlayer.stop();
      // Play the notification sound
      await _audioPlayer.resume();
      
      debugPrint('Notification sound played');
    } catch (e) {
      debugPrint('Error playing notification sound: $e');
      // Try to reinitialize and play
      try {
        await _audioPlayer.play(AssetSource('notification.mp3'));
      } catch (retryError) {
        debugPrint('Retry failed: $retryError');
      }
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
