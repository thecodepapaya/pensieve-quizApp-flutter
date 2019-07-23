import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Results extends StatefulWidget {
  Results({@required this.documentId, @required this.user});

  final String documentId;
  final FirebaseUser user;

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("monthlyQuizzes")
              .document(widget.documentId)
              .collection("participants")
              .where("isSubmitted", isEqualTo: true)
              .orderBy("score", descending: true)
              .orderBy("timeTaken", descending: false)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.connectionState == ConnectionState.none) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Table();
            }
          },
        ),
      ),
    );
  }
}
