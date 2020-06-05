import 'package:flutter/material.dart';

class SlideRouteTransition extends PageRouteBuilder {
  final Widget page;
  bool isRight;

  SlideRouteTransition({this.page, this.isRight = true})
      : super(
          pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) => page,
          transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) => SlideTransition(
            position: Tween<Offset>(begin:  Offset((isRight ? 1 : -1), 0), end: Offset.zero).animate(animation),
            child: child,
          ),
          transitionDuration: Duration(milliseconds: 500),
        );
}
