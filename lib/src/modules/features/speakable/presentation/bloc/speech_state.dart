// state
class SpeechState {
  const SpeechState({
    required this.words,
    required this.currentIndex,
    required this.isPlaying,
  });

  final List<String> words;
  final int? currentIndex; // null = no highlight
  final bool isPlaying;

  SpeechState copyWith({int? currentIndex, bool? isPlaying}) => SpeechState(
    words: words,
    currentIndex: currentIndex,
    isPlaying: isPlaying ?? this.isPlaying,
  );
}

// events
class SpeechRequested {
  const SpeechRequested(this.text);
  final String text;
}

class SpeechProgressed {
  const SpeechProgressed(this.index);
  final int? index;
}

class SpeechFinished {
  const SpeechFinished();
}
