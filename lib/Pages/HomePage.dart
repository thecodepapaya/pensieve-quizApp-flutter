import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pensieve_quiz/Pages/AdminConsole.dart';
import 'package:pensieve_quiz/Pages/Quiz.dart';
import 'package:pensieve_quiz/Pages/Results.dart';
import 'package:package_info/package_info.dart';

class HomePage extends StatefulWidget {
  HomePage({@required this.user});

  final FirebaseUser user;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Query upcomingQuizDB;
  int currentQuestionIndex;

  @override
  void initState() {
    super.initState();
    upcomingQuizDB = Firestore.instance
        .collection("monthlyQuizzes")
        .where("expiryTime",
            isGreaterThanOrEqualTo:
                DateTime.now().millisecondsSinceEpoch.toString())
        .orderBy("expiryTime")
        .limit(1);
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
                  Container(
                    // child: BackdropFilter(
                    //   filter: ImageFilter.blur(
                    //     sigmaX: 5,
                    //     sigmaY: 5,
                    //   ),
                    // child: Container(
                    child: Image.asset(
                      "assets/mystery.jpg",
                      fit: BoxFit.cover,
                    ),
                    // ),
                    // ),
                  ),
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 3,
                      sigmaY: 3,
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "The Quizzes we complete have a way of coming back to us in the end",
                              textAlign: TextAlign.center,
                              textScaleFactor: 2.0,
                              style: TextStyle(
                                color: Colors.white,
                                // backgroundColor: Colors.black12,
                              ),
                            ),
                            // SizedBox(
                            //   height: 300,
                            // ),
                            Text(
                              "If not always in the way we expect.",
                              textAlign: TextAlign.center,
                              textScaleFactor: 2.0,
                              style: TextStyle(
                                color: Colors.white,
                                // backgroundColor: Colors.black12,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  // SafeArea(

                  // ),
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
                      padding: EdgeInsets.all(8),
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
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    onPressed: () async {
                                      //check if user is not using an outdated
                                      //version of the app which could bypass
                                      //critical bugs
                                      if (!await isOnCorrectVersion(ref)) {
                                        showOutdatedAppDialog();
                                      } else {
                                        // to make sure that the user does not attempts to
                                        // retake the quiz
                                        if (await isEligible(ref)) {
                                          showQuiz(ref);
                                        } else {
                                          showNotEligible(ref);
                                        }
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

                // Positioned(
                //   top: 30,
                //   right: 0,
                //   child: Container(
                //     color: Colors.white,
                //     child: IconButton(
                //       icon: Icon(Icons.exit_to_app),
                //       onPressed: () async {
                //         await FirebaseAuth.instance.signOut();
                //         await GoogleSignIn().signOut();
                //       },
                //     ),
                //   ),
                // ),

                //Admin console functionality

                // Positioned(
                //   top: 30,
                //   left: 0,
                //   child: Container(
                //     color: Colors.white,
                //     child: IconButton(
                //       icon: Icon(Icons.person),
                //       onPressed: () async {
                //         Navigator.push(context,
                //             MaterialPageRoute(builder: (BuildContext context) {
                //           return AdminConsole();
                //         }));
                //       },
                //     ),
                //   ),
                // ),

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
                          backgroundColor: Colors.black12,
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

  Future<bool> isOnCorrectVersion(DocumentSnapshot ref) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String buildNumber = packageInfo.buildNumber;
    print("buildNumber:$buildNumber");
    // return buildNumber == ref.data["minVersionCode"].toString();
    return true;
  }

  showOutdatedAppDialog() {
    print("Showing outDated app Dialog");
    return showDialog(
      context: context,
      // barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            // title: Text("You think you are smart"),
            actions: <Widget>[
              FlatButton(
                child: Text("Ok"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
            content: Text(
              "You are running an outdated app. Please update your app."
              "\nFor more instructions contact you club heads",
            ),
          ),
        );
      },
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
              //+1 to show the question after the current
              //question since a value of "currentQuestionIndex" = 3
              //indicates the user has already attempted
              //question at index 3 so we need to show the question
              //at index 3+1 i.e 4
              currentQuestionIndex: currentQuestionIndex + 1,
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
      //check the current question index and show questions
      //accordingly to the user
      currentQuestionIndex = snapshot.data["currentQuestionIndex"] ?? -1;
      print("Question Index: $currentQuestionIndex");
      return snapshot.data["isSubmitted"] == null
          ? true
          : !snapshot.data["isSubmitted"];
    } else {
      print("Document does not Exists");
      currentQuestionIndex = -1;
      print("Question Index: $currentQuestionIndex");
      return true;
    }
  }

  showNotEligible(DocumentSnapshot ref) {
    print("Showing Not eligible Dialog");
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: Text("Lights, Camera and Cut?"),
            content: Text("Retakes are for Movies, not for live Quizzes"),
            actions: <Widget>[
              FlatButton(
                child: Text("Agree"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("Show Results"),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (BuildContext context, animation,
                          secondaryAnimation) {
                        return SlideTransition(
                          child: Results(
                            documentId: ref.documentID,
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
                },
              )
            ],
          ),
        );
      },
    );
  }
}
