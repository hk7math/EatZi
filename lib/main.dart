import 'package:flutter/material.dart';

void main() {
  runApp(EatZi());
}

class EatZi extends StatefulWidget {
  @override
  _EatZiState createState() => _EatZiState();
}

class _EatZiState extends State<EatZi> {
  List<String> words = ['世歲牆樓', '細水長流', '啜泣', '輸入'];
  Map<int, List<int>> eatzi = {
    0: [1],
    1: [0],
    2: [3],
    3: [2],
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
                children: eatzi
                    .map((key, value) => MapEntry(
                        key,
                        Row(
                          children: [
                            Text(
                                '${words[key]}: ${eatzi[key].map((e) => words[e]).join(',')}')
                          ],
                        )))
                    .values
                    .toList()),
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
