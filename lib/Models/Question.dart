import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class Question {
  Question({@required this.snapshot}) {
    _options = List<String>();
    loadfromSnapshot(snapshot);
    // printQuestions();
  }

  final DocumentSnapshot snapshot;

  String _question;
  // String _option1;
  // String _option2;
  // String _option3;
  // String _option4;
  List<String> _options;
  String _imageUrl;
  bool _isBonus;
  int _reward;
  int _timeLimit;
  int _answerIndex;

  void loadfromSnapshot(DocumentSnapshot snapshot) {
    this._question = snapshot.data["question"];
    // this._option1 = snapshot.data["Option 1"];
    // this._option2 = snapshot.data["Option 2"];
    // this._option3 = snapshot.data["Option 3"];
    // this._option4 = snapshot.data["Option 4"];
    this._options = List.from(snapshot.data["options"]);
    this._reward = snapshot.data["reward"];
    this._timeLimit = snapshot.data["timeLimit"];
    this._imageUrl = snapshot.data["imageUrl"];
    this._answerIndex = snapshot.data["answerIndex"];
    this._isBonus = snapshot.data["isBonus"];
  }

  String get question => this._question;
  // String get option1 => this._option1;
  // String get option2 => this._option2;
  // String get option3 => this._option3;
  // String get option4 => this._option4;
  List<String> get options => this._options;
  String get imageUrl => this._imageUrl;
  bool get isBonus => this._isBonus;
  int get reward => this._reward;
  int get timeLimit => this._timeLimit;
  int get answerIndex => this._answerIndex;

  printQuestions() {
    print("##################################");
    print("Question: $question");
    print("Options: $options");
    print("Answer Index: $answerIndex");
    print("Reward: $reward");
    print("TimeLimit: $timeLimit");
    print("Bonus Question: $isBonus");
    print("##################################");
  }
}
