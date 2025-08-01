import 'dart:async';

import 'package:flutter/services.dart';

/// Represents the current state of audio playback.
enum AudioState {
  /// Playback is stopped.
  stopped,

  /// Playback is paused.
  paused,

  /// Audio is currently playing.
  playing,

  /// Playback has completed.
  completed,
}

/// Represents metadata for a media item.
class MediaItem {
  /// The title of the media item.
  final String title;

  /// The artist of the media item.
  final String artist;

  /// The URL of the album art.
  final String? albumArtUrl;

  /// The URL of the audio file.
  final String url;

  MediaItem({
    required this.title,
    required this.artist,
    this.albumArtUrl,
    required this.url,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'albumArtUrl': albumArtUrl,
      'url': url,
    };
  }
}

/// Provides background audio playback services.
class AudioBackgroundService {
  static const MethodChannel _channel =
      MethodChannel('com.example.audio_background');

  static final StreamController<AudioState> _stateController =
      StreamController.broadcast();
  static final StreamController<Duration> _positionController =
      StreamController.broadcast();

  /// A stream of audio state changes.
  static Stream<AudioState> get onStateChanged => _stateController.stream;

  /// A stream of audio position changes.
  static Stream<Duration> get onPositionChanged => _positionController.stream;

  /// Initializes the audio service.
  static Future<void> initialize() async {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// Starts playback of a media item.
  static Future<void> play(MediaItem item) async {
    await _channel.invokeMethod('play', item.toMap());
  }

  /// Pauses playback.
  static Future<void> pause() async {
    await _channel.invokeMethod('pause');
  }

  /// Stops playback.
  static Future<void> stop() async {
    await _channel.invokeMethod('stop');
  }

  /// Seeks to a specific position.
  static Future<void> seek(Duration position) async {
    await _channel.invokeMethod('seek', {'position': position.inMilliseconds});
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onStateChanged':
        _stateController.add(AudioState.values[call.arguments as int]);
        break;
      case 'onPositionChanged':
        _positionController
            .add(Duration(milliseconds: call.arguments as int));
        break;
      default:
        // Not implemented
        break;
    }
  }
}