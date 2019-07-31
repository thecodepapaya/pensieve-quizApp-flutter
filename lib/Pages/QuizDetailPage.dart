import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pensieve_quiz/Models/QuizMetadata.dart';

class QuizDetailsPage extends StatefulWidget {
  QuizDetailsPage({@required this.documentSnapshot});

  final DocumentSnapshot documentSnapshot;

  @override
  _QuizDetailsPageState createState() => _QuizDetailsPageState();
}

class _QuizDetailsPageState extends State<QuizDetailsPage> {
  QuizMetadata quizMetadata;

  @override
  void initState() {
    super.initState();
    quizMetadata = QuizMetadata(snapshot: widget.documentSnapshot);
    fetchQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Details"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            _cardConstructor(
              "Abstract Heading",
              quizMetadata.abstractHeading,
              updateAbstractHeading,
            ),
            _cardConstructor(
              "Abstract Body",
              quizMetadata.abstractBody,
              updateAbstractBody,
            ),
            _cardConstructor(
              "Image Url",
              quizMetadata.imageUrl,
              updateBgImageUrl,
            ),
            _cardConstructor(
              "Expiry Date",
              quizMetadata.exipiryTime.toString(),
              updateExpiryDate,
            ),
            _cardConstructor(
              "Minimum Version",
              quizMetadata.minVersionCode.toString(),
              updateMinVersionCode,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Text("+Q"),
        tooltip: "Add question",
      ),
    );
  }

  Widget _cardConstructor(String key, String value, var onTapDialog) {
    return GestureDetector(
      onTap: onTapDialog,
      child: Card(
        margin: EdgeInsets.all(5),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Table(
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: <TableRow>[
              TableRow(
                children: <Widget>[
                  Text(key),
                  Text(value),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  fetchQuestions() async {
    print("docId:${widget.documentSnapshot.documentID}");
    QuerySnapshot docSnap = await Firestore.instance
        .collection("monthlyQuizzes")
        .document(widget.documentSnapshot.documentID)
        .collection("questions")
        .getDocuments();
    print("Questions " + "${docSnap.documents.first.data}");
  }

  updateAbstractHeading() {
    print("updateAbstractHeading");
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Enter new Heading"),
          contentPadding: EdgeInsets.all(12),
          children: <Widget>[],
        );
      },
    );
  }

  updateAbstractBody() {
    print("updateAbstractBody");
  }

  updateBgImageUrl() {
    print("updateBgImageUrl");
  }

  updateExpiryDate() {
    print("updateExpiryDate");
  }

  updateMinVersionCode() {
    print("updateMinVersionCode");
  }
}
