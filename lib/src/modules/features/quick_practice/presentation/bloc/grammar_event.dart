// ─── Events ───────────────────────────────────────

import 'package:equatable/equatable.dart';

abstract class GrammarEvent extends Equatable {
  const GrammarEvent();
  @override
  List<Object?> get props => [];
}

class GrammarStarted extends GrammarEvent {
  const GrammarStarted();
}

class GrammarOptionSelected extends GrammarEvent {
  final int selectedIndex;
  const GrammarOptionSelected(this.selectedIndex);
  @override
  List<Object?> get props => [selectedIndex];
}

class GrammarNextQuestion extends GrammarEvent {
  const GrammarNextQuestion();
}

class GrammarTimerTicked extends GrammarEvent {
  final int elapsed;
  const GrammarTimerTicked(this.elapsed);
  @override
  List<Object?> get props => [elapsed];
}
