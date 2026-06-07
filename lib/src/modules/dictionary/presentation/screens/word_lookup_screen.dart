import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:images/src/modules/dictionary/data/dictionary_api.dart';
import 'package:images/src/modules/dictionary/data/dictionary_audio.dart';
import 'package:images/src/modules/dictionary/presentation/widgets/user_pronunciation_panel.dart';
import 'package:images/src/utils/color.dart';

class WordLookupScreen extends StatelessWidget {
  const WordLookupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WordLookupBody();
  }
}

class _WordLookupBody extends StatefulWidget {
  const _WordLookupBody();

  @override
  State<_WordLookupBody> createState() => _WordLookupBodyState();
}

class _WordLookupBodyState extends State<_WordLookupBody>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  Dictionary? _entry;
  String? _error;
  bool _loading = false;
  List<String> _recentWords = ['hello', 'beautiful', 'knowledge', 'flutter', 'language'];

  late final DictionaryAudio _audio;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _audio = DictionaryAudio();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    _audio.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _search([String? word]) async {
    final query = (word ?? _controller.text).trim();
    if (query.isEmpty) return;

    _controller.text = query;
    _focusNode.unfocus();

    setState(() {
      _loading = true;
      _error = null;
      _entry = null;
    });

    try {
      final uri = Uri.parse(
        'https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(query)}',
      );
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        final entry = Dictionary.fromJson(list.first as Map<String, dynamic>);

        // Add to recent words
        setState(() {
          _recentWords.remove(query.toLowerCase());
          _recentWords.insert(0, query.toLowerCase());
          if (_recentWords.length > 10) _recentWords = _recentWords.sublist(0, 10);
          _entry = entry;
        });

        // Scroll to top of results
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      } else if (res.statusCode == 404) {
        setState(() => _error = 'Word not found. Try a different spelling.');
      } else {
        setState(() => _error = 'Server error (${res.statusCode}). Please try again.');
      }
    } catch (e) {
      setState(() => _error = 'No internet connection. Please check your network.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _listenWord() async {
    if (_entry == null) return;
    await _audio.playWord(
      audioUrl: _entry!.firstAudioUrl,
      word: _entry!.word,
    );
    if (mounted) setState(() {});
  }

  Future<void> _listenExample(String text) async {
    await _audio.speakExample(text);
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Header ──────────────
            _buildSearchHeader(),
            // ── Body ───────────────────────
            Expanded(
              child: _loading
                  ? _buildLoadingSkeleton()
                  : _error != null
                      ? _buildError()
                      : _entry != null
                          ? _buildResults()
                          : _buildEmptyState(),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEARCH HEADER
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          const Row(
            children: [
              Text(
                '📖',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(width: 10),
              Text(
                'Dictionary',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: CustomColors.Purple900,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Search bar
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? CustomColors.Purple600
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.search_rounded,
                  color: Colors.black.withOpacity(0.35),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.Purple900,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search for a word...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black.withOpacity(0.3),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onSubmitted: (_) => _search(),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      setState(() {
                        _entry = null;
                        _error = null;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.black.withOpacity(0.3),
                        size: 20,
                      ),
                    ),
                  ),
                // Search button
                GestureDetector(
                  onTap: () => _search(),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [CustomColors.Purple600, CustomColors.Purple900],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // EMPTY STATE — recent words
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildEmptyState() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 32),
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: CustomColors.Purple50,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔍', style: TextStyle(fontSize: 44)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'Look up any English word',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: CustomColors.Purple900,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            'Get definitions, phonetics, examples & more',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withOpacity(0.4),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Recent searches
        if (_recentWords.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.history_rounded,
                  size: 16, color: Colors.black.withOpacity(0.3)),
              const SizedBox(width: 6),
              Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black.withOpacity(0.4),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentWords.map((w) {
              return GestureDetector(
                onTap: () => _search(w),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: CustomColors.Purple200.withOpacity(0.4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    w,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.Purple600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOADING SKELETON
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLoadingSkeleton() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        final shimmerValue = _shimmerController.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSkeletonCard(shimmerValue, height: 120),
            const SizedBox(height: 12),
            _buildSkeletonCard(shimmerValue, height: 200),
            const SizedBox(height: 12),
            _buildSkeletonCard(shimmerValue, height: 160),
          ],
        );
      },
    );
  }

  Widget _buildSkeletonCard(double shimmer, {required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment(-1.0 + 2.0 * shimmer, 0),
          end: Alignment(1.0 + 2.0 * shimmer, 0),
          colors: const [
            Color(0xFFEEEDFE),
            Color(0xFFF8F8FF),
            Color(0xFFEEEDFE),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ERROR STATE
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF0F0),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('😕', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: CustomColors.Purple900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check your spelling or try another word',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                setState(() {
                  _error = null;
                  _entry = null;
                });
                _focusNode.requestFocus();
              },
              icon: const Icon(Icons.search_rounded, size: 18),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                backgroundColor: CustomColors.Purple600,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESULTS VIEW
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildResults() {
    final entry = _entry!;

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // ── Word Hero Card ─────────────────
        _buildWordHeroCard(entry),
        const SizedBox(height: 16),

        // ── Pronunciation Panel ────────────
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: UserPronunciationPanel(word: entry.word),
          ),
        ),
        const SizedBox(height: 16),

        // ── Meanings ───────────────────────
        ...entry.meanings.asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMeaningCard(e.value, e.key),
          );
        }),
      ],
    );
  }

  // ── Word Hero Card ───────────────────────
  Widget _buildWordHeroCard(Dictionary entry) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CustomColors.Purple900, CustomColors.Purple600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: CustomColors.Purple600.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word + listen button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.word,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    if (entry.primaryPhonetic != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          entry.primaryPhonetic!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Play pronunciation
              GestureDetector(
                onTap: _audio.isBusy ? null : _listenWord,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                    ),
                  ),
                  child: _audio.isBusy
                      ? const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Part-of-speech chips row
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: entry.meanings.map((m) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  m.partOfSpeech,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── Meaning Card ─────────────────────────
  Widget _buildMeaningCard(Meaning meaning, int index) {
    // Pick a color accent per index
    final accentColors = [
      (CustomColors.Purple600, CustomColors.Purple50),
      (CustomColors.Teal600, CustomColors.Teal50),
      (CustomColors.Blue600, CustomColors.Blue50),
      (CustomColors.Coral600, CustomColors.Coral50),
    ];
    final (accentColor, accentBg) = accentColors[index % accentColors.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: part of speech
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: accentBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      meaning.partOfSpeech.isNotEmpty
                          ? meaning.partOfSpeech[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  meaning.partOfSpeech,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: accentColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${meaning.definitions.length} definition${meaning.definitions.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Definitions
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: meaning.definitions.asMap().entries.map((e) {
                final idx = e.key;
                final def = e.value;
                return _buildDefinitionItem(def, idx + 1, accentColor);
              }).toList(),
            ),
          ),

          // Synonyms
          if (meaning.synonyms != null && meaning.synonyms!.isNotEmpty)
            _buildWordChipRow(
              label: 'Synonyms',
              icon: Icons.add_circle_outline,
              words: meaning.synonyms!,
              chipColor: CustomColors.Teal50,
              chipTextColor: CustomColors.Teal600,
            ),

          // Antonyms
          if (meaning.antonyms != null && meaning.antonyms!.isNotEmpty)
            _buildWordChipRow(
              label: 'Antonyms',
              icon: Icons.remove_circle_outline,
              words: meaning.antonyms!,
              chipColor: CustomColors.Coral50,
              chipTextColor: CustomColors.Coral600,
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Definition item ──────────────────────
  Widget _buildDefinitionItem(Definition def, int number, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Number badge
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 1),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  def.definition,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A2E),
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          // Example sentence
          if (def.example != null && def.example!.trim().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(left: 34, top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8FC),
                borderRadius: BorderRadius.circular(12),
                border: Border(
                  left: BorderSide(
                    color: accentColor.withOpacity(0.4),
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💬 ', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Text(
                      '"${def.example!}"',
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF555570),
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => _listenExample(def.example!),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.volume_up_rounded,
                        color: accentColor,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Synonym / Antonym chips row ──────────
  Widget _buildWordChipRow({
    required String label,
    required IconData icon,
    required List<String> words,
    required Color chipColor,
    required Color chipTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: chipTextColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: chipTextColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: words.take(8).map((w) {
              return GestureDetector(
                onTap: () => _search(w),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    w,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: chipTextColor,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
