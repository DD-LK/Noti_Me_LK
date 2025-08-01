# audio_background

A Flutter plugin for seamless background audio playback on Android and iOS. This plugin allows you to play audio from a URL or a local file, and it provides notifications and controls for the audio playback.

## Features

- Play audio from a URL or a local file.
- Background audio playback.
- Media controls in the notification.
- Support for Android and iOS.

## Getting Started

To use this plugin, add `audio_background` as a [dependency in your pubspec.yaml file](https://flutter.dev/to/develop-plugins).

## Usage

Here's a simple example of how to use the `audio_background` plugin to play an audio file:

```dart
import 'package:flutter/material.dart';
import 'package:audio_background/audio_background.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AudioBackgroundService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Audio Background Example'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              AudioBackgroundService.play(MediaItem(
                title: 'Test Title',
                artist: 'Test Artist',
                url: 'https://example.com/audio.mp3',
              ));
            },
            child: const Text('Play Audio'),
          ),
        ),
      ),
    );
  }
}
```

For more detailed examples, see the `example` directory.