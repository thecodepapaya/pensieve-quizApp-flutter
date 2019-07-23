import 'package:flutter/material.dart';
import 'package:pensieve_quiz/Models/Question.dart';
import 'package:pensieve_quiz/Utils/Options.dart';

class QuestionPalette extends StatefulWidget {
  QuestionPalette({
    @required this.questionData,
    @required this.onCorrectSelection,
    @required this.onIncorrectSelection,
  });

  final Question questionData;
  final Function onCorrectSelection;
  final Function onIncorrectSelection;

  @override
  _QuestionPaletteState createState() => _QuestionPaletteState();
}

class _QuestionPaletteState extends State<QuestionPalette> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: questionAndOptions(),
      ),
    );
  }

  List<Widget> questionAndOptions() {
    List<Widget> list = List<Widget>();
    list.addAll([
      Text(
        widget.questionData.question,
        style: TextStyle(fontSize: 20),
      ),
      SizedBox(
        height: 15,
      )
    ]);
    for (int i = 0; i < widget.questionData.options.length; i++) {
      if (i == widget.questionData.answerIndex) {
        list.add(Options(
          isCorrect: true,
          onTap: widget.onCorrectSelection,
          option: widget.questionData.options[i],
        ));
      } else {
        list.add(Options(
          isCorrect: false,
          onTap: widget.onIncorrectSelection,
          option: widget.questionData.options[i],
        ));
      }
    }
    return list;
  }
}
