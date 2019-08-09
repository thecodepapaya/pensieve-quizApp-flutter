import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pensieve_quiz/Models/Question.dart';
import 'package:pensieve_quiz/Models/QuizData.dart';
import 'package:pensieve_quiz/Models/QuizMetadata.dart';
import 'package:pensieve_quiz/Pages/QuestionForm.dart';

class QuizDetailsPage extends StatefulWidget {
  QuizDetailsPage({@required this.documentSnapshot});

  final DocumentSnapshot documentSnapshot;

  @override
  _QuizDetailsPageState createState() => _QuizDetailsPageState();
}

class _QuizDetailsPageState extends State<QuizDetailsPage> {
  QuizMetadata quizMetadata;
  QuizData quizData;

  TextEditingController _abstractHeadingController = TextEditingController();
  TextEditingController _abstractBodyController = TextEditingController();
  TextEditingController _imageUrlController = TextEditingController();
  TextEditingController _expiryEpochTimeController = TextEditingController();
  TextEditingController _minVerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    quizMetadata = QuizMetadata(snapshot: widget.documentSnapshot);
    quizData = QuizData(documentID: widget.documentSnapshot.documentID);
    initializeTextControllers();
    // fetchQuestions();
  }

  initializeTextControllers() {
    _abstractHeadingController.text = quizMetadata.abstractHeading;
    _abstractBodyController.text = quizMetadata.abstractBody;
    _imageUrlController.text = quizMetadata.imageUrl;
    _expiryEpochTimeController.text = quizMetadata.exipiryTime;
    _minVerController.text = quizMetadata.minVersionCode.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Details"),
        actions: <Widget>[],
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
            //list of questions
            FutureBuilder(
              future: quizData.fetchQuizData(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Question>> snapshot) {
                if (snapshot.connectionState == ConnectionState.none ||
                    snapshot.connectionState == ConnectionState.waiting ||
                    snapshot.connectionState == ConnectionState.active) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  int length = snapshot.data.length;
                  List<Card> _questionList = List();
                  for (int i = 0; i < length; i++) {
                    _questionList.add(
                      Card(
                        child: ListTile(
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Q${i + 1}",
                              textScaleFactor: 1.2,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              // Firestore.instance
                              //     .collection("monthlyQuizes")
                              //     .document(widget.documentSnapshot.documentID)
                              //     .collection("questions")
                              //     .document()
                              //     .delete();
                              // print("Question Deleted");
                            },
                          ),
                          title: Text(snapshot.data[i].question),
                          onLongPress: () {
                            // Firestore.instance
                            //     .collection("monthlyQuizes")
                            //     .document(widget.documentSnapshot.documentID)
                            //     .collection("questions")
                            //     .document()
                            //     .delete();
                            // print("Question Deleted");
                          },
                        ),
                      ),
                    );
                  }
                  return Container(
                    padding: EdgeInsets.all(2),
                    child: Column(
                      children: _questionList,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return QuestionForm(
                  documentID: widget.documentSnapshot.documentID,
                );
              },
            ),
          );
        },
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

  // fetchQuestions() async {
  //   print("docId:${widget.documentSnapshot.documentID}");
  //   QuerySnapshot querySnap = await Firestore.instance
  //       .collection("monthlyQuizzes")
  //       .document(widget.documentSnapshot.documentID)
  //       .collection("questions")
  //       .getDocuments();
  //   print("Questions " + "${querySnap.documents.first.data}");
  // }

  // Widget _questionsList(List<DocumentSnapshot> docSnapList) {
  //   // final int questionCount = docSnapList.length;
  //   quizData = QuizData(documentID: widget.documentSnapshot.documentID);
  //   quizData.fetchQuizData();

  //   // docSnapList.forEach((DocumentSnapshot docSnap) {});
  //   return CircularProgressIndicator();
  // }

  updateAbstractHeading() {
    print("updateAbstractHeading");
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Abstract Heading"),
          contentPadding: EdgeInsets.all(12),
          children: <Widget>[
            TextField(
              maxLines: null,
              controller: _abstractHeadingController,
              decoration: InputDecoration(
                helperText: "(String)",
                hintText: "Abstract Heading",
              ),
              // onChanged: (value) {},
            ),
            SizedBox(
              height: 12,
            ),
            FlatButton(
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("Save"),
              onPressed: () {
                Firestore.instance
                    .collection("monthlyQuizzes")
                    .document(widget.documentSnapshot.documentID)
                    .updateData({
                  "abstractHeading": _abstractHeadingController.text,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  updateAbstractBody() {
    print("updateAbstractBody");
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Abstract Body"),
          contentPadding: EdgeInsets.all(12),
          children: <Widget>[
            TextField(
              maxLines: null,
              controller: _abstractBodyController,
              decoration: InputDecoration(
                hintText: "Abstract Body",
                helperText: "(String)",
              ),
              // onChanged: (value) {},
            ),
            SizedBox(
              height: 12,
            ),
            FlatButton(
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("Save"),
              onPressed: () {
                Firestore.instance
                    .collection("monthlyQuizzes")
                    .document(widget.documentSnapshot.documentID)
                    .updateData({
                  "abstractBody": _abstractBodyController.text,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  updateBgImageUrl() {
    print("updateBgImageUrl");
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Image Url"),
          contentPadding: EdgeInsets.all(12),
          children: <Widget>[
            TextField(
              controller: _imageUrlController,
              decoration: InputDecoration(
                hintText: "Image Url",
                helperText: "(String)",
              ),
              // onChanged: (value) {},
            ),
            SizedBox(
              height: 12,
            ),
            FlatButton(
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("Save"),
              onPressed: () {
                Firestore.instance
                    .collection("monthlyQuizzes")
                    .document(widget.documentSnapshot.documentID)
                    .updateData({
                  "bgImageUrl": _imageUrlController.text,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  updateExpiryDate() {
    print("updateExpiryDate");
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("Expiry EpochTime"),
          contentPadding: EdgeInsets.all(12),
          children: <Widget>[
            TextField(
              maxLines: 1,
              controller: _expiryEpochTimeController,
              decoration: InputDecoration(
                hintText: "Eg. 1565592397721",
                helperText: "(String)",
              ),
              // onChanged: (value) {},
            ),
            SizedBox(
              height: 12,
            ),
            FlatButton(
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("Save"),
              onPressed: () {
                Firestore.instance
                    .collection("monthlyQuizzes")
                    .document(widget.documentSnapshot.documentID)
                    .updateData({
                  "expiryTime": _expiryEpochTimeController.text,
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  updateMinVersionCode() {
    print("updateMinVersionCode");
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text("minVersionCode"),
          contentPadding: EdgeInsets.all(12),
          children: <Widget>[
            TextField(
              maxLines: 1,
              controller: _minVerController,
              decoration: InputDecoration(
                hintText: "Eg. 1,2,3",
                helperText: "(Integer)",
              ),
              // onChanged: (value) {},
            ),
            SizedBox(
              height: 12,
            ),
            FlatButton(
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("Save"),
              onPressed: () {
                Firestore.instance
                    .collection("monthlyQuizzes")
                    .document(widget.documentSnapshot.documentID)
                    .updateData({
                  "minVersionCode": int.parse(_minVerController.text),
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
