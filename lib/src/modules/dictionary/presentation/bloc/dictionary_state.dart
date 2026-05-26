import 'package:equatable/equatable.dart';

sealed class DictionaryState extends Equatable {
  const DictionaryState();
  @override
  List<Object?> get props => [];
}

final class DictionaryInitial extends DictionaryState {
  const DictionaryInitial();
}

final class DictionaryLoading extends DictionaryState {
  const DictionaryLoading();
}

final class DictionaryLoaded extends DictionaryState {
  const DictionaryLoaded(this.json);
  final List<dynamic> json;
  @override
  List<Object?> get props => [json];
}

final class DictionaryError extends DictionaryState {
  const DictionaryError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
