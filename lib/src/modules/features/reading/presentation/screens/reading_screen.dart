// reading_screen.dart
// Full reading experience:
//  1. Article view — paragraphs + tappable vocab words
//  2. Vocab bottom sheet — definition + example
//  3. Reading quiz — multiple choice + true/false
//  4. Results screen — score + XP

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/reading/data/reading_models.dart';
import 'package:images/src/modules/features/reading/presentation/bloc/reading_bloc.dart';
import 'package:images/src/modules/features/reading/presentation/bloc/reading_event.dart';
import 'package:images/src/modules/features/reading/presentation/bloc/reading_state.dart';

// ─── Design tokens ────────────────────────────────────
const _purple800 = Color(0xFF3C3489);
const _purple600 = Color(0xFF534AB7);
const _purple200 = Color(0xFFAFA9EC);
const _purple50 = Color(0xFFEEEDFE);
const _teal600 = Color(0xFF0F6E56);
const _teal50 = Color(0xFFE1F5EE);
const _coral600 = Color(0xFF993C1D);
const _coral50 = Color(0xFFFAECE7);
const _blue600 = Color(0xFF185FA5);
const _blue50 = Color(0xFFE6F1FB);
const _amber400 = Color(0xFFEF9F27);
const _amber50 = Color(0xFFFAEEDA);

// ─────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────

class ReadingScreen extends StatelessWidget {
  final String articleId;
  const ReadingScreen({super.key, this.articleId = 'a1'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReadingBloc()..add(ReadingLoaded(articleId)),
      child: const _ReadingView(),
    );
  }
}

// ─────────────────────────────────────────────────────
// VIEW
// ─────────────────────────────────────────────────────

