// ═══════════════════════════════════════════
// BLOC
// ═══════════════════════════════════════════

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:images/src/modules/features/reading/data/reading_models.dart';
import 'package:images/src/modules/features/reading/presentation/bloc/reading_event.dart';
import 'package:images/src/modules/features/reading/presentation/bloc/reading_state.dart';

class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  final DateTime _startTime = DateTime.now();

  // ── Mock article ──────────────────────────────────
  static const _mockArticle = ReadingArticle(
    id: 'a1',
    title: 'How Artificial Intelligence Is Changing Education',
    topic: 'Technology',
    imageUrl: '',
    difficulty: ReadingDifficulty.medium,
    estimatedMinutes: 5,
    wordCount: 380,
    xpReward: 60,
    content:
        '''Artificial intelligence is rapidly transforming the way we learn. '
From personalised lesson plans to instant feedback, AI tools are making education more accessible and effective than ever before.

One of the most significant changes is the rise of adaptive learning platforms. These systems analyse a student\'s performance in real time and automatically adjust the difficulty of exercises. If a student struggles with a concept, the platform immediately provides extra practice and simpler explanations. This means every learner receives a customised experience, rather than following a one-size-fits-all curriculum.

AI-powered writing assistants are also becoming common in classrooms. Tools such as grammar checkers and style analysers help students improve their written English by pointing out errors and suggesting better word choices. Some advanced tools even offer explanations of why a sentence is incorrect, turning every mistake into a learning opportunity.

Language learning apps have embraced AI particularly enthusiastically. Conversation bots allow learners to practise speaking at any hour of the day without the anxiety of speaking with a real person. Speech recognition software evaluates pronunciation and gives instant scores, helping users refine their accent over hundreds of short practice sessions.

However, not everyone is optimistic. Some educators worry that students may become too dependent on AI tools and lose the ability to think critically without assistance. Others raise concerns about data privacy, since these platforms collect detailed records of every student\'s learning behaviour.

Despite these concerns, the consensus among researchers is that AI, when used thoughtfully, can dramatically improve educational outcomes. The key is to treat AI as a helpful assistant rather than a replacement for genuine human understanding and effort.''',
    vocabWords: [
      VocabWord(
        word: 'adaptive',
        definition: 'Able to change or adjust to new conditions.',
        exampleSentence:
            'The adaptive system adjusted the exercises based on her score.',
        partOfSpeech: 'adjective',
      ),
      VocabWord(
        word: 'curriculum',
        definition: 'The subjects and topics included in a course of study.',
        exampleSentence:
            'The new curriculum includes coding lessons for all students.',
        partOfSpeech: 'noun',
      ),
      VocabWord(
        word: 'consensus',
        definition: 'A general agreement among a group of people.',
        exampleSentence:
            'There is a consensus that exercise is good for mental health.',
        partOfSpeech: 'noun',
      ),
      VocabWord(
        word: 'optimistic',
        definition: 'Hopeful and confident about the future.',
        exampleSentence: 'She remained optimistic despite the setbacks.',
        partOfSpeech: 'adjective',
      ),
    ],
    questions: [
      ReadingQuestion(
        id: 'q1',
        question: 'What do adaptive learning platforms do?',
        type: QuestionType.multipleChoice,
        options: [
          'They replace teachers entirely',
          'They adjust exercise difficulty based on student performance',
          'They only work for advanced students',
          'They translate lessons into other languages',
        ],
        correctIndex: 1,
        explanation:
            'The article states that adaptive platforms analyse performance in real time and automatically adjust difficulty.',
      ),
      ReadingQuestion(
        id: 'q2',
        question:
            'AI writing assistants help students by pointing out errors and suggesting better word choices.',
        type: QuestionType.trueFalse,
        options: ['True', 'False'],
        correctIndex: 0,
        explanation:
            'Correct — the article says these tools point out errors and suggest better word choices.',
      ),
      ReadingQuestion(
        id: 'q3',
        question:
            'What concern do some educators have about AI tools in education?',
        type: QuestionType.multipleChoice,
        options: [
          'AI tools are too expensive',
          'Students may become dependent and lose critical thinking',
          'AI cannot understand English grammar',
          'Students prefer human teachers',
        ],
        correctIndex: 1,
        explanation:
            'The article mentions concerns that students may become too dependent on AI and lose critical thinking ability.',
      ),
      ReadingQuestion(
        id: 'q4',
        question:
            'According to the article, AI should replace human understanding and effort.',
        type: QuestionType.trueFalse,
        options: ['True', 'False'],
        correctIndex: 1,
        explanation:
            'The article says AI should be treated as a helpful assistant, NOT a replacement for genuine human understanding.',
      ),
    ],
  );

  ReadingBloc() : super(const ReadingInitial()) {
    on<ReadingLoaded>(_onLoaded);
    on<ReadingScrolled>(_onScrolled);
    on<ReadingWordTapped>(_onWordTapped);
    on<ReadingVocabDismissed>(_onVocabDismissed);
    on<ReadingQuizStarted>(_onQuizStarted);
    on<ReadingAnswerSelected>(_onAnswerSelected);
    on<ReadingNextQuestion>(_onNextQuestion);
    on<ReadingCompleted>(_onCompleted);
    on<ReadingRestarted>(_onRestarted);
    on<ReadingFontSizeChanged>(_onFontSizeChanged);
  }

  Future<void> _onLoaded(
    ReadingLoaded event,
    Emitter<ReadingState> emit,
  ) async {
    emit(const ReadingLoading());
    await Future.delayed(const Duration(milliseconds: 400));

    emit(
      ReadingReady(
        article: _mockArticle,
        fontSize: 16.0,
        session: const ReadingSession(
          articleId: 'a1',
          currentParagraph: 0,
          highlightedWordIds: {},
          answers: {},
          quizStarted: false,
          completed: false,
          scrollPercent: 0,
        ),
      ),
    );
  }

  void _onScrolled(ReadingScrolled event, Emitter<ReadingState> emit) {
    if (state is! ReadingReady) return;
    final s = state as ReadingReady;
    emit(s.copyWith(session: s.session.copyWith(scrollPercent: event.percent)));
  }

  void _onWordTapped(ReadingWordTapped event, Emitter<ReadingState> emit) {
    if (state is! ReadingReady) return;
    final s = state as ReadingReady;

    // Find vocab word (case-insensitive)
    final vocab = s.article.vocabWords
        .where((v) => v.word.toLowerCase() == event.word.toLowerCase())
        .toList();

    if (vocab.isEmpty) return;
    emit(s.copyWith(activeVocabWord: vocab.first));
  }

  void _onVocabDismissed(
    ReadingVocabDismissed event,
    Emitter<ReadingState> emit,
  ) {
    if (state is! ReadingReady) return;
    emit((state as ReadingReady).copyWith(clearVocab: true));
  }

  void _onQuizStarted(ReadingQuizStarted event, Emitter<ReadingState> emit) {
    if (state is! ReadingReady) return;
    final s = state as ReadingReady;
    emit(
      s.copyWith(
        session: s.session.copyWith(quizStarted: true),
        currentQuestionIndex: 0,
      ),
    );
  }

  void _onAnswerSelected(
    ReadingAnswerSelected event,
    Emitter<ReadingState> emit,
  ) {
    if (state is! ReadingReady) return;
    final s = state as ReadingReady;
    if (s.session.answers.containsKey(event.questionId)) return;

    final updated = Map<String, int>.from(s.session.answers)
      ..[event.questionId] = event.selectedIndex;

    emit(s.copyWith(session: s.session.copyWith(answers: updated)));
  }

  void _onNextQuestion(ReadingNextQuestion event, Emitter<ReadingState> emit) {
    if (state is! ReadingReady) return;
    final s = state as ReadingReady;

    if (s.isLastQuestion) {
      add(const ReadingCompleted());
      return;
    }

    emit(s.copyWith(currentQuestionIndex: s.currentQuestionIndex + 1));
  }

  void _onCompleted(ReadingCompleted event, Emitter<ReadingState> emit) {
    if (state is! ReadingReady) return;
    final s = state as ReadingReady;
    final duration = DateTime.now().difference(_startTime).inSeconds;

    emit(
      ReadingFinished(
        article: s.article,
        correctCount: s.correctCount,
        totalQuestions: s.article.questions.length,
        xpEarned: s.xpEarned,
        durationSeconds: duration,
      ),
    );
  }

  void _onRestarted(ReadingRestarted event, Emitter<ReadingState> emit) {
    add(ReadingLoaded(_mockArticle.id));
  }

  void _onFontSizeChanged(
    ReadingFontSizeChanged event,
    Emitter<ReadingState> emit,
  ) {
    if (state is! ReadingReady) return;
    emit(
      (state as ReadingReady).copyWith(
        fontSize: event.fontSize.clamp(14.0, 22.0),
      ),
    );
  }
}
