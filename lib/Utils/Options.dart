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
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            color: _color,
            border: Border.all(),
          ),
          child: Text(
            widget.option,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
