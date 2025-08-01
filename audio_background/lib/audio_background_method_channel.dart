import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audio_background_platform_interface.dart';

/// An implementation of [AudioBackgroundPlatform] that uses method channels.
class MethodChannelAudioBackground extends AudioBackgroundPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('audio_background');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
