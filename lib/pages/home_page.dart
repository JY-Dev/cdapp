import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cd/components/counter_widget.dart';
import 'package:cd/generated/i18n.dart';
import 'package:cd/models/counter.dart';
import 'package:cd/pages/calendar_page.dart';
import 'package:cd/pages/counter_form.dart';
import 'package:cd/pages/setting_page.dart';
import 'package:cd/utils/slide_route_transition.dart';
import 'package:cd/utils/wave_clipper_two_clipper.dart';
import 'package:intl/intl.dart';
import 'package:timeline_list/timeline.dart';
import 'package:timeline_list/timeline_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<DateTime, List<Counter>> _events = new Map<DateTime, List<Counter>>();
  Counter _counter;
  int secondsRemaining;
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    _initData();
    super.initState();
  }

  _initData() async {
    var now = DateTime.now();
    var isCurrentMonth = false;
    if (selectedMonth == now.month) {
      isCurrentMonth = true;
    }
    _events = await Counter().getCountersForCalendar(
      isCurrentMonth ? DateTime.now() : DateTime(now.year, selectedMonth, 1, 0, 0, 0, 0),
      DateTime(now.year, selectedMonth, DateTime(now.year, selectedMonth + 1, 0).day, 23, 59, 59),
    );

    setState(() {
      if (_events.length > 0) {
        _counter = _events.values.first.first;
        _events.values.first.removeAt(0);
      } else {
        _counter = null;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.event),
          onPressed: () => Navigator.push(context, SlideRouteTransition(page: CalendarPage(), isRight: false)).then((val) => _initData()),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.push(context, SlideRouteTransition(page: SettingsPage())),
          ),
        ],
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: WaveClipperTwo(),
                    child: Container(
                      color: Theme.of(context).primaryColor,
                      width: MediaQuery.of(context).size.width,
                      height: 140.0,
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                    ),
                  ),
                  Container(
                    height: 175.0,
                    padding: EdgeInsets.symmetric(horizontal: 17.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        DropdownButtonHideUnderline(
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              canvasColor: Theme.of(context).primaryColor,
                            ),
                            child: DropdownButton(
                              value: selectedMonth,
                              items: List.generate(3, (index) {
                                var date = DateTime(2019, DateTime.now().month + index, 1);
                                return DropdownMenuItem(
                                  child: Text(
                                    DateFormat("MMMM").format(date),
                                    style: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w500),
                                  ),
                                  value: date.month,
                                );
                              }),
                              onChanged: (val) {
                                setState(() {
                                  selectedMonth = val;
                                  _initData();
                                });
                              },
                              iconEnabledColor: Colors.white,
                              iconSize: 36.0,
                              icon: Icon(Icons.keyboard_arrow_down),
                              style: TextStyle(inherit: false, color: Colors.white, decorationColor: Colors.white),
                              isDense: true,
                            ),
                          ),
                        ),
                        SizedBox(height: 25.0),
                        _counter != null
                            ? CounterWidget(
                                counter: _counter,
                                shadow: true,
                                onDeleted: (counterId) {
                                  _initData();
                                },
                                onCompleted: (val) {
                                  _initData();
                                },
                              )
                            : Center(
                                child: Text(
                                  S.of(context).no_event,
                                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                                ),
                              ),
                      ],
                    ),
                  )
                ],
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _events.length > 0
                      ? _generateTimeLine(_events)
                      : [
                          SizedBox(
                            height: 0,
                          )
                        ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 5,
        onPressed: () {
          Navigator.push(
            context,
            SlideRouteTransition(
              page: CounterForm(
                counter: Counter(
                  title: "",
                  description: "",
                  dateTime: DateTime.now().add(Duration(days: 1)),
                  whatItSeems: ["days", "hours", "minutes", "seconds"],
                  counterFontSize: 14,
                  titleFontSize: 18,
                  fontColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ).then((val) => _initData());
        },
        tooltip: S.of(context).add_new_event,
        child: Icon(
          Icons.add,
          color: Theme.of(context).primaryColor,
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  _generateTimeLine(Map<DateTime, List<Counter>> eventList) {
    List<Widget> widgetList = List<Widget>();
    eventList.forEach(
      (date, events) {
        if (events.length > 0) {
          widgetList.add(
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.only(left: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            DateFormat("E").format(date),
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14.0),
                          ),
                          Text(
                            DateFormat("dd").format(date),
                            style: TextStyle(color: Theme.of(context).textTheme.caption.color, fontWeight: FontWeight.bold, fontSize: 30.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Timeline.builder(
                      iconSize: 0,
                      shrinkWrap: true,
                      itemCount: events.length,
                      position: TimelinePosition.Right,
                      lineWidth: 0,
                      lineColor: Colors.transparent,
                      itemBuilder: (context, index) => TimelineModel(
                        Column(
                          children: <Widget>[
                            CounterWidget(
                              counter: events[index],
                              onDeleted: (counterId) {
                                _initData();
                              },
                              onCompleted: (val) {
                                _initData();
                              },
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                        icon: Icon(
                          Icons.event_available,
                          color: Colors.transparent,
                          size: 1,
                        ),
                        iconBackground: Colors.transparent,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        }
      },
    );

    return widgetList;
  }
}
