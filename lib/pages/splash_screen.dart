import 'package:cd/utils/slide_route_transition.dart';
import 'package:flutter/material.dart';
import 'package:cd/generated/i18n.dart';

import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  AnimationController controller;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn);
    controller.forward();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.push(context, SlideRouteTransition(page: HomePage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: FadeTransition(
            opacity: animation,
            child: Text(
              S.of(context).app_name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 36.0,
                fontFamily: 'Pacifico',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
