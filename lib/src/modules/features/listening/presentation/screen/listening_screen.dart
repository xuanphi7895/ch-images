import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:images/src/utils/color.dart';

class ListeningScreen extends StatefulWidget {
  const ListeningScreen({Key? key}) : super(key: key);

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  late final AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;

  // Mock Synchronized Transcript (Text with Millisecond Timestamp triggers)
  final List<Map<String, dynamic>> _transcript = [
    {
      "speaker": "John",
      "text": "Good morning everyone. Thanks for coming.",
      "start": 0,
      "end": 4000,
    },
    {
      "speaker": "Sarah",
      "text": "I would like to review our English presentation progress first.",
      "start": 4001,
      "end": 9000,
    },
    {
      "speaker": "John",
      "text": "Excellent idea. Let's look at the metrics together.",
      "start": 9001,
      "end": 14000,
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Set audio source url or asset path
    _audioPlayer.setSource(
      UrlSource('https://www.123listening.com/freeaudio/adjectives1-1.mp3'),
    );

    // Track total duration
    _audioPlayer.onDurationChanged.listen((d) => setState(() => _duration = d));

    // Track current playing position to update highlighted transcript lines
    _audioPlayer.onPositionChanged.listen((p) => setState(() => _position = p));

    // Track state switches
    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void _changeSpeed() async {
    double nextSpeed = _playbackSpeed == 1.0
        ? 0.75
        : (_playbackSpeed == 0.75 ? 1.25 : 1.0);
    await _audioPlayer.setPlaybackRate(nextSpeed);
    setState(() => _playbackSpeed = nextSpeed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Listening Practice",
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            // Soundwave/Illustration Zone
            Container(
              height: 100,
              alignment: Alignment.center,
              child: Icon(
                Icons.graphic_eq,
                size: 64,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
              ),
            ),

            // Transcript Display Area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemCount: _transcript.length,
                  itemBuilder: (context, index) {
                    final line = _transcript[index];
                    final currentMs = _position.inMilliseconds;
                    // Determine if this specific line is actively being spoken
                    final bool isActive =
                        currentMs >= line['start'] && currentMs <= line['end'];

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.blue.withOpacity(0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: isActive
                                ? Colors.blue[900]
                                : CustomColors.BlackBackground,
                          ),
                          children: [
                            TextSpan(
                              text: "${line['speaker']}: ",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: line['text'],
                              style: TextStyle(
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Timeline Scrubbing Slider
            const SizedBox(height: 10),
            Slider(
              min: 0,
              max: _duration.inMilliseconds.toDouble(),
              value: _position.inMilliseconds.toDouble().clamp(
                0,
                _duration.inMilliseconds.toDouble(),
              ),
              onChanged: (value) async {
                await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(_position)),
                  Text(_formatDuration(_duration)),
                ],
              ),
            ),

            // Media Control Panel
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Playback speed controller
                  TextButton(
                    onPressed: _changeSpeed,
                    child: Text(
                      "${_playbackSpeed}x",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Rewind 10 seconds
                  IconButton(
                    icon: const Icon(Icons.replay_10, size: 32),
                    onPressed: () => _audioPlayer.seek(
                      _position - const Duration(seconds: 10),
                    ),
                  ),
                  // Core Play/Pause Circle
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  ),
                  // Skip forward 10 seconds
                  IconButton(
                    icon: const Icon(Icons.forward_10, size: 32),
                    onPressed: () => _audioPlayer.seek(
                      _position + const Duration(seconds: 10),
                    ),
                  ),
                  // Inline Dictionary translation toggle
                  IconButton(
                    icon: const Icon(Icons.g_translate, size: 26),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Translation Mode Activated: Tap any word to translate",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
