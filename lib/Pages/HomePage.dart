import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pensieve_quiz/Pages/Quiz.dart';

class HomePage extends StatefulWidget {
  HomePage({@required this.user});

  final FirebaseUser user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var upcomingQuizDB;

  @override
  void initState() {
    super.initState();
    upcomingQuizDB = Firestore.instance
        .collection("monthlyQuizzes")
        .where("startTime",
            isGreaterThanOrEqualTo:
                DateTime.now().millisecondsSinceEpoch.toString())
        .orderBy("startTime")
        .limit(1);
    // print("Month: ${DateTime.now().year}");
    print("Epoch Time: ${DateTime.now().millisecondsSinceEpoch}");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: upcomingQuizDB.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (snapshot.data.documents.isEmpty) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.asset("assets/mystery.jpg"),
                ],
              );
            }
            DocumentSnapshot ref = snapshot.data.documents.first;
            // if (ref.data["isActive"]) {
            //  return Navigator.of(context).push(
            //     PageRouteBuilder(
            //       pageBuilder:
            //           (BuildContext context, animation, secondsryAnimation) {
            //         return SlideTransition(
            //           child: Quiz(
            //             user: widget.user,
            //             documentID: ref.documentID,
            //           ),
            //           position: Tween<Offset>(
            //             begin: Offset(1.0, 0),
            //             end: Offset.zero,
            //           ).animate(animation),
            //         );
            //       },
            //     ),
            //   );
            // }
            String imgUrl = ref.data["bgImageUrl"];
            imgUrl = imgUrl.replaceAll(RegExp("[\"]"), "");
            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Container(
                  child: CachedNetworkImage(
                    imageUrl: imgUrl,
                    fit: BoxFit.cover,
                    // placeholder: (context, url) {
                    //   return Image.asset(
                    //     "assets/default.png",
                    //     fit: BoxFit.cover,
                    //   );
                    // },
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  // top: 500,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 4,
                      sigmaY: 4,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent.withOpacity(0.2),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              ref.data["abstractHeading"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 7),
                            Text(
                              ref.data["abstractBody"],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            ref.data["isActive"]
                                ? MaterialButton(
                                    child: Text("Start Now"),
                                    color: Colors.lightGreen,
                                    onPressed: () async {
                                      // to make sure that the user does not attempts to
                                      // retake the quiz

                                      if (await isEligible(ref)) {
                                        showQuiz(ref);
                                      } else {
                                        showNotEligible();
                                      }
                                      // showQuiz(ref);
                                    },
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                //log out functionality

                Positioned(
                  top: 30,
                  right: 0,
                  child: Container(
                    color: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        await GoogleSignIn().signOut();
                      },
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 100),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          CachedNetworkImageProvider(widget.user.photoUrl),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        "${widget.user.displayName}",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void showQuiz(DocumentSnapshot ref) {
    print("Showing Quiz...");
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (BuildContext context, animation, secondsryAnimation) {
          return SlideTransition(
            child: Quiz(
              user: widget.user,
              documentID: ref.documentID,
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

  Future<bool> isEligible(DocumentSnapshot ref) async {
    DocumentSnapshot snapshot = await Firestore.instance
        .collection("monthlyQuizzes")
        .document(ref.documentID)
        .collection("participants")
        .document(widget.user.email)
        .get();
    // print("Is Eligible: ${!snapshot.data["isSubmitted"] ?? false}");
    if (snapshot.exists) {
      print("Document Exists");
      return !snapshot.data["isSubmitted"] ?? true;
    } else {
      print("Document does not Exists");
      return true;
    }
  }

  showNotEligible() {
    print("Showing Not eligible Dialog");
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text("Permission Denied"),
            actions: <Widget>[
              FlatButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            content: Text(
                "It seems as if you've already taken this quiz. Kindly contact the head of your club if you think it's a mistake."),
          ),
        );
      },
    );
  }
}
