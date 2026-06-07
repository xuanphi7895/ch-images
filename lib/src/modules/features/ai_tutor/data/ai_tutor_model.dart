import 'package:equatable/equatable.dart';

class AiTutor extends Equatable {
  final String id;
  final String name;
  final String accent;
  final String avatarUrl;
  final String language;
  final String level;
  final List<String> specialties;
  final String bio;
  final String introMessage;
  final List<String> starters;

  const AiTutor({
    required this.id,
    required this.name,
    required this.accent,
    required this.avatarUrl,
    required this.language,
    required this.level,
    required this.specialties,
    required this.bio,
    required this.introMessage,
    required this.starters,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        accent,
        avatarUrl,
        language,
        level,
        specialties,
        bio,
        introMessage,
        starters,
      ];

  static const List<AiTutor> mockTutors = [
    AiTutor(
      id: 'learna_x',
      name: 'Learna-X',
      accent: 'Neutral English Accent',
      avatarUrl: 'https://codewayimages.net/cdn-cgi/imagedelivery/rLEmnyzM9Rd0IW4YgVrjXg/aitutorweb/assets/images/landing/heros/learna-x.png/w=748,q=85',
      language: 'English',
      level: 'All Levels',
      specialties: ['General Fluency', 'Accent Reduction', 'Adaptive Learning'],
      bio: 'Your advanced AI tutor. I dynamically adapt to your speaking pace, correct grammar errors, and help polish your natural flow.',
      introMessage: 'Hello! I am Learna-X. Let\'s practice speaking naturally today. What topic would you like to discuss, or shall we start with some warm-ups?',
      starters: [
        'How can I improve my accent?',
        'Let\'s talk about traveling.',
        'Can we practice a job interview?'
      ],
    ),
    AiTutor(
      id: 'hazel',
      name: 'Hazel',
      accent: 'American English Accent',
      avatarUrl: 'https://codewayimages.net/cdn-cgi/imagedelivery/rLEmnyzM9Rd0IW4YgVrjXg/aitutorweb/assets/images/landing/heros/hazel.png/w=432,q=85',
      language: 'English',
      level: 'Beginner - Intermediate',
      specialties: ['Daily Conversation', 'Slangs & Idioms', 'Confidence Building'],
      bio: 'Super friendly and energetic! I focus on making conversation practice fun, casual, and low-pressure. Don\'t worry about mistakes!',
      introMessage: 'Hey there! I\'m Hazel. So excited to chat with you today! Don\'t worry about being perfect, let\'s just talk. How was your day?',
      starters: [
        'My day was great, how about yours?',
        'Help me practice casual greetings.',
        'Let\'s talk about movies and pop culture!'
      ],
    ),
    AiTutor(
      id: 'darius',
      name: 'Darius',
      accent: 'British English Accent',
      avatarUrl: 'https://codewayimages.net/cdn-cgi/imagedelivery/rLEmnyzM9Rd0IW4YgVrjXg/aitutorweb/assets/images/landing/heros/darius.png/w=556,q=85',
      language: 'English',
      level: 'Intermediate - Advanced',
      specialties: ['IELTS Preparation', 'Academic Vocab', 'Structured Feedback'],
      bio: 'Focused and encouraging. I specialize in formal/academic vocabulary and structured speaking tasks (similar to the IELTS test structure).',
      introMessage: 'Good day. I am Darius. I look forward to working on your fluency and structuring your responses logically. Ready to begin our speaking exercise?',
      starters: [
        'Let\'s start an IELTS Speaking Part 2 task.',
        'Explain the difference between academic and casual phrases.',
        'How can I use transition words better?'
      ],
    ),
    AiTutor(
      id: 'jasmine',
      name: 'Jasmine',
      accent: 'Australian English Accent',
      avatarUrl: 'https://codewayimages.net/cdn-cgi/imagedelivery/rLEmnyzM9Rd0IW4YgVrjXg/aitutorweb/assets/images/landing/heros/jasmine.png/w=484,q=85',
      language: 'English',
      level: 'Intermediate',
      specialties: ['Business English', 'Interview Prep', 'Presentation Practice'],
      bio: 'Professional and supportive. I help you master professional vocabulary, write emails, present ideas, and handle difficult interview questions.',
      introMessage: 'Hi! Jasmine here. Let\'s get you ready to take on the corporate world. Would you like to practice mock interviewing or explaining data?',
      starters: [
        'Let\'s do a mock job interview.',
        'How to explain business strategy in English?',
        'Give me professional idioms.'
      ],
    ),
    AiTutor(
      id: 'mateo',
      name: 'Mateo',
      accent: 'Castilian Spanish Accent',
      avatarUrl: 'https://codewayimages.net/cdn-cgi/imagedelivery/rLEmnyzM9Rd0IW4YgVrjXg/aitutorweb/assets/images/landing/heros/mateo.png/w=594,q=85',
      language: 'Spanish',
      level: 'All Levels',
      specialties: ['Spanish Grammar', 'Travel Conversations', 'Latin Culture'],
      bio: '¡Hola! Warm, patient, and very expressive. I am here to help you speak Spanish confidently, whether you are checking into a hotel or chatting with friends.',
      introMessage: '¡Hola! Soy Mateo, tu tutor de español. Estoy muy feliz de hablar contigo. ¿De qué te gustaría hablar hoy?',
      starters: [
        'Quiero practicar conversaciones de viaje.',
        '¿Puedes explicarme el subjuntivo?',
        'Hablemos sobre comida tradicional.'
      ],
    ),
  ];
}
