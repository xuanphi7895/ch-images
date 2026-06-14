import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  final bool isListening;
  final bool isAvailable;
  final AnimationController pulseController;
  final VoidCallback onTap;

  const MicButton({
    super.key,
    required this.isListening,
    required this.isAvailable,
    required this.pulseController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: pulseController,
        builder: (_, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              if (isListening)
                Container(
                  width: 44 + pulseController.value * 16,
                  height: 44 + pulseController.value * 16,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15 * (1 - pulseController.value)),
                    shape: BoxShape.circle,
                  ),
                ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isListening
                      ? Colors.red.shade400
                      : isAvailable
                          ? const Color(0xFF185FA5)
                          : Colors.grey.shade400,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isListening ? Icons.stop_rounded : Icons.mic,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
