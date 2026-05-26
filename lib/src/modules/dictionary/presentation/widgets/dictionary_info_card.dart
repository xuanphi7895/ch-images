import 'package:flutter/material.dart';
import 'package:images/src/modules/dictionary/data/dictionary_api.dart';

import '../../data/dictionary_audio.dart';

/// Shows dictionary info + Listen buttons (word + each example).
class DictionaryInfoCard extends StatefulWidget {
  const DictionaryInfoCard({super.key, required this.entry, this.audio});

  final Dictionary entry;
  final DictionaryAudio? audio;

  @override
  State<DictionaryInfoCard> createState() => _DictionaryInfoCardState();
}

class _DictionaryInfoCardState extends State<DictionaryInfoCard> {
  late final DictionaryAudio _audio;
  late final bool _ownsAudio;

  @override
  void initState() {
    super.initState();
    _ownsAudio = widget.audio == null;
    _audio = widget.audio ?? DictionaryAudio();
  }

  @override
  void dispose() {
    if (_ownsAudio) {
      _audio.dispose();
    }
    super.dispose();
  }

  Future<void> _listenWord() async {
    setState(() {});
    await _audio.playWord(
      audioUrl: widget.entry.firstAudioUrl,
      word: widget.entry.word,
    );
    if (mounted) setState(() {});
  }

  Future<void> _listenExample(String text) async {
    setState(() {});
    await _audio.speakExample(text);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.entry;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WordHeader(
              word: entry.word,
              phonetic: entry.primaryPhonetic,
              isBusy: _audio.isBusy,
              onListen: _listenWord,
            ),
            const SizedBox(height: 16),
            // ...entry.meanings.map(
            //   (meaning) => _MeaningSection(
            //     meaning: meaning,
            //     isBusy: _audio.isBusy,
            //     onListenExample: _listenExample,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _WordHeader extends StatelessWidget {
  const _WordHeader({
    required this.word,
    required this.phonetic,
    required this.isBusy,
    required this.onListen,
  });

  final String word;
  final String? phonetic;
  final bool isBusy;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (phonetic != null) ...[
                const SizedBox(height: 4),
                Text(
                  phonetic!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.tonalIcon(
          onPressed: isBusy ? null : onListen,
          icon: isBusy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.volume_up),
          label: const Text('Listen'),
        ),
      ],
    );
  }
}

class _MeaningSection extends StatelessWidget {
  const _MeaningSection({
    required this.meaning,
    required this.isBusy,
    required this.onListenExample,
  });

  final Meaning meaning;
  final bool isBusy;
  final ValueChanged<String> onListenExample;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              meaning.partOfSpeech,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...meaning.definitions.asMap().entries.map((e) {
            final index = e.key + 1;
            final sense = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$index. ${sense.definition}',
                    style: theme.textTheme.bodyLarge,
                  ),
                  if (sense.example != null && sense.example!.trim().isNotEmpty)
                    _ExampleRow(
                      example: sense.example!,
                      isBusy: isBusy,
                      onListen: () => onListenExample(sense.example!),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({
    required this.example,
    required this.isBusy,
    required this.onListen,
  });

  final String example;
  final bool isBusy;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '“$example”',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Listen to example',
            onPressed: isBusy ? null : onListen,
            icon: const Icon(Icons.record_voice_over_outlined),
          ),
        ],
      ),
    );
  }
}
