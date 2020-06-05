import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cd/models/counter.dart';
import 'package:cd/pages/counter_form.dart';
import 'package:cd/utils/database_helper.dart';
import 'package:cd/utils/slide_route_transition.dart';
import 'package:cd/generated/i18n.dart';
import 'package:cd/models/notification.dart' as CounterNotification;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class CounterWidget extends StatefulWidget {
  final Counter counter;
  final bool shadow;
  final ValueChanged<int> onDeleted;
  final ValueChanged<bool> onCompleted;

  CounterWidget({Key key, @required this.counter, this.onDeleted, this.onCompleted, this.shadow = false}) : super(key: key);

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> with TickerProviderStateMixin {
  int secondsRemaining = 0;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      widget.counter.dateTime.difference(DateTime.now()).inSeconds;
      startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.counter.dateTime.isAfter(DateTime.now()) && (_timer?.isActive != null ?? false)) {
      secondsRemaining = widget.counter.dateTime.difference(DateTime.now()).inSeconds;
      startTimer();
      setState(() {});
    }
    return Container(
      decoration: widget.shadow == true
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 10.0,
                  spreadRadius: 1.0,
                  color: Colors.black.withOpacity(.3),
                  offset: Offset(5.0, 5.0),
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Container(
          width: double.infinity,
          height: 90.0,
          color: widget.counter.backgroundColor == Colors.transparent ? Theme.of(context).cardColor : widget.counter.backgroundColor,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(context, SlideRouteTransition(page: CounterForm(counter: widget.counter))),
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // return object of type Dialog
                    return AlertDialog(
                      title: Text(
                        S.of(context).are_you_sure_want_to_delete,
                        style: Theme.of(context).textTheme.headline,
                      ),
                      titlePadding: EdgeInsets.only(top: 25.0, left: 25.0, right: 25.0),
                      content: Text(
                        S.of(context).delete_note,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      contentPadding: EdgeInsets.only(top: 10.0, left: 25.0, right: 25.0),
                      actions: <Widget>[
                        // usually buttons at the bottom of the dialog
                        FlatButton(
                          child: Text(S.of(context).cancel, style: Theme.of(context).textTheme.title),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        FlatButton(
                          child: Text(S.of(context).sure, style: Theme.of(context).textTheme.title),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
                            List<CounterNotification.Notification> oldNotifications = await CounterNotification.Notification().getNotifications(widget.counter.id);

                            //delete old notifications
                            oldNotifications.forEach((notification) async {
                              await flutterLocalNotificationsPlugin.cancel(notification.id);
                              await DatabaseHelper().delete(CounterNotification.Notification.table, notification.id);
                            });

                            DatabaseHelper().delete(Counter.table, widget.counter.id);
                            widget.onDeleted(1);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Text(widget.counter.title, style: TextStyle(fontSize: widget.counter.titleFontSize, color: widget.counter.fontColor == Colors.transparent ? Theme.of(context).textTheme.headline.color: widget.counter.fontColor, fontWeight: FontWeight.bold)),
                          widget.counter.dateTime.isBefore(DateTime.now())
                              ? Icon(Icons.check_circle, size: 25.0)
                              : SizedBox(
                                  height: 0,
                                )
                        ],
                      ),
                    ),
                    widget.counter.dateTime.isBefore(DateTime.now())
                        ? Text(S.of(context).completed, style: TextStyle(fontSize: 14.0, color: widget.counter.fontColor == Colors.transparent ? Theme.of(context).textTheme.headline.color: widget.counter.fontColor))
                        : Column(
                            children: <Widget>[
                              Text(formatter(widget.counter.dateTime.difference(DateTime.now()).inSeconds),
                                  style: TextStyle(fontSize: widget.counter.counterFontSize, color: widget.counter.fontColor == Colors.transparent ? Theme.of(context).textTheme.headline.color: widget.counter.fontColor.withOpacity(.7))),
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (mounted) {
          setState(
            () {
              if (secondsRemaining < 1) {
                if (widget.onCompleted != null) {
                  widget.onCompleted(true);
                }
                timer.cancel();
              } else {
                secondsRemaining = secondsRemaining - 1;
              }
            },
          );
        }
      },
    );
  }

  String formatter(seconds) {
    int hours = ((seconds / 3600)).truncate();
    int days = (hours / 25).truncate();
    seconds = (seconds % 3600).truncate();
    int minutes = (seconds / 60).truncate();
    String text = "";

    hours = (hours % 24);
    seconds = (seconds % 60).truncate();
    if (widget.counter.whatItSeems.contains("days")) {
      text += "$days ${S.of(context).days} ";
    } else {
      hours += (days * 24);
    }

    if (widget.counter.whatItSeems.contains("hours")) {
      text += "$hours ${S.of(context).hours} ";
    } else {
      minutes += (hours * 60);
    }

    if (widget.counter.whatItSeems.contains("minutes")) {
      text += "$minutes ${S.of(context).minutes} ";
    } else {
      seconds += (minutes * 60);
    }
    if (widget.counter.whatItSeems.contains("seconds")) {
      text += "$seconds ${S.of(context).seconds} ";
    }

    return text;
  }
}
