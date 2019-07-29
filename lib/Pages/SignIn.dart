import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CircleAvatar(
                backgroundImage: AssetImage("assets/icon.jpg"),
                radius: 100,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "It's Quiz Time!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // Text("Sign In"),
              RaisedButton(
                padding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  "Google Signin",
                  textScaleFactor: 1.2,
                ),
                onPressed: () {
                  _handleGoogleSignIn().then((FirebaseUser user) {
                    print(
                        "Signed in ${user.displayName} with E mail ${user.email}");
                  }).catchError((e) {
                    print("Error signin in: $e");
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<FirebaseUser> _handleGoogleSignIn() async {
    final GoogleSignInAccount googleUser =
        await _googleSignIn.signIn().catchError((e, st) {
      print("Error signIn(): $e");
    });
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication.catchError((e) {
      print("fetch auth Error: $e");
    });
    AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final FirebaseUser user =
        await _auth.signInWithCredential(credential).catchError((e) {
      print("Caught error Signing in :$e");
    });
    return user;
  }
}
