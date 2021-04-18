import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:eatzi/word_model.dart';

void main() {
  runApp(EatZi());
}

class EatZi extends StatefulWidget {
  @override
  _EatZiState createState() => _EatZiState();
}

class _EatZiState extends State<EatZi> {
  Future<List<Word>> getWord() async {
    Response res = await get(Uri.parse(
        'https://script.google.com/macros/s/AKfycbxtIPYeloaPye8qVIxYaTs4w1lixcDo_fsSmjx5Fa3zCtG7Q-yN1u_K3hG2XFUvQjidYA/exec'));
    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      List<Word> words = body.map((e) => Word.fromJson(e)).toList();
      return words;
    } else {
      throw 'Sick jor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FutureBuilder(
                future: getWord(),
                builder: (ctx, snapshot) {
                  if (snapshot.hasData) {
                    List<Word> words = snapshot.data;
                    return Column(
                        children: words
                            .map((word) => Row(
                                  children: [
                                    Text(
                                        '${word.word}: ${word.eatzi.map((e) => words[int.parse(e)].word).join(',')}')
                                  ],
                                ))
                            .toList());
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    );
                  }
                }),
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '食你個字',
                hintText: '啜泣',
              ),
            )
          ],
        )));
  }
}
