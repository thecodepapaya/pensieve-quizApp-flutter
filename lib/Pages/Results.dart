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
      // backgroundColor: Colors.blue,
      body: FutureBuilder(
        future: Firestore.instance
            .collection("monthlyQuizzes")
            .document(widget.documentId)
            .collection("participants")
            .document(widget.user.email)
            .get(),
        builder: (context, scoreSnapshot) {
          if (scoreSnapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Container(
              padding: EdgeInsets.only(top: 40),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
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
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance
                        .collection("monthlyQuizzes")
                        .document(widget.documentId)
                        .collection("participants")
                        // .where("isSubmitted", isEqualTo: true)
                        .orderBy("score", descending: true)
                        .orderBy("totalTime", descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.connectionState == ConnectionState.none) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  bottom: 10, right: 10, left: 10),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    // FutureBuilder(
                                    //   future: Firestore.instance
                                    //       .collection("monthlyQuizzes")
                                    //       .document(widget.documentId)
                                    //       .collection("participants")
                                    //       .document(widget.user.email)
                                    //       .get(),
                                    //   builder: (context, scoreSnapshot) {
                                    //     if (scoreSnapshot.connectionState !=
                                    //         ConnectionState.done) {
                                    //       return Center(
                                    //         child: CircularProgressIndicator(),
                                    //       );
                                    //     } else {
                                    //       return Center(
                                    //         child: Column(
                                    //           mainAxisAlignment:
                                    //               MainAxisAlignment.center,
                                    //           crossAxisAlignment:
                                    //               CrossAxisAlignment.start,
                                    //           children: <Widget>[
                                    //             Center(
                                    //               child: Text(
                                    //                 "Your Score",
                                    //                 textScaleFactor: 2,
                                    //               ),
                                    //             ),
                                    //             Center(
                                    //                 child: Text(
                                    //               "${scoreSnapshot.data["score"]}",
                                    //               textScaleFactor: 4,
                                    //             )),
                                    //           ],
                                    //         ),
                                    //       );
                                    //     }
                                    //   },
                                    // ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: rankList(snapshot.data),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          }
        },
      ),
      // body: StreamBuilder<QuerySnapshot>(
      //   stream: Firestore.instance
      //       .collection("monthlyQuizzes")
      //       .document(widget.documentId)
      //       .collection("participants")
      //       // .where("isSubmitted", isEqualTo: true)
      //       .orderBy("score", descending: true)
      //       .orderBy("totalTime", descending: false)
      //       .snapshots(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting ||
      //         snapshot.connectionState == ConnectionState.none) {
      //       return Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     } else {
      //       return Padding(
      //         padding: EdgeInsets.fromLTRB(10, 70, 10, 10),
      //         child: SingleChildScrollView(
      //           child: Column(
      //             mainAxisAlignment: MainAxisAlignment.start,
      //             children: <Widget>[
      //               FutureBuilder(
      //                 future: Firestore.instance
      //                     .collection("monthlyQuizzes")
      //                     .document(widget.documentId)
      //                     .collection("participants")
      //                     .document(widget.user.email)
      //                     .get(),
      //                 builder: (context, scoreSnapshot) {
      //                   if (scoreSnapshot.connectionState !=
      //                       ConnectionState.done) {
      //                     return Center(
      //                       child: CircularProgressIndicator(),
      //                     );
      //                   } else {
      //                     return Center(
      //                       child: Column(
      //                         mainAxisAlignment: MainAxisAlignment.center,
      //                         crossAxisAlignment: CrossAxisAlignment.start,
      //                         children: <Widget>[
      //                           Center(
      //                             child: Text(
      //                               "Your Score",
      //                               textScaleFactor: 2,
      //                             ),
      //                           ),
      //                           Center(
      //                               child: Text(
      //                             "${scoreSnapshot.data["score"]}",
      //                             textScaleFactor: 4,
      //                           )),
      //                         ],
      //                       ),
      //                     );
      //                   }
      //                 },
      //               ),
      //               SizedBox(
      //                 height: 10,
      //               ),
      //               SingleChildScrollView(
      //                 child: Column(
      //                   mainAxisAlignment: MainAxisAlignment.start,
      //                   children: rankList(snapshot.data),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //       );
      //     }
      //   },
      // ),
    );
  }

  List<Widget> rankList(QuerySnapshot snapshots) {
    print("Result length: ${snapshots.documents.length}");
    int _rank = 0;
    List<Widget> list = List<Widget>();
    snapshots.documents.forEach(
      (docSnap) {
        // print("rank: ${_rank++}");
        _rank++;
        list.add(
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                // color: docSnap.data["emailID"] == widget.user.email
                //     ? Colors.green
                //     : Colors.transparent,
                color: rankColor(
                    _rank, docSnap.data["emailID"] == widget.user.email),
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
                // subtitle: Text("${_rank}"),
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
                              // TableRow(
                              //   children: <Widget>[
                              //     Text("Name"),
                              //     Text(docSnap.data["displayName"]),
                              //   ],
                              // ),
                              TableRow(
                                children: <Widget>[
                                  Text("Email"),
                                  Text(docSnap.data["emailID"]),
                                ],
                              ),
                              // TableRow(
                              //   children: <Widget>[
                              //     Text("Total Score"),
                              //     Text(docSnap.data["score"].toString()),
                              //   ],
                              // ),
                              TableRow(
                                children: <Widget>[
                                  Text("Total Time"),
                                  Text("${docSnap.data["totalTime"]} Sec"),
                                ],
                              ),
                              TableRow(
                                children: <Widget>[
                                  Text("Correct Ans"),
                                  Text(docSnap.data["correctAns"].toString()),
                                ],
                              ),
                              // TableRow(
                              //   children: <Widget>[
                              //     Text("Incorrect Ans"),
                              //     Text(docSnap.data["incorrectAns"].toString()),
                              //   ],
                              // ),
                              // TableRow(
                              //   children: <Widget>[
                              //     Text("Unanswered"),
                              //     Text(docSnap.data["unanswered"].toString()),
                              //   ],
                              // ),
                            ],
                          ),
                        );
                      });
                },
              ),
            ),
          ),
        );
      },
    );
    return list;
  }

  Color rankColor(int rank, bool isSelf) {
    // print("is self: $isSelf");
    switch (rank) {
      case 1:
        //hex for gold colour
        return Color(0xffCfb53b);
      case 2:
        //hex for silver colour
        return Color(0xffe6e8fa);
      case 3:
        //hex for bronze colour
        return Color(0xff8c7853);
      default:
        {
          return isSelf ? Colors.green : Colors.white;
        }
    }
  }
}
