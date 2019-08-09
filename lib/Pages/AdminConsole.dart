// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pensieve_quiz/Utils/PastQuizzes.dart';
import 'package:pensieve_quiz/Utils/UpcomingQuizzes.dart';

class AdminConsole extends StatefulWidget {
  @override
  _AdminConsoleState createState() => _AdminConsoleState();
}

class _AdminConsoleState extends State<AdminConsole>
    with TickerProviderStateMixin {
  TabController _tabController;
  TextEditingController adminIDController = TextEditingController();
  GlobalKey<FormState> _globalKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Admin Console"),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: AssetImage("assets/icon.jpeg"),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.person_add),
              onPressed: () {
                String errorText;
                return showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("New Admin"),
                      contentPadding: EdgeInsets.all(10),
                      actions: <Widget>[
                        FlatButton(
                          child: Text("Add"),
                          onPressed: () {
                            if (_globalKey.currentState.validate()) {
                              Firestore.instance
                                  .collection("admins")
                                  .document(adminIDController.text)
                                  .setData({
                                "email": adminIDController.text,
                                "adminSince": DateTime.now(),
                              });
                              adminIDController.clear();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 5),
                          Form(
                            key: _globalKey,
                            autovalidate: true,
                            child: TextFormField(
                              autovalidate: true,
                              controller: adminIDController,
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Field cannot be empty";
                                } else if (!value.contains("@")) {
                                  return "Invalid Format";
                                } else if (!value
                                    .contains("@iiitvadodara.ac.in")) {
                                  return "Only IIITV students allowed";
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: "Email Address",
                                errorText: errorText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
          bottom: TabBar(
            tabs: <Widget>[
              Tab(
                text: "Upcoming Quizzes",
              ),
              Tab(
                text: "Past Quizzes",
              )
            ],
            controller: _tabController,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            UpcomingQuizzes(),
            PastQuizzes(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
