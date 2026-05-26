class Dictionary {
  String word;
  List<Phonetic> phonetics;
  List<Meaning> meanings;
  License license;
  List<String> sourceUrls;

  Dictionary({
    required this.word,
    required this.phonetics,
    required this.meanings,
    required this.license,
    required this.sourceUrls,
  });
}

class License {
  String name;
  String url;

  License({required this.name, required this.url});
}

class Meaning {
  String partOfSpeech;
  List<Definition> definitions;
  List<String> synonyms;
  List<String> antonyms;

  Meaning({
    required this.partOfSpeech,
    required this.definitions,
    required this.synonyms,
    required this.antonyms,
  });
}

class Definition {
  String definition;
  List<dynamic> synonyms;
  List<dynamic> antonyms;
  String? example;

  Definition({
    required this.definition,
    required this.synonyms,
    required this.antonyms,
    this.example,
  });
}

class Phonetic {
  String audio;
  String? sourceUrl;
  License? license;
  String? text;

  Phonetic({required this.audio, this.sourceUrl, this.license, this.text});
}
