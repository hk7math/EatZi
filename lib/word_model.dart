import 'package:flutter/foundation.dart';

class Word {
  final String word;
  final List<String> eatzi;

  Word({
    @required this.word,
    @required this.eatzi,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      word: json['Word'] as String,
      eatzi: json['Link'].toString().split(','),
    );
  }
}
