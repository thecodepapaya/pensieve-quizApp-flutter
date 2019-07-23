import 'package:flutter/material.dart';

class CountDownTimer extends StatefulWidget {
  CountDownTimer({@required this.timeLimit, @required this.onCompletion});

  final int timeLimit;
  final Function onCompletion;

  @override
  _CountDownTimerState createState() => _CountDownTimerState();
}

class _CountDownTimerState extends State<CountDownTimer>
    with TickerProviderStateMixin {
  double progressValue = 0.0;
  AnimationController _controllerValue;

  @override
  void initState() {
    super.initState();
    _controllerValue = AnimationController(
      vsync: this,
      duration: Duration(
        seconds: widget.timeLimit,
      ),
    );
    Tween<double>(begin: 0.0, end: 1.0).animate(_controllerValue)
      ..addListener(() {
        setState(() {
          progressValue = _controllerValue.value;
        });
        if (_controllerValue.isCompleted) {
          widget.onCompletion();
        }
      });
    _controllerValue.forward();
  }

  @override
  void dispose() {
    _controllerValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: LinearProgressIndicator(
        backgroundColor: Colors.white,
        valueColor: AlwaysStoppedAnimation<Color>(
          Color.fromRGBO(
            (255 * progressValue).toInt(),
            1 - (255 * progressValue).toInt(),
            0,
            1,
          ),
        ),
        value: progressValue,
      ),
    );
  }
}
