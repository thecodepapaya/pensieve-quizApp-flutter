import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pensieve_quiz/Pages/HomePage.dart';
import 'package:pensieve_quiz/Pages/SignIn.dart';

class SignInHandler extends StatefulWidget {
  @override
  _SignInHandlerState createState() => _SignInHandlerState();
}

class _SignInHandlerState extends State<SignInHandler> {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return new HomePage(user: snapshot.data);
        }
        return new SignIn();
      },
    );
  }
}
