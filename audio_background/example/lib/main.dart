import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
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
  AudioState _state = AudioState.stopped;
  Duration _position = Duration.zero;
  String? _filePath;

  @override
  void initState() {
    super.initState();
    AudioBackgroundService.initialize();
    AudioBackgroundService.onStateChanged.listen((state) {
      setState(() {
        _state = state;
      });
    });
    AudioBackgroundService.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      setState(() {
        _filePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Audio Background Example'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _pickFile,
                  child: const Text('Pick Audio File'),
                ),
                if (_filePath != null) ...[
                  const SizedBox(height: 20),
                  Text('Selected file: $_filePath'),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: _filePath == null
                          ? null
                          : () {
                              AudioBackgroundService.play(MediaItem(
                                title: 'Test Title',
                                artist: 'Test Artist',
                                url: _filePath!,
                              ));
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.pause),
                      onPressed: () {
                        AudioBackgroundService.pause();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: () {
                        AudioBackgroundService.stop();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('State: ${_state.toString().split('.').last}'),
                Slider(
                  value: _position.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    AudioBackgroundService.seek(
                        Duration(milliseconds: value.toInt()));
                  },
                  min: 0,
                  max: 100000, // This should be the duration of the audio
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
