import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pensieve_quiz/Models/Question.dart';

class QuestionHandler {
  QuestionHandler({@required this.initialQuestion});

  final Question initialQuestion;

  StreamController<Question> questionController = StreamController<Question>();
  Stream<Question> get questionStream => questionController.stream;
  Sink<Question> get questionSink => questionController.sink;

  void add(Question newQuestion) {
    questionSink.add(newQuestion);
  }

  void cloes() {
    questionController.close();
  }
}
