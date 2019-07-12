import 'package:flutter/material.dart';
import 'package:pensieve_quiz/Utils/SignInHandler.dart';

void main() => runApp(QuizApp());

class QuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pensieve Quiz",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SignInHandler(),
    );
  }
}
