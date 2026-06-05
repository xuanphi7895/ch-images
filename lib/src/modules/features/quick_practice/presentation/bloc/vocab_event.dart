import 'package:equatable/equatable.dart';
import 'package:images/src/utils/enum.dart';

abstract class VocabEvent extends Equatable {
  const VocabEvent();
  @override
  List<Object?> get props => [];
}

class VocabStarted extends VocabEvent {
  const VocabStarted();
}

class VocabAnswerRevealed extends VocabEvent {
  const VocabAnswerRevealed();
}

class VocabCardRated extends VocabEvent {
  final CardRating rating;
  const VocabCardRated(this.rating);
  @override
  List<Object?> get props => [rating];
}