class _ReadingView extends StatelessWidget {
  const _ReadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ReadingBloc, ReadingState>(
        builder: (context, state) {
          if (state is ReadingLoading || state is ReadingInitial) {
            return const Center(
              child: CircularProgressIndicator(color: _purple600),
            );
          }
          if (state is ReadingReady) {
            return _ReadyView(state: state);
          }
          if (state is ReadingFinished) {
            return _ResultsView(state: state);
          }
          if (state is ReadingError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// READY VIEW — article or quiz
// ─────────────────────────────────────────────────────

class _ReadyView extends StatelessWidget {
  final ReadingReady state;
  const _ReadyView({required this.state});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        state.session.quizStarted
            ? _QuizView(state: state)
            : _ArticleView(state: state),

        // Vocab bottom sheet overlay
        if (state.activeVocabWord != null)
          _VocabSheet(word: state.activeVocabWord!),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// ARTICLE VIEW
// ─────────────────────────────────────────────────────

class _ArticleView extends StatefulWidget {
  final ReadingReady state;
  const _ArticleView({required this.state});

  @override
  State<_ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<_ArticleView> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max == 0) return;
    final pct = (_scroll.offset / max * 100).round().clamp(0, 100);
    context.read<ReadingBloc>().add(ReadingScrolled(pct));
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final a = s.article;

    return Column(
      children: [
        // ── Header ──
        _ArticleHeader(
          article: a,
          scrollPercent: s.session.scrollPercent,
          fontSize: s.fontSize,
        ),

        // ── Article content ──
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            children: [
              // Topic + difficulty badge
              Row(
                children: [
                  _Badge(label: a.topic, color: _blue600, bg: _blue50),
                  const SizedBox(width: 8),
                  _Badge(
                    label: _diffLabel(a.difficulty),
                    color: _diffColor(a.difficulty),
                    bg: _diffBg(a.difficulty),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 13,
                    color: Colors.black.withOpacity(0.4),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${a.estimatedMinutes} min · ${a.wordCount} words',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                a.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),

              // Vocab hint
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _purple50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_outlined,
                      color: _purple600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap highlighted words to see their meaning',
                        style: const TextStyle(fontSize: 12, color: _purple600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Paragraphs
              ...a.paragraphs.map(
                (p) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: _ParagraphWidget(
                    paragraph: p,
                    vocabWords: a.vocabWords,
                    fontSize: s.fontSize,
                  ),
                ),
              ),

              // Vocab words summary
              const SizedBox(height: 8),
              _VocabSummaryCard(words: a.vocabWords),
              const SizedBox(height: 24),

              // Start quiz button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _purple600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(
                    Icons.quiz_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: Text(
                    'Start comprehension quiz (${a.questions.length} questions)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onPressed: () => context.read<ReadingBloc>().add(
                    const ReadingQuizStarted(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _diffLabel(ReadingDifficulty d) {
    switch (d) {
      case ReadingDifficulty.easy:
        return 'Easy';
      case ReadingDifficulty.medium:
        return 'Medium';
      case ReadingDifficulty.hard:
        return 'Hard';
    }
  }

  Color _diffColor(ReadingDifficulty d) {
    switch (d) {
      case ReadingDifficulty.easy:
        return _teal600;
      case ReadingDifficulty.medium:
        return _amber400;
      case ReadingDifficulty.hard:
        return _coral600;
    }
  }

  Color _diffBg(ReadingDifficulty d) {
    switch (d) {
      case ReadingDifficulty.easy:
        return _teal50;
      case ReadingDifficulty.medium:
        return _amber50;
      case ReadingDifficulty.hard:
        return _coral50;
    }
  }
}

// ─────────────────────────────────────────────────────
// ARTICLE HEADER
// ─────────────────────────────────────────────────────

class _ArticleHeader extends StatelessWidget {
  final ReadingArticle article;
  final int scrollPercent;
  final double fontSize;

  const _ArticleHeader({
    required this.article,
    required this.scrollPercent,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _purple800,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: _purple200,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reading',
                        style: TextStyle(
                          color: Color(0xFFEEEDFE),
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Comprehension practice',
                        style: TextStyle(color: _purple200, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Font size control
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.read<ReadingBloc>().add(
                        ReadingFontSizeChanged(fontSize - 1),
                      ),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.text_decrease,
                          color: _purple200,
                          size: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${fontSize.round()}',
                        style: const TextStyle(color: _purple200, fontSize: 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.read<ReadingBloc>().add(
                        ReadingFontSizeChanged(fontSize + 1),
                      ),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.text_increase,
                          color: _purple200,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Reading progress bar
          ClipRRect(
            child: LinearProgressIndicator(
              value: scrollPercent / 100,
              minHeight: 3,
              backgroundColor: Colors.white.withOpacity(0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(_amber400),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// PARAGRAPH — tappable vocab words highlighted
// ─────────────────────────────────────────────────────

class _ParagraphWidget extends StatelessWidget {
  final String paragraph;
  final List<VocabWord> vocabWords;
  final double fontSize;

  const _ParagraphWidget({
    required this.paragraph,
    required this.vocabWords,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final vocabSet = {for (final v in vocabWords) v.word.toLowerCase(): v};

    // Split paragraph into words preserving spaces and punctuation
    final words = paragraph.split(RegExp(r'(?<=\s)|(?=\s)'));

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.black87,
          height: 1.75,
          fontFamily: 'serif',
        ),
        children: words.map((word) {
          final clean = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
          final isVocab = vocabSet.containsKey(clean);

          if (isVocab) {
            return WidgetSpan(
              child: GestureDetector(
                onTap: () =>
                    context.read<ReadingBloc>().add(ReadingWordTapped(clean)),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: _purple600.withOpacity(0.6),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Text(
                    word,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: _purple600,
                      fontWeight: FontWeight.w500,
                      height: 1.75,
                    ),
                  ),
                ),
              ),
            );
          }
          return TextSpan(text: word);
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// VOCAB SUMMARY CARD
// ─────────────────────────────────────────────────────

class _VocabSummaryCard extends StatelessWidget {
  final List<VocabWord> words;
  const _VocabSummaryCard({required this.words});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spellcheck, color: _purple600, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Key vocabulary',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...words.map(
            (v) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _purple50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      v.word,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _purple600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      v.definition,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withOpacity(0.65),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// VOCAB BOTTOM SHEET
// ─────────────────────────────────────────────────────

class _VocabSheet extends StatelessWidget {
  final VocabWord word;
  const _VocabSheet({required this.word});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () =>
            context.read<ReadingBloc>().add(const ReadingVocabDismissed()),
        child: Container(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {}, // prevent dismiss when tapping inside
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                border: Border.all(
                  color: Colors.black.withOpacity(0.1),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        word.word,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _purple50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            word.partOfSpeech,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _purple600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    word.definition,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '"${word.exampleSentence}"',
                      style: TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.black.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => context.read<ReadingBloc>().add(
                      const ReadingVocabDismissed(),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _purple600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Got it',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// QUIZ VIEW
// ─────────────────────────────────────────────────────

class _QuizView extends StatelessWidget {
  final ReadingReady state;
  const _QuizView({required this.state});

  @override
  Widget build(BuildContext context) {
    final q = state.currentQuestion;
    if (q == null) return const SizedBox.shrink();

    final answered = state.currentQuestionAnswered;
    final selected = state.session.answers[q.id];

    return Column(
      children: [
        // Quiz header
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            bottom: 16,
          ),
          color: _purple800,
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: _purple200,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Question ${state.currentQuestionIndex + 1} of ${state.article.questions.length}',
                      style: const TextStyle(
                        color: Color(0xFFEEEDFE),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '+${state.article.xpReward} XP',
                    style: const TextStyle(
                      color: _amber400,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value:
                      (state.currentQuestionIndex + 1) /
                      state.article.questions.length,
                  minHeight: 5,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(_amber400),
                ),
              ),
            ],
          ),
        ),

        // Question body
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question type badge
                _Badge(
                  label: q.type == QuestionType.trueFalse
                      ? 'True / False'
                      : 'Multiple choice',
                  color: _blue600,
                  bg: _blue50,
                ),
                const SizedBox(height: 14),

                // Question text
                Text(
                  q.question,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Options
                ...List.generate(q.options.length, (i) {
                  final isSelected = selected == i;
                  final isCorrect = i == q.correctIndex;
                  final showResult = answered;

                  Color bg = Colors.white;
                  Color border = Colors.black.withOpacity(0.12);
                  Color textColor = Colors.black87;
                  Widget? trailing;

                  if (showResult) {
                    if (isCorrect) {
                      bg = _teal50;
                      border = _teal600;
                      textColor = _teal600;
                      trailing = const Icon(
                        Icons.check_circle,
                        color: _teal600,
                        size: 20,
                      );
                    } else if (isSelected && !isCorrect) {
                      bg = _coral50;
                      border = _coral600;
                      textColor = _coral600;
                      trailing = const Icon(
                        Icons.cancel,
                        color: _coral600,
                        size: 20,
                      );
                    }
                  } else if (isSelected) {
                    bg = _purple50;
                    border = _purple600;
                    textColor = _purple600;
                  }

                  return GestureDetector(
                    onTap: answered
                        ? null
                        : () => context.read<ReadingBloc>().add(
                            ReadingAnswerSelected(q.id, i),
                          ),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        border: Border.all(color: border, width: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Option letter
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: border.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + i),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.options[i],
                              style: TextStyle(
                                fontSize: 15,
                                color: textColor,
                                height: 1.4,
                              ),
                            ),
                          ),
                          if (trailing != null) ...[
                            const SizedBox(width: 8),
                            trailing,
                          ],
                        ],
                      ),
                    ),
                  );
                }),

                // Explanation (shown after answering)
                if (answered) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selected == q.correctIndex ? _teal50 : _coral50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              selected == q.correctIndex
                                  ? Icons.check_circle_outline
                                  : Icons.lightbulb_outline,
                              color: selected == q.correctIndex
                                  ? _teal600
                                  : _coral600,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              selected == q.correctIndex
                                  ? 'Correct!'
                                  : 'Not quite',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: selected == q.correctIndex
                                    ? _teal600
                                    : _coral600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          q.explanation,
                          style: TextStyle(
                            fontSize: 13,
                            color: selected == q.correctIndex
                                ? _teal600
                                : _coral600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => context.read<ReadingBloc>().add(
                        state.isLastQuestion
                            ? const ReadingCompleted()
                            : const ReadingNextQuestion(),
                      ),
                      child: Text(
                        state.isLastQuestion
                            ? 'See results'
                            : 'Next question →',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────
// RESULTS VIEW
// ─────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  final ReadingFinished state;
  const _ResultsView({required this.state});

  String get _grade {
    final pct = state.accuracyPercent;
    if (pct >= 90) return 'Excellent!';
    if (pct >= 70) return 'Good job!';
    if (pct >= 50) return 'Keep practising';
    return 'Try again';
  }

  String get _durationLabel {
    final m = state.durationSeconds ~/ 60;
    final s = state.durationSeconds % 60;
    return m > 0 ? '${m}m ${s}s' : '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 28,
              bottom: 32,
              left: 20,
              right: 20,
            ),
            color: _purple800,
            child: Column(
              children: [
                const Text('📖', style: TextStyle(fontSize: 42)),
                const SizedBox(height: 10),
                Text(
                  _grade,
                  style: const TextStyle(
                    color: Color(0xFFEEEDFE),
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.article.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _purple200, fontSize: 13),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Score cards
                  Row(
                    children: [
                      _ScoreCard(
                        label: 'Score',
                        value: '${state.correctCount}/${state.totalQuestions}',
                        color: _purple600,
                        bg: _purple50,
                      ),
                      const SizedBox(width: 10),
                      _ScoreCard(
                        label: 'Accuracy',
                        value: '${state.accuracyPercent}%',
                        color: _teal600,
                        bg: _teal50,
                      ),
                      const SizedBox(width: 10),
                      _ScoreCard(
                        label: 'XP earned',
                        value: '+${state.xpEarned}',
                        color: _amber400,
                        bg: _amber50,
                      ),
                      const SizedBox(width: 10),
                      _ScoreCard(
                        label: 'Time',
                        value: _durationLabel,
                        color: _blue600,
                        bg: _blue50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Accuracy bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withOpacity(0.09),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comprehension score',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: state.accuracyPercent / 100,
                            minHeight: 10,
                            backgroundColor: Colors.black.withOpacity(0.07),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              state.accuracyPercent >= 70
                                  ? _teal600
                                  : state.accuracyPercent >= 50
                                  ? _amber400
                                  : _coral600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${state.accuracyPercent}% — ${_grade.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // CTAs
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _purple600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Read again',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () => context.read<ReadingBloc>().add(
                        const ReadingRestarted(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Colors.black.withOpacity(0.15),
                          width: 0.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          Navigator.popUntil(context, (r) => r.isFirst),
                      child: const Text(
                        'Back to lessons',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;

  const _Badge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final Color bg;

  const _ScoreCard({
    required this.label,
    required this.value,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}
