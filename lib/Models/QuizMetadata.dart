import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class QuizMetadata {
  QuizMetadata({@required this.snapshot}) {
    loadfromSnapshot(snapshot);
    // printQuizMetadata();
  }

  final DocumentSnapshot snapshot;

  String _abstractHeading;
  String _abstractBody;
  bool _isActive;
  int _minVersionCode;
  String _imageUrl;
  String _exipiryTime;

  void loadfromSnapshot(DocumentSnapshot snapshot) {
    this._abstractHeading = snapshot.data["abstractHeading"];
    this._abstractBody = snapshot.data["abstractBody"];
    this._isActive = snapshot.data["isActive"];
    this._minVersionCode = snapshot.data["minVersionCode"];
    this._imageUrl = snapshot.data["bgImageUrl"];
    this._exipiryTime = snapshot.data["expiryTime"];
  }

  String get abstractHeading => this._abstractHeading;
  String get abstractBody => this._abstractBody;
  bool get isActive => this._isActive;
  int get minVersionCode => this._minVersionCode;
  String get imageUrl => this._imageUrl;
  String get exipiryTime => this._exipiryTime;

  printQuestions() {
    print("##################################");
    print("abstractHeading: $_abstractHeading");
    print("abstractBody: $_abstractBody");
    print("isActive Index: $_isActive");
    print("minVersionCode: $_minVersionCode");
    print("bgImageUrl: $_imageUrl");
    print("exipiryTime: $_exipiryTime");
    print("##################################");
  }

  toJson() {
    return {
      "abstractHeading": this._abstractHeading,
      "abstractBody": this._abstractBody,
      "isActive": this._isActive,
      "minVersionCode": this._minVersionCode,
      "bgImageUrl": this._imageUrl,
      "exipiryTime": this._exipiryTime,
    };
  }
}
