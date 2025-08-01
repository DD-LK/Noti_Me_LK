import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_background/audio_background.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.example.audio_background');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    log.clear();
  });

  test('play', () async {
    final item = MediaItem(
      title: 'Test',
      artist: 'Test Artist',
      url: 'http://example.com/test.mp3',
    );
    await AudioBackgroundService.play(item);
    expect(log, <Matcher>[
      isMethodCall('play', arguments: <String, dynamic>{
        'title': 'Test',
        'artist': 'Test Artist',
        'albumArtUrl': null,
        'url': 'http://example.com/test.mp3',
      }),
    ]);
  });

  test('pause', () async {
    await AudioBackgroundService.pause();
    expect(log, <Matcher>[isMethodCall('pause', arguments: null)]);
  });

  test('stop', () async {
    await AudioBackgroundService.stop();
    expect(log, <Matcher>[isMethodCall('stop', arguments: null)]);
  });

  test('seek', () async {
    await AudioBackgroundService.seek(const Duration(seconds: 10));
    expect(log, <Matcher>[
      isMethodCall('seek', arguments: {'position': 10000})
    ]);
  });
}