class Dictionary {
  String word;
  List<Phonetic> phonetics;
  List<Meaning> meanings;
  License license;
  // List<String> sourceUrls;

  Dictionary({
    required this.word,
    required this.phonetics,
    required this.meanings,
    // required this.sourceUrls,
    required this.license,
  });

  String? get firstAudioUrl {
    for (final p in phonetics) {
      final url = p.audio?.trim();
      if (url != null && url.isNotEmpty) return url;
    }
    return null;
  }

  String? get primaryPhonetic {
    for (final p in phonetics) {
      final text = p.text?.trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return null;
  }

  factory Dictionary.fromJson(Map<String, dynamic> json) {
    return Dictionary(
      word: json['word'] as String,
      phonetics: (json['phonetics'] as List<dynamic>? ?? [])
          .map((e) => Phonetic.fromJson(e as Map<String, dynamic>))
          .toList(),
      meanings: (json['meanings'] as List<dynamic>? ?? [])
          .map((e) => Meaning.fromJson(e as Map<String, dynamic>))
          .toList(),
      license: (json['license'] as Map<String, dynamic>? ?? {}).isNotEmpty
          ? License(
              name: (json['license']['name'] as String?) ?? '',
              url: (json['license']['url'] as String?) ?? '',
            )
          : License(name: '', url: ''),
      // sourceUrls: (json['sourceUrls'] as List<dynamic>? ?? [])
      //     .map((e) => e as String)
      //     .toList(),
    );
  }
}

class License {
  String name;
  String url;

  License({required this.name, required this.url});
}

class Meaning {
  String partOfSpeech;
  List<Definition> definitions;
  List<String>? synonyms;
  List<String>? antonyms;

  Meaning({
    required this.partOfSpeech,
    required this.definitions,
    required this.synonyms,
    required this.antonyms,
  });

  factory Meaning.fromJson(Map<String, dynamic> json) {
    return Meaning(
      partOfSpeech: json['partOfSpeech'] as String? ?? '',
      definitions: (json['definitions'] as List<dynamic>? ?? [])
          .map((e) => Definition.fromJson(e as Map<String, dynamic>))
          .toList(),
      synonyms: (json['synonyms'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      antonyms: (json['antonyms'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
    );
  }
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

  factory Definition.fromJson(Map<String, dynamic> json) {
    return Definition(
      definition: json['definition'] as String,
      synonyms: json['synonyms'] as List<dynamic>? ?? [],
      antonyms: json['antonyms'] as List<dynamic>? ?? [],
      example: json['example'] as String?,
    );
  }
}

class Phonetic {
  String? text;
  String? audio;
  String? sourceUrl;
  License? license;

  Phonetic({this.text, this.audio, this.sourceUrl, this.license});

  factory Phonetic.fromJson(Map<String, dynamic> json) {
    return Phonetic(
      text: json['text'] as String?,
      audio: json['audio'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
    );
  }
}


// Convert to dart from json: https://app.quicktype.io/?l=dart or https://json2csharp.com/code-converters/json-to-dart
// API sameple: https://api.dictionaryapi.dev/api/v2/entries/en/hello