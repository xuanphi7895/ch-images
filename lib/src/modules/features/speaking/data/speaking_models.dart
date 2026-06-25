// speaking_models.dart

import 'package:equatable/equatable.dart';

// ─── Enums ────────────────────────────────────────────

enum SpeakingScenario {
  jobInterview,
  airportCheckin,
  restaurantOrder,
  hotelBooking,
  doctorVisit,
  casualConversation,
}

enum SpeakingDifficulty { beginner, intermediate, advanced }

enum TurnRole { user, ai, system }

enum FeedbackType { pronunciation, grammar, vocabulary, fluency }

// ─── Scenario model ───────────────────────────────────

class SpeakingScenarioData extends Equatable {
  final String id;
  final SpeakingScenario scenario;
  final String title;
  final String description;
  final String aiRole; // e.g. "Interviewer"
  final String userRole; // e.g. "Job applicant"
  final String openingLine; // AI's first message
  final SpeakingDifficulty difficulty;
  final int estimatedMinutes;
  final int xpReward;
  final List<String> targetPhrases; // phrases the user should try to use

  const SpeakingScenarioData({
    required this.id,
    required this.scenario,
    required this.title,
    required this.description,
    required this.aiRole,
    required this.userRole,
    required this.openingLine,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.xpReward,
    required this.targetPhrases,
  });

  @override
  List<Object?> get props => [id, scenario];
}

// ─── Conversation turn ────────────────────────────────

class SpeakingTurn extends Equatable {
  final String id;
  final TurnRole role;
  final String text;
  final DateTime timestamp;
  final SpeakingFeedback? feedback; // null until evaluated

  const SpeakingTurn({
    required this.id,
    required this.role,
    required this.text,
    required this.timestamp,
    this.feedback,
  });

  SpeakingTurn withFeedback(SpeakingFeedback fb) => SpeakingTurn(
    id: id,
    role: role,
    text: text,
    timestamp: timestamp,
    feedback: fb,
  );

  @override
  List<Object?> get props => [id, role, text, timestamp, feedback];
}

// ─── Feedback for a user turn ─────────────────────────

class SpeakingFeedback extends Equatable {
  final int pronunciationScore; // 0–100
  final int grammarScore;
  final int vocabularyScore;
  final int fluencyScore;
  final List<FeedbackItem> items;
  final String correctedText; // grammatically corrected version
  final String nativeSuggestion; // how a native speaker might say it

  const SpeakingFeedback({
    required this.pronunciationScore,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.fluencyScore,
    required this.items,
    required this.correctedText,
    required this.nativeSuggestion,
  });

  int get overallScore =>
      ((pronunciationScore + grammarScore + vocabularyScore + fluencyScore) / 4)
          .round();

  @override
  List<Object?> get props => [
    pronunciationScore,
    grammarScore,
    vocabularyScore,
    fluencyScore,
    items,
  ];
}

class FeedbackItem extends Equatable {
  final FeedbackType type;
  final String issue;
  final String suggestion;

  const FeedbackItem({
    required this.type,
    required this.issue,
    required this.suggestion,
  });

  @override
  List<Object?> get props => [type, issue, suggestion];
}

// ─── Session result ───────────────────────────────────

class SpeakingResult extends Equatable {
  final String scenarioId;
  final int totalTurns;
  final int avgPronunciation;
  final int avgGrammar;
  final int avgVocabulary;
  final int avgFluency;
  final int xpEarned;
  final int durationSeconds;
  final List<String> usedTargetPhrases;

  const SpeakingResult({
    required this.scenarioId,
    required this.totalTurns,
    required this.avgPronunciation,
    required this.avgGrammar,
    required this.avgVocabulary,
    required this.avgFluency,
    required this.xpEarned,
    required this.durationSeconds,
    required this.usedTargetPhrases,
  });

  int get overallScore =>
      ((avgPronunciation + avgGrammar + avgVocabulary + avgFluency) / 4)
          .round();

  @override
  List<Object?> get props => [scenarioId, totalTurns, overallScore];
}
