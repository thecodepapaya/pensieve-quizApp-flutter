import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pensieve_quiz/Models/Question.dart';
import 'package:pensieve_quiz/Pages/Results.dart';
import 'package:pensieve_quiz/Utils/CountDownTimer.dart';
import 'package:pensieve_quiz/Utils/QuestionPalette.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionCard extends StatefulWidget {
  QuestionCard({
    @required this.questionData,
    @required this.currentQuestionIndex,
    @required this.user,
    @required this.documentID,
    @required this.startTime,
  });

  final List<Question> questionData;
  final int currentQuestionIndex;
  final FirebaseUser user;
  final String documentID;
  final int startTime;

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  int _questionIndex;
  OverlayEntry _preventTouchOverlay;

  @override
  void initState() {
    super.initState();
    // print("Current Question index: ${widget.currentQuestionIndex}");
    //shuffle all questions
    _questionIndex = widget.currentQuestionIndex;
    _preventTouchOverlay = OverlayEntry(builder: (BuildContext context) {
      return Container(
        color: Colors.transparent,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: widget.questionData[_questionIndex].imageUrl != null
            ? FutureBuilder(
                future: http.get(widget.questionData[_questionIndex].imageUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        //image container
                        Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height / 3,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(50),
                            ),
                          ),
                          child: Image.memory(
                            snapshot.data.bodyBytes,
                            fit: BoxFit.cover,
                          ),
                        ),
                        //countdown timer for each question
                        CountDownTimer(
                          timeLimit:
                              widget.questionData[_questionIndex].timeLimit,
                          onCompletion: onTimeOut,
                        ),
                        //palette which contains question and options
                        QuestionPalette(
                          questionData: widget.questionData[_questionIndex],
                          onCorrectSelection: onCorrectSelection,
                          onIncorrectSelection: onIncorrectSelection,
                        ),
                      ],
                    );
                  } else if (snapshot.connectionState ==
                          ConnectionState.waiting ||
                      snapshot.connectionState == ConnectionState.active) {
                    return Center(
                      child: LinearProgressIndicator(),
                    );
                  } else {
                    return Center(
                      child: Column(
                        children: <Widget>[
                          Icon(Icons.warning),
                          SizedBox(height: 10),
                          MaterialButton(
                            child: Text("Retry"),
                            onPressed: () {
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    );
                  }
                },
              )
            //For the case when no question thumbnail has been assigned
            //do not use Future and simply show the
            //question palette and progress indicator
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  CountDownTimer(
                    timeLimit: widget.questionData[_questionIndex].timeLimit,
                    onCompletion: onTimeOut,
                  ),
                  QuestionPalette(
                    questionData: widget.questionData[_questionIndex],
                    onCorrectSelection: onCorrectSelection,
                    onIncorrectSelection: onIncorrectSelection,
                  ),
                ],
              ),
      ),
    );
  }

  onCorrectSelection() async {
    print("Correct Submission");
    Overlay.of(context).insert(_preventTouchOverlay);
    double totalTime =
        (DateTime.now().millisecondsSinceEpoch - widget.startTime) / 1000;
    await Firestore.instance
        .collection("monthlyQuizzes")
        .document(widget.documentID)
        .collection("participants")
        .document(widget.user.email)
        .updateData({
      "score": FieldValue.increment(widget.questionData[_questionIndex].reward),
      "finishTime": DateTime.now().millisecondsSinceEpoch,
      "correctAns": FieldValue.increment(1),
      "currentQuestionIndex": _questionIndex,
      "totalTime": totalTime,
    });
    _nextQuestion();
  }

  onIncorrectSelection() async {
    Overlay.of(context).insert(_preventTouchOverlay);
    print("Incorrect Submission");
    double totalTime =
        (DateTime.now().millisecondsSinceEpoch - widget.startTime) / 1000;
    await Firestore.instance
        .collection("monthlyQuizzes")
        .document(widget.documentID)
        .collection("participants")
        .document(widget.user.email)
        .updateData({
      "currentQuestionIndex": _questionIndex,
      "finishTime": DateTime.now().millisecondsSinceEpoch,
      "incorrectAns": FieldValue.increment(1),
      "totalTime": totalTime,
    });
    //to let user know that they have pressed the wrong
    //option. Otherwise the next question appears immediately
    //without change in option color
    // Timer(Duration(milliseconds: 500), () {
    //   _nextQuestion();
    // });
    _nextQuestion();
  }

  onTimeOut() async {
    Overlay.of(context).insert(_preventTouchOverlay);
    // _nextQuestion();
    double totalTime =
        (DateTime.now().millisecondsSinceEpoch - widget.startTime) / 1000;
    print("Time out");
    await Firestore.instance
        .collection("monthlyQuizzes")
        .document(widget.documentID)
        .collection("participants")
        .document(widget.user.email)
        .updateData({
      "finishTime": DateTime.now().millisecondsSinceEpoch,
      "currentQuestionIndex": _questionIndex,
      "unanswered": FieldValue.increment(1),
      "totalTime": totalTime,
    });
    _nextQuestion();
  }

  void _nextQuestion() async {
    _preventTouchOverlay.remove();
    if (_questionIndex < widget.questionData.length - 1) {
      setState(() {
        _questionIndex++;
      });
      print("New Question");
    } else {
      print("Showing Results");

      await Firestore.instance
          .collection("monthlyQuizzes")
          .document(widget.documentID)
          .collection("participants")
          .document(widget.user.email)
          .updateData({
        "isSubmitted": true,
      });
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (BuildContext context, animation, secondaryAnimation) {
            return SlideTransition(
              child: Results(
                documentId: widget.documentID,
                user: widget.user,
              ),
              position: Tween<Offset>(
                begin: Offset(1.0, 0),
                end: Offset.zero,
              ).animate(animation),
            );
          },
        ),
      );
    }
  }
}
