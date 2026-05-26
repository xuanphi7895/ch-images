import '../domain/english_card_model.dart';

/// Loads English vocabulary cards (mock data; swap for API/DB later).
class EnglishCardRepository {
  Future<List<EnglishCardModel>> fetchCards() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    return const [
      EnglishCardModel(
        id: '1',
        word: 'hello',
        phonetic: '/həˈloʊ/',
        partOfSpeech: 'exclamation',
        definition: 'Used as a greeting or to begin a conversation.',
        example: 'Hello, how are you today?',
        level: 'A1',
      ),
      EnglishCardModel(
        id: '2',
        word: 'achieve',
        phonetic: '/əˈtʃiːv/',
        partOfSpeech: 'verb',
        definition: 'To succeed in doing something after effort.',
        example: 'She achieved her goal of speaking fluently.',
        level: 'B1',
      ),
      EnglishCardModel(
        id: '3',
        word: 'nevertheless',
        phonetic: '/ˌnevərðəˈles/',
        partOfSpeech: 'adverb',
        definition: 'In spite of that; however.',
        example: 'It was raining; nevertheless, we went out.',
        level: 'B2',
      ),
    ];
  }
}
