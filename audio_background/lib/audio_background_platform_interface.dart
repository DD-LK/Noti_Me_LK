import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'audio_background_method_channel.dart';

abstract class AudioBackgroundPlatform extends PlatformInterface {
  /// Constructs a AudioBackgroundPlatform.
  AudioBackgroundPlatform() : super(token: _token);

  static final Object _token = Object();

  static AudioBackgroundPlatform _instance = MethodChannelAudioBackground();

  /// The default instance of [AudioBackgroundPlatform] to use.
  ///
  /// Defaults to [MethodChannelAudioBackground].
  static AudioBackgroundPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AudioBackgroundPlatform] when
  /// they register themselves.
  static set instance(AudioBackgroundPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
