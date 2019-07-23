import 'package:flutter/widgets.dart';
import 'package:pensieve_quiz/Models/Question.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizData {
  QuizData({@required this.documentID});

  final String documentID;
  List<Question> questionsList;

  Future<List<Question>> fetchQuizData() async {
    questionsList = List<Question>();
    var _query = await Firestore.instance
        .collection("monthlyQuizzes")
        .document(documentID)
        .collection("questions")
        .getDocuments();
    List<DocumentSnapshot> snapshotList = _query.documents;
    print("Number of Questions: ${snapshotList.length}");
    for (int i = 0; i < snapshotList.length; i++) {
      questionsList.add(Question(snapshot: snapshotList[i]));
      // print("QuizData Question: ${questionsList.first.question}");
    }
    // print("Number of Question docs: ${questionsList.length}");
    return questionsList;
  }
}
