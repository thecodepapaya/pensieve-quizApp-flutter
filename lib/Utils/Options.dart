import 'package:flutter/material.dart';

class Options extends StatefulWidget {
  Options(
      {@required this.onTap, @required this.isCorrect, @required this.option});
  final Function onTap;
  final bool isCorrect;
  final String option;

  @override
  _OptionsState createState() => _OptionsState();
}

class _OptionsState extends State<Options> {
  Color _color = Colors.white;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        if (widget.isCorrect) {
          setState(() {
            _color = Colors.green;
          });
        } else {
          setState(() {
            _color = Colors.red;
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey,
                  blurRadius: 3,
                  spreadRadius: 1,
                  offset: Offset(3, 3))
            ],
            borderRadius: BorderRadius.all(Radius.circular(50)),
            color: _color,
            // border: Border.,
          ),
          child: Text(
            widget.option,
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
