import 'package:equatable/equatable.dart';

sealed class DictionaryEvent extends Equatable {
  const DictionaryEvent();
  @override
  List<Object?> get props => [];
}

final class DictionaryLoadRequested extends DictionaryEvent {
  const DictionaryLoadRequested(this.word);
  final String word;
  @override
  List<Object?> get props => [word];
}
