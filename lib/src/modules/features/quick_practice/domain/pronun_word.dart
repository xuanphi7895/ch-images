import 'package:equatable/equatable.dart';

class PronunWord extends Equatable {
  final String id;
  final String word;
  final String ipa;
  final String audioAssetPath; // e.g. 'assets/audio/through.mp3'

  const PronunWord({
    required this.id,
    required this.word,
    required this.ipa,
    required this.audioAssetPath,
  });

  @override
  List<Object?> get props => [id, word, ipa, audioAssetPath];
}

class PronunResult extends Equatable {
  final int scorePercent;
  final String tip;

  const PronunResult({required this.scorePercent, required this.tip});

  @override
  List<Object?> get props => [scorePercent, tip];
}
