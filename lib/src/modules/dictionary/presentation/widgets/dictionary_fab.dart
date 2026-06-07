import 'package:flutter/material.dart';
import 'package:images/src/modules/dictionary/presentation/screens/word_lookup_screen.dart';
import 'package:images/src/utils/color.dart';

/// A floating chat-bubble icon that opens the Dictionary as a modal overlay.
///
/// Place this inside a [Stack] on any screen — it will float at the
/// bottom-right corner and pulse gently to attract attention.
class DictionaryFab extends StatefulWidget {
  const DictionaryFab({super.key});

  @override
  State<DictionaryFab> createState() => _DictionaryFabState();
}

class _DictionaryFabState extends State<DictionaryFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _openDictionary() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _DictionaryModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 50,
      child: ScaleTransition(
        scale: _pulseScale,
        child: GestureDetector(
          onTap: _openDictionary,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [CustomColors.Purple600, CustomColors.Purple900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: CustomColors.Purple600.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: CustomColors.Purple900.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Chat bubble icon
                const Icon(
                  Icons.chat_bubble_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                // Small "Aa" text badge inside the bubble
                Positioned(
                  top: 17,
                  child: Text(
                    'Aa',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Dictionary Modal — wraps the WordLookupScreen with close button
// ═══════════════════════════════════════════════════════════════════════════════
class _DictionaryModal extends StatelessWidget {
  const _DictionaryModal();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Drag handle + Close button ────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 8, 0),
            child: Row(
              children: [
                // Drag handle
                Expanded(
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                // Close button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.black.withOpacity(0.45),
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Dictionary Screen ─────────────────────
          const Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: WordLookupScreen(),
            ),
          ),
        ],
      ),
    );
  }
}
