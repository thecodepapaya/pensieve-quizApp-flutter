import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pensieve_quiz/Pages/QuizDetailPage.dart';

class UpcomingQuizzes extends StatefulWidget {
  @override
  _UpcomingQuizzesState createState() => _UpcomingQuizzesState();
}

class _UpcomingQuizzesState extends State<UpcomingQuizzes> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("monthlyQuizzes")
            .where("startTime",
                isGreaterThanOrEqualTo:
                    DateTime.now().millisecondsSinceEpoch.toString())
            .where("isActive", isEqualTo: false)
            .orderBy("startTime")
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.hasError)
              return Center(
                child: new Text('${snapshot.error}'),
              );
            if (!snapshot.hasData)
              return Center(
                child: Text('No data found!'),
              );

            return _cardBuilder(snapshot);
          }
        },
      ),
    );
  }

  Widget _cardBuilder(AsyncSnapshot snapshot) {
    return SingleChildScrollView(
      child: Column(
        children:
            snapshot.data.documents.map<Widget>((DocumentSnapshot document) {
          return Card(
            child: ListTile(
              title: Text("${document.data["abstractHeading"]}"),
              subtitle: Text(
                  "Expires ${DateTime.fromMillisecondsSinceEpoch(int.parse(document.data["startTime"]))}"),
              isThreeLine: true,
              trailing: IconButton(
                color: Colors.blue,
                icon: Icon(Icons.send),
                onPressed: () {
                  print("Quiz ID ${document.documentID} ACTIVATED");
                  Firestore.instance
                      .collection("monthlyQuizzes")
                      .document(document.documentID)
                      .updateData({
                    "isActive": true,
                  });
                },
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return QuizDetailsPage(
                        documentSnapshot: document,
                      );
                    },
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
