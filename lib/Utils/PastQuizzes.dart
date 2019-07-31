import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PastQuizzes extends StatefulWidget {
  @override
  _PastQuizzesState createState() => _PastQuizzesState();
}

class _PastQuizzesState extends State<PastQuizzes> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("monthlyQuizzes").snapshots(),
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
              onTap: () {},
              title: Text("${document.data["abstractHeading"]}"),
              subtitle: Text(
                  "Expires ${DateTime.fromMillisecondsSinceEpoch(int.parse(document.data["startTime"]))}"),
              isThreeLine: true,
              trailing: IconButton(
                color: Colors.blue,
                icon: Icon(Icons.send),
                onPressed: () {},
              ),
            ),
          );
          // return _borrowCardsBuilder(
          //     "${document['Name']}",
          //     "${document['Context']}",
          //     document['Amount'],
          //     "${document['Date']}");
        }).toList(),
      ),
    );
  }
}
