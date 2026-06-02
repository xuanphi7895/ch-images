import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:images/src/modules/features/ipa/data/ipa.dart';

class IpaChartPage extends StatefulWidget {
  const IpaChartPage({super.key});

  @override
  State<IpaChartPage> createState() => _IpaChartPageState();
}

class _IpaChartPageState extends State<IpaChartPage> {
  final AudioPlayer _player = AudioPlayer();

  final List<IpaSound> sounds = ipaSounds;

  // Future<void> testPlay() async {
  //   try {
  //     await _player.setAsset('assets/ipa/audio/sound_j.mp3');
  //     await _player.play();
  //   } catch (e) {
  //     debugPrint('Audio error: $e');
  //   }
  // }

  Future<void> _play(IpaSound s) async {
    debugPrint('Audio error: $s');
    await _player.stop();
    await _player.setAsset(s.audioAsset);
    await _player.play();
  }

  Future<void> _openDetails(IpaSound s) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            Center(
              child: Text(
                '${s.symbol}  (${s.example})',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(s.mouthImageAsset),
            ),
            const SizedBox(height: 12),
            Text(s.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async => {await _play(s)},
              icon: const Icon(Icons.volume_up),
              label: const Text('Play sound'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('English IPA Chart')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sounds.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (_, i) {
          final s = sounds[i];
          return InkWell(
            onTap: () async {
              // await testPlay();
              debugPrint('loadeddsdsds: ${s.audioAsset}');
              // await _play(s);
              await _openDetails(s);
              // if (mounted) _openDetails(s);
            },
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    s.symbol,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(s.example, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
