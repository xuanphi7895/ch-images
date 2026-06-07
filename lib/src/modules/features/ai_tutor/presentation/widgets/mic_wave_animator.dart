import 'dart:math';
import 'package:flutter/material.dart';

class MicWaveAnimator extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(String) onFinish;
  final List<String> starters;

  const MicWaveAnimator({
    super.key,
    required this.onCancel,
    required this.onFinish,
    required this.starters,
  });

  @override
  State<MicWaveAnimator> createState() => _MicWaveAnimatorState();
}

class _MicWaveAnimatorState extends State<MicWaveAnimator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _waveValues = List.generate(8, (_) => 0.1);
  final Random _random = Random();
  String _statusText = 'Listening...';
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    )..addListener(() {
        setState(() {
          for (int i = 0; i < _waveValues.length; i++) {
            _waveValues[i] = 0.15 + _random.nextDouble() * 0.85;
          }
        });
      });
    _controller.repeat(reverse: true);

    // Simulate speech-to-text after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _statusText = 'Transcribing...';
        _isFinished = true;
      });
      _controller.stop();

      // Pick a random conversation starter or fallback sentence
      final simulatedSpeech = widget.starters.isNotEmpty
          ? widget.starters[_random.nextInt(widget.starters.length)]
          : 'I want to learning Spanish with you!';

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        widget.onFinish(simulatedSpeech);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'SPEAK NOW',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _statusText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          // Pulsing Soundwaves
          SizedBox(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_waveValues.length, (index) {
                final height = _isFinished ? 6.0 : (_waveValues[index] * 70);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 6,
                  height: height,
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? const Color(0xFF40DF9F)
                        : const Color(0xFF534AB7),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 50),
          const Text(
            'Simulating voice input speech-to-text...',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 40),
          // Cancel Button
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white30),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            icon: const Icon(Icons.close, color: Colors.white70, size: 16),
            label: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            onPressed: widget.onCancel,
          ),
        ],
      ),
    );
  }
}
