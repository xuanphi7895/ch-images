import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:images/src/modules/features/ai_tutor/data/ai_tutor_model.dart';
import 'package:images/src/modules/features/ai_tutor/presentation/bloc/ai_tutor_event.dart';
import 'package:images/src/modules/features/ai_tutor/presentation/bloc/ai_tutor_state.dart';

class AiTutorBloc extends Bloc<AiTutorEvent, AiTutorState> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTtsInitialized = false;

  AiTutorBloc() : super(const AiTutorInitial()) {
    on<AiTutorSessionStarted>(_onSessionStarted);
    on<AiTutorMessageSent>(_onMessageSent);
    on<AiTutorVoiceSimulationStarted>(_onVoiceSimulationStarted);
    on<AiTutorVoiceSimulationFinished>(_onVoiceSimulationFinished);
    on<AiTutorMessageTTSRequested>(_onMessageTTSRequested);
    on<AiTutorTTSStopped>(_onTTSStopped);
    on<AiTutorTranslationToggled>(_onTranslationToggled);

    _initTts();
  }

  void _initTts() {
    try {
      _flutterTts.setCompletionHandler(() {
        add(const AiTutorTTSStopped());
      });
      _isTtsInitialized = true;
    } catch (e) {
      // Quietly log error if TTS is not available on this platform/device
      print('TTS initialization failed: $e');
    }
  }

  @override
  Future<void> close() {
    try {
      _flutterTts.stop();
    } catch (_) {}
    return super.close();
  }

  Future<void> _onSessionStarted(
    AiTutorSessionStarted event,
    Emitter<AiTutorState> emit,
  ) async {
    final tutor = event.tutor;
    final initialMessage = ChatMessage(
      id: 'init_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'tutor',
      text: tutor.introMessage,
      translation: _getTranslation(tutor.introMessage, tutor.language),
      timestamp: DateTime.now(),
    );

    emit(AiTutorReady(
      tutor: tutor,
      messages: [initialMessage],
    ));

    // Auto-read intro message if TTS is ready
    _speak(tutor.introMessage, tutor.language, initialMessage.id);
  }

  Future<void> _onMessageSent(
    AiTutorMessageSent event,
    Emitter<AiTutorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AiTutorReady) return;

    final userText = event.text.trim();
    if (userText.isEmpty) return;

    // Stop current TTS playing if any
    try {
      await _flutterTts.stop();
    } catch (_) {}

    // Check for grammar mistakes
    final correction = _checkGrammar(userText);

    final userMessage = ChatMessage(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'user',
      text: userText,
      translation: _getTranslation(userText, currentState.tutor.language),
      timestamp: DateTime.now(),
      correction: correction,
    );

    final updatedMessages = List<ChatMessage>.from(currentState.messages)..add(userMessage);

    emit(currentState.copyWith(
      messages: updatedMessages,
      isTutorTyping: true,
      playingTTSMessageId: null,
    ));

    // Simulate thinking/typing delay
    await Future.delayed(const Duration(milliseconds: 1600));

    final replyText = _generateTutorReply(userText, currentState.tutor);
    final replyTranslation = _getTranslation(replyText, currentState.tutor.language);

    final tutorMessage = ChatMessage(
      id: 'tutor_${DateTime.now().millisecondsSinceEpoch}',
      sender: 'tutor',
      text: replyText,
      translation: replyTranslation,
      timestamp: DateTime.now(),
    );

    final finalMessages = List<ChatMessage>.from(updatedMessages)..add(tutorMessage);

    emit(currentState.copyWith(
      messages: finalMessages,
      isTutorTyping: false,
    ));

    // Auto-read response
    _speak(replyText, currentState.tutor.language, tutorMessage.id);
  }

  void _onVoiceSimulationStarted(
    AiTutorVoiceSimulationStarted event,
    Emitter<AiTutorState> emit,
  ) {
    final currentState = state;
    if (currentState is! AiTutorReady) return;

    emit(currentState.copyWith(isRecordingVoice: true));
  }

  Future<void> _onVoiceSimulationFinished(
    AiTutorVoiceSimulationFinished event,
    Emitter<AiTutorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AiTutorReady) return;

    emit(currentState.copyWith(isRecordingVoice: false));
    add(AiTutorMessageSent(event.simulatedText));
  }

  Future<void> _onMessageTTSRequested(
    AiTutorMessageTTSRequested event,
    Emitter<AiTutorState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AiTutorReady) return;

    // Toggle off if clicking the currently playing message
    if (currentState.playingTTSMessageId == event.messageId) {
      try {
        await _flutterTts.stop();
      } catch (_) {}
      emit(currentState.copyWith(playingTTSMessageId: null));
      return;
    }

    emit(currentState.copyWith(playingTTSMessageId: event.messageId));
    _speak(event.text, currentState.tutor.language, event.messageId);
  }

  void _onTTSStopped(
    AiTutorTTSStopped event,
    Emitter<AiTutorState> emit,
  ) {
    final currentState = state;
    if (currentState is! AiTutorReady) return;

    emit(currentState.copyWith(playingTTSMessageId: null));
  }

  void _onTranslationToggled(
    AiTutorTranslationToggled event,
    Emitter<AiTutorState> emit,
  ) {
    final currentState = state;
    if (currentState is! AiTutorReady) return;

    final updated = currentState.messages.map((m) {
      if (m.id == event.messageId) {
        return m.copyWith(showTranslation: !m.showTranslation);
      }
      return m;
    }).toList();

    emit(currentState.copyWith(messages: updated));
  }

  // Helper function to synthesize speech
  Future<void> _speak(String text, String language, String messageId) async {
    if (!_isTtsInitialized) return;
    try {
      String languageCode = 'en-US';
      if (language.toLowerCase() == 'spanish') {
        languageCode = 'es-ES';
      } else if (language.toLowerCase() == 'french') {
        languageCode = 'fr-FR';
      }

      await _flutterTts.setLanguage(languageCode);
      await _flutterTts.setSpeechRate(0.45); // Slightly slower for language learners
      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS speak error: $e');
      add(const AiTutorTTSStopped());
    }
  }

  // Simple static translation map for core dialogs
  String _getTranslation(String text, String currentLang) {
    // Basic translations mapping English <-> Vietnamese or English <-> Spanish
    final textLower = text.toLowerCase().trim();
    if (currentLang.toLowerCase() == 'spanish') {
      if (textLower.contains('hola')) {
        return 'Hello! How are you? I\'m very happy to talk with you. What would you like to speak about today?';
      }
      if (textLower.contains('viajar') || textLower.contains('viaje')) {
        return 'Excellent topic! Traveling is the best way to learn. Imagine you are checking into a hotel in Madrid. How would you request a room?';
      }
      if (textLower.contains('subjuntivo')) {
        return 'Ah, the subjunctive! It is used to express doubts, desires, or emotions. For example: "Quiero que hables español" (I want you to speak Spanish).';
      }
      if (textLower.contains('comida')) {
        return 'Mmm! Traditional Spanish food is amazing. Have you ever tried tapas or paella? What is your favorite dish?';
      }
      return 'I understand. That\'s very interesting. Tell me a bit more about that, please.';
    } else {
      // English to Vietnamese translations for learning
      if (textLower.contains('hello') || textLower.contains('hi')) {
        return 'Xin chào! Rất vui được gặp bạn. Chúng ta cùng luyện nói hôm nay nhé. Bạn có ý tưởng gì chưa?';
      }
      if (textLower.contains('travel') || textLower.contains('trip')) {
        return 'Du lịch là một chủ đề thú vị! Nếu ngày mai bạn có thể ghé thăm bất kỳ quốc gia nào, bạn sẽ đi đâu?';
      }
      if (textLower.contains('interview') || textLower.contains('job')) {
        return 'Hãy luyện tập phỏng vấn thử nhé! Điểm mạnh lớn nhất trong công việc của bạn là gì?';
      }
      if (textLower.contains('ielts') || textLower.contains('exam')) {
        return 'Hãy bắt đầu đề thi nói IELTS phần 2: Hãy kể về một cuốn sách hoặc bộ phim ảnh hưởng sâu sắc đến bạn.';
      }
      if (textLower.contains('accent') || textLower.contains('pronounce')) {
        return 'Luyện phát âm là việc tập luyện cơ miệng! Hãy thử lặp lại câu này: "She sells seashells by the seashore".';
      }
      if (textLower.contains('learna-x')) {
        return 'Chào bạn! Tôi là Learna-X. Chúng ta cùng thực hành nói tiếng Anh tự nhiên hôm nay nhé.';
      }
      if (textLower.contains('hey there') || textLower.contains('hazel')) {
        return 'Chào bạn! Mình là Hazel. Rất vui được trò chuyện với bạn hôm nay! Ngày hôm nay của bạn thế nào?';
      }
      if (textLower.contains('good day') || textLower.contains('darius')) {
        return 'Xin chào. Tôi là Darius. Rất vui được cùng bạn nâng cao sự lưu loát và cấu trúc câu nói logic.';
      }
      if (textLower.contains('jasmine') || textLower.contains('corporate')) {
        return 'Chào bạn! Jasmine đây. Hãy cùng chuẩn bị để bạn tự tin bước vào môi trường doanh nghiệp nhé.';
      }
      return 'Tôi hiểu rồi. Góc nhìn đó rất thú vị. Bạn có thể chia sẻ chi tiết hơn một chút không?';
    }
  }

  GrammarCorrection? _checkGrammar(String text) {
    final textLower = text.toLowerCase();

    if (textLower.contains('to learning')) {
      return const GrammarCorrection(
        original: 'to learning',
        corrected: 'to learn',
        explanation: 'In English, the infinitive particle "to" must be followed by the base form of the verb (bare infinitive), not the gerund (-ing) form. Example: "I want to learn English".',
      );
    }
    if (RegExp(r'\b(he|she|it)\s+don\b').hasMatch(textLower)) {
      final match = RegExp(r'\b(he|she|it)\s+don\b').firstMatch(textLower);
      final word = match?.group(1) ?? 'he';
      return GrammarCorrection(
        original: '$word don\'t',
        corrected: '$word doesn\'t',
        explanation: 'Subject-verb agreement: the third-person singular subjects (he, she, it) require the negative auxiliary verb "doesn\'t" (does not) instead of "don\'t".',
      );
    }
    if (textLower.contains('speak english good') ||
        textLower.contains('speak spanish good') ||
        textLower.contains('speak french good') ||
        textLower.contains('talk english good')) {
      return const GrammarCorrection(
        original: 'speak english good',
        corrected: 'speak English well',
        explanation: 'Adverbs modify verbs, whereas adjectives modify nouns. Use the adverb "well" to describe how you perform the action of speaking. Also, capitalize "English".',
      );
    }
    if (textLower.contains('study every day') &&
        (textLower.contains('she study') || textLower.contains('he study'))) {
      final original = textLower.contains('she study') ? 'she study' : 'he study';
      final corrected = textLower.contains('she study') ? 'she studies' : 'he studies';
      return GrammarCorrection(
        original: original,
        corrected: corrected,
        explanation: 'For third-person singular present tense verbs, you must add "-s" or "-es" (study -> studies).',
      );
    }
    if (RegExp(r'\bi\s+have\s+(\d+|twenty|thirty|fourty)\s+years\s+old\b').hasMatch(textLower)) {
      return const GrammarCorrection(
        original: 'have ... years old',
        corrected: 'am ... years old',
        explanation: 'In English, ages are expressed using the verb "to be" (e.g., "I am 20 years old") rather than "to have" (which is common in Spanish "tener" or French "avoir").',
      );
    }
    // Simple nationality capitalization check
    if (textLower.contains('english') && !text.contains('English')) {
      return const GrammarCorrection(
        original: 'english',
        corrected: 'English',
        explanation: 'Languages and nationalities are proper nouns in English and must always be capitalized.',
      );
    }
    if (textLower.contains('spanish') && !text.contains('Spanish')) {
      return const GrammarCorrection(
        original: 'spanish',
        corrected: 'Spanish',
        explanation: 'Languages and nationalities are proper nouns in English and must always be capitalized.',
      );
    }

    return null;
  }

  String _generateTutorReply(String userText, AiTutor tutor) {
    final textLower = userText.toLowerCase();

    // Mateo (Spanish Tutor)
    if (tutor.id == 'mateo') {
      if (textLower.contains('hola') || textLower.contains('buenos')) {
        return '¡Hola! ¿Cómo estás hoy? Es un placer saludarte. ¿Prefieres que hablemos sobre viajes, cultura o gramática?';
      }
      if (textLower.contains('viaje') || textLower.contains('viajar') || textLower.contains('hotel')) {
        return '¡Me encanta viajar! Vamos a practicar un juego de rol. Estás en la recepción de un hotel en Madrid. Dime: "¿Tiene una habitación libre para esta noche?"';
      }
      if (textLower.contains('subjuntivo') || textLower.contains('gramatica')) {
        return 'El subjuntivo es divertido. Se usa para expresar deseos. Intenta completar esta frase: "Quiero que tú..." y dime tu respuesta.';
      }
      if (textLower.contains('comida') || textLower.contains('tapas') || textLower.contains('paella')) {
        return '¡La paella es deliciosa! En España comemos muy tarde, sobre las dos de la tarde. ¿Cuál es tu plato de comida tradicional favorito?';
      }
      return '¡Qué interesante! Tu pronunciación y vocabulario están mejorando mucho. ¿De qué más te gustaría platicar en español?';
    }

    // English Tutors
    if (textLower.contains('hello') || textLower.contains('hi') || textLower.contains('hey')) {
      if (tutor.id == 'hazel') {
        return 'Hey! I\'m doing awesome, thanks for asking! Let\'s talk about something fun. What\'s your favorite movie or TV show?';
      }
      if (tutor.id == 'darius') {
        return 'Hello there. Let us start today\'s session by checking your vocabulary usage. Please describe how you spent your morning.';
      }
      if (tutor.id == 'jasmine') {
        return 'Hi! Ready to boost your professional speaking skills? Tell me, what industry do you work in (or plan to work in)?';
      }
      return 'Hello! I am ready to practice English with you. What topic would you like to explore together?';
    }

    if (textLower.contains('travel') || textLower.contains('trip') || textLower.contains('vacation')) {
      return 'Traveling is great! If you could visit any place in the world, what would be your top destination and why?';
    }

    if (textLower.contains('interview') || textLower.contains('job') || textLower.contains('work')) {
      if (tutor.id == 'jasmine') {
        return 'Great choice. Let\'s practice this common question: "Why do you want to work for our company?" Try to structure your answer using the STAR method.';
      }
      return 'Preparing for interviews is so important! What do you find most difficult when answering professional questions in English?';
    }

    if (textLower.contains('ielts') || textLower.contains('exam') || textLower.contains('test')) {
      if (tutor.id == 'darius') {
        return 'Excellent. For IELTS Speaking, coherence is key. Try to speak for a full minute about a memorable vacation. Go ahead when you are ready.';
      }
      return 'Taking exams can be stressful, but practice makes perfect! Shall we work on organizing your thoughts into clear structures?';
    }

    if (textLower.contains('accent') || textLower.contains('pronounce') || textLower.contains('pronunciation')) {
      if (tutor.id == 'learna_x') {
        return 'Perfect! Try repeating after me to practice linking sounds: "What do you do?" sounds like "Whadya do?". Give it a try!';
      }
      return 'Let\'s practice word stress! Focus on stressing the correct syllable. For instance: "pho-TO-gra-pher" vs "PHO-to-graph". Try saying them!';
    }

    // Default responses based on tutor personality
    switch (tutor.id) {
      case 'hazel':
        return 'Oh wow! I totally get what you mean. That is super cool! Tell me more about it, I\'d love to know what you think!';
      case 'darius':
        return 'Indeed. That is a well-considered response. To improve your score, try to incorporate advanced vocabulary like "subsequent" or "furthermore". What are your thoughts?';
      case 'jasmine':
        return 'Very clear. Communicating key value propositions is vital. Let\'s build on that: how would you present this solution to a client or team member?';
      case 'learna_x':
        return 'I understand. Your sentence structure is solid. Let\'s try to expand this. What do you think is the main benefit or challenge of this situation?';
      default:
        return 'Fascinating. Language learning is all about consistency. You are doing a wonderful job. What would you like to practice next?';
    }
  }
}
