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
      body: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection("monthlyQuizzes")
            .document(widget.documentId)
            .collection("participants")
            // .where("isSubmitted", isEqualTo: true)
            .orderBy("score", descending: true)
            .orderBy("finishTime", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.connectionState == ConnectionState.none) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Padding(
              padding: EdgeInsets.fromLTRB(10, 70, 10, 10),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    FutureBuilder(
                      future: Firestore.instance
                          .collection("monthlyQuizzes")
                          .document(widget.documentId)
                          .collection("participants")
                          .document(widget.user.email)
                          .get(),
                      builder: (context, scoreSnapshot) {
                        if (scoreSnapshot.connectionState !=
                            ConnectionState.done) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    "Your Score",
                                    textScaleFactor: 2,
                                  ),
                                ),
                                Center(
                                    child: Text(
                                  "${scoreSnapshot.data["score"]}",
                                  textScaleFactor: 4,
                                )),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: rankList(snapshot.data),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  List<Widget> rankList(QuerySnapshot snapshots) {
    // print("Result data: ${snapshots.documents.first}");
    List<Widget> list = List<Widget>();
    snapshots.documents.forEach((docSnap) {
      list.add(
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: docSnap.data["emailID"] == widget.user.email
                ? Colors.green
                : Colors.white,
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(8),
            isThreeLine: false,
            title: Text(
              docSnap.data["displayName"],
              textScaleFactor: 1.2,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            // subtitle: Text(docSnap.data["emailID"],),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(docSnap.data["photoUrl"]),
              ),
            ),
            trailing: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                docSnap.data["score"].toString(),
                textScaleFactor: 1.5,
              ),
            ),
            onTap: () {
              return showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Details"),
                      content: Table(
                        children: [
                          TableRow(
                            children: <Widget>[
                              Text("Name"),
                              Text(docSnap.data["displayName"]),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              Text("Email"),
                              Text(docSnap.data["emailID"]),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              Text("Total Score"),
                              Text(docSnap.data["score"].toString()),
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              Text("Time Taken"),
                              Text(
                                  "${((docSnap.data["finishTime"] - docSnap.data["startTime"]) / 1000)} Sec")
                            ],
                          ),
                          TableRow(
                            children: <Widget>[
                              Text("Correct Ans"),
                              Text(docSnap.data["correctAns"].toString()),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            },
          ),
        ),
      );
    });

    return list;
  }
}
