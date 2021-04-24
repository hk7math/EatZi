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
  final String baseUrl =
      'https://script.google.com/macros/s/AKfycbzK9arWky9kB_d8bPsmRSVtbUaZJl5xrG7H4qpDW4VAoG9CVW3kAJPiL4HzP24xExaUIQ/exec';
  final TextEditingController textController = TextEditingController();
  final TextEditingController textController2 = TextEditingController();
  final FocusNode textNode = FocusNode();
  Color color1, color2;
  bool isOk = true;

  Future<List<Word>> getWord() async {
    Response res = await get(Uri.parse(baseUrl));
    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      List<Word> words = body.map((e) => Word.fromJson(e)).toList();
      return words;
    } else {
      throw 'Sick jor';
    }
  }

  Future<List<Word>> postWord(String word, String eatzi) async {
    Response res = await post(Uri.parse(baseUrl + '?word=$word&eatzi=$eatzi'));
    if (res.statusCode == 200) {
      List<dynamic> body = jsonDecode(res.body);
      List<Word> words = body.map((e) => Word.fromJson(e)).toList();
      return words;
    } else {
      throw 'Sick jor';
    }
  }

  void onSubmit(EatZi widget) async {
    unlockNotifier.value = false;
    String word = textController.value.text;
    String eatzi = textController2.value.text;
    if (word == '' || eatzi == '') {
      unlockNotifier.value = true;
      return;
    }
    textController2.clear();
    widget.words = await postWord(word, eatzi);
    unlockNotifier.value = true;
    inputNotifier.value = word;
    inputNotifier.notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    color1 = randomColor();
    color2 = randomColor();
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: AnimatedContainer(
          duration: Duration(seconds: 1),
          decoration:
              BoxDecoration(gradient: RadialGradient(colors: [color1, color2])),
          child: Column(
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
                                        .contains(
                                            input.toString().toLowerCase()))
                                    .toList()
                                      ..shuffle())
                                .take(12)
                                .toList();
                            return Expanded(
                              child: SizedBox(
                                width:
                                    min(MediaQuery.of(context).size.width, 600),
                                child: GridView.count(
                                  crossAxisCount: 3,
                                  children: words.map((word) {
                                    Color color = randomColor();
                                    return FlipCard(
                                        onFlipDone: (done) {
                                          if (!done) {
                                            textController.text = word.word;
                                            textNode.requestFocus();
                                          }
                                        },
                                        front: CardContainer(
                                            color: color, texts: [word.word]),
                                        back: CardContainer(
                                            color: color.withOpacity(.5),
                                            texts: word.eatzi
                                                .map((e) => widget
                                                    .words[int.parse(e)].word)
                                                .toList()));
                                  }).toList(),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(100.0),
                          child: SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    }),
                ValueListenableBuilder(
                  valueListenable: unlockNotifier,
                  builder: (context, unlock, child) => Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 5,
                            child: TextField(
                              enabled: unlock,
                              controller: textController,
                              onChanged: (input) {
                                inputNotifier.value = input;
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(8.0),
                                border: OutlineInputBorder(),
                                labelText: '食字之橋',
                              ),
                            ),
                          ),
                          Spacer(
                            flex: 1,
                          ),
                          Flexible(
                            flex: 5,
                            child: TextField(
                              enabled: unlock,
                              controller: textController2,
                              focusNode: textNode,
                              onSubmitted: (text) {
                                onSubmit(widget);
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.all(8.0),
                                border: OutlineInputBorder(),
                                labelText: '執字之手',
                              ),
                            ),
                          ),
                          Spacer(flex: 1),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                minimumSize: Size(50, 50),
                                primary: randomColor()),
                            child: Icon(
                              unlock ? Icons.send : Icons.refresh,
                              color: Colors.white,
                            ),
                            onPressed: unlock
                                ? () {
                                    onSubmit(widget);
                                  }
                                : () {},
                          ),
                        ]),
                  ),
                ),
              ]),
        )));
  }
}

Color randomColor() =>
    Color(Random().nextInt(0xFFFFFFFF)).withAlpha(0xFF).withOpacity(.2);

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
      padding: EdgeInsets.all(8.0),
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
ValueNotifier unlockNotifier = ValueNotifier(true);
