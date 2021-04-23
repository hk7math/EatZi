import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:eatzi/word_model.dart';

void main() {
  runApp(EatZi());
}

class EatZi extends StatefulWidget {
  List<Word> words;
  @override
  _EatZiState createState() => _EatZiState();
}

class _EatZiState extends State<EatZi> {
  TextEditingController textController = TextEditingController();
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
                      widget.words = snapshot.data;
                      return ValueListenableBuilder(
                        valueListenable: inputNotifier,
                        builder: (context, input, child) {
                          List<Word> words = (widget.words
                                  .where((word) => word.word
                                      .toLowerCase()
                                      .contains(input.toString().toLowerCase()))
                                  .toList()
                                    ..shuffle())
                              .take(10)
                              .toList();
                          return Expanded(
                              child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: words.map((word) {
                                Color color = Color(
                                    (Random().nextDouble() * 0xFFFFFF).toInt());
                                return FlipCard(
                                    onFlipDone: (done) {
                                      if (!done) {
                                        textController.text = word.word;
                                      }
                                    },
                                    front: CardContainer(
                                        color: color.withOpacity(.2),
                                        texts: [word.word]),
                                    back: CardContainer(
                                        color: color.withOpacity(.5),
                                        texts: word.eatzi
                                            .map((e) =>
                                                widget.words[int.parse(e)].word)
                                            .toList()));
                              }).toList(),
                            ),
                          ));
                        },
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      );
                    }
                  }),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Flexible(
                    flex: 5,
                    child: TextField(
                      controller: textController,
                      onChanged: (input) {
                        inputNotifier.value = input;
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(8.0),
                        border: OutlineInputBorder(),
                        labelText: '食字之橋',
                        hintText: '宣任',
                      ),
                    ),
                  ),
                  Spacer(
                    flex: 1,
                  ),
                  Flexible(
                    flex: 5,
                    child: TextField(
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(8.0),
                        border: OutlineInputBorder(),
                        labelText: '伸出對手',
                        hintText: '專一',
                      ),
                    ),
                  ),
                  Spacer(flex: 1),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(minimumSize: Size(50, 50),
                        primary: Color((Random().nextDouble() * 0xFFFFFF).toInt())
                            .withOpacity(1)),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                  ),
                ]),
              ),
            ])));
  }
}

class CardContainer extends StatelessWidget {
  const CardContainer({
    Key key,
    @required this.color,
    @required this.texts,
  }) : super(key: key);

  final Color color;
  final List<String> texts;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.0, right: 20.0),
      child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: SizedBox(
              width: 150,
              height: 150,
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: texts
                        .map((text) =>
                            Text('$text', style: TextStyle(fontSize: 20)))
                        .toList()),
              ))),
    );
  }
}

ValueNotifier inputNotifier = ValueNotifier('');
