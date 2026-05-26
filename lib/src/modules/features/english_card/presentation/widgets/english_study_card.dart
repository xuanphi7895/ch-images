import 'package:flutter/material.dart';

import '../../domain/english_card_model.dart';

/// Visual English flashcard (front = word, back = definition + example).
class EnglishStudyCard extends StatelessWidget {
  const EnglishStudyCard({
    super.key,
    required this.card,
    required this.showBack,
    required this.onFlip,
    required this.onFavorite,
  });

  final EnglishCardModel card;
  final bool showBack;
  final VoidCallback onFlip;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFlip,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: showBack
            ? _BackSide(card: card, key: const ValueKey('back'))
            : _FrontSide(
                card: card,
                onFavorite: onFavorite,
                key: const ValueKey('front'),
              ),
      ),
    );
  }
}

class _FrontSide extends StatelessWidget {
  const _FrontSide({
    super.key,
    required this.card,
    required this.onFavorite,
  });

  final EnglishCardModel card;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      color: cs.primaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LevelBadge(level: card.level),
            const SizedBox(height: 16),
            Text(
              card.word,
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.phonetic,
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.partOfSpeech,
              style: theme.textTheme.labelLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onFavorite,
                  icon: Icon(
                    card.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: card.isFavorite ? Colors.red : null,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tap card to see meaning',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BackSide extends StatelessWidget {
  const _BackSide({super.key, required this.card});

  final EnglishCardModel card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      color: cs.secondaryContainer.withValues(alpha: 0.35),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Definition',
              style: theme.textTheme.labelLarge?.copyWith(
                color: cs.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              card.definition,
              style: theme.textTheme.titleLarge?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 20),
            Text(
              'Example',
              style: theme.textTheme.labelLarge?.copyWith(color: cs.secondary),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '“${card.example}”',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const Spacer(),
            Center(
              child: Text(
                'Tap to flip back',
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});
  final String level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        level,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
