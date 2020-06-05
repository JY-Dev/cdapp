import 'package:flutter/material.dart';
import 'package:cd/components/counter_widget.dart';
import 'package:cd/generated/i18n.dart';
import 'package:cd/models/counter.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();

}

class _CalendarPageState extends State<CalendarPage> {
  List<Counter> _selectedCounterList;
  Map<DateTime,List<Counter>> _events;
  CalendarController _calendarController = CalendarController();
  bool _loading = false;
  DateTime currentDate = DateTime.now();

  @override
  void initState() {
    _initData();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  _initData() async {
    var today = DateTime.now();
    _events = await Counter().getCountersForCalendar(today.subtract(Duration(days: 6)), today.add(Duration(days: 36)));
    //_calendarController.events = _calendarController.events;

    setState(() {
      if (_events != null) {
        _selectedCounterList = _events.keys.contains(DateTime(today.year, today.month, today.day)) ? _events[DateTime(today.year, today.month, today.day)] : [];
        // _calendarController.events = _calendarController.events;
      }
      _loading = true;
    });
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      _selectedCounterList = _events.keys.contains(DateTime(_calendarController.selectedDay.year, _calendarController.selectedDay.month, _calendarController.selectedDay.day))
          ? _events[DateTime(_calendarController.selectedDay.year, _calendarController.selectedDay.month, _calendarController.selectedDay.day)]
          : [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Theme.of(context).iconTheme.color,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(icon: Icon(Icons.chevron_left,color: Theme.of(context).iconTheme.color), onPressed: () => _calendarController.setFocusedDay(DateTime(_calendarController.focusedDay.year, _calendarController.focusedDay.month - 1, 1))),
            SizedBox(
                width: 150.0,
                child: Center(
                  child: Text(
                    "${DateFormat("MMMM").format(currentDate)} / ${currentDate.year}",
                    style: Theme.of(context).textTheme.headline,
                  ),
                )),
            IconButton(
              icon: Icon(Icons.chevron_right,color: Theme.of(context).iconTheme.color),
              onPressed: () => _calendarController.setFocusedDay(DateTime(_calendarController.focusedDay.year, _calendarController.focusedDay.month + 1, 1)),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: !_loading
          ? Container(
              child: Center(child: CircularProgressIndicator()),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    color: Theme.of(context).cardColor,
                    child: TableCalendar(
                      calendarController: _calendarController,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: CalendarStyle(
                        selectedColor: Theme.of(context).primaryColor,
                        todayColor: Colors.blueAccent.shade100,
                      ),
                      onDaySelected: _onDaySelected,
                      headerVisible: false,
                      builders: CalendarBuilders(
                        markersBuilder: (context, date, events, holidays) {
                          final children = <Widget>[];
                          if (events.isNotEmpty) {
                            children.add(
                              Positioned(
                                right: 1,
                                bottom: 1,
                                child: _buildEventsMarker(date, events),
                              ),
                            );
                          }
                          return children;
                        },
                        todayDayBuilder: (BuildContext context, DateTime date, _) {
                          return Container(
                            margin: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.shade100,
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Center(
                              child: Text(
                                "${date.day}",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                        selectedDayBuilder: (BuildContext context, DateTime date, _) {
                          return Container(
                            margin: EdgeInsets.all(5.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.all(Radius.circular(5.0)),
                            ),
                            child: Center(
                              child: Text(
                                "${date.day}",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                      onVisibleDaysChanged: (firstDate, lastDate, format) async {
                        _events = await Counter().getCountersForCalendar(firstDate, lastDate);
                        setState(
                          () {
                            currentDate = firstDate.add(Duration(days: 10));
                            _events = _events;
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10.0),
                        Text(S.of(context).events, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0)),
                        SizedBox(height: 10.0),
                        _selectedCounterList.length > 0
                            ? ListView.separated(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                padding: EdgeInsets.all(5.0),
                                itemCount: _selectedCounterList.length,
                                separatorBuilder: (BuildContext ctxt, int index) {
                                  return SizedBox(height: 10.0);
                                },
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return CounterWidget(
                                    counter: _selectedCounterList[index],
                                    onDeleted: (id) async {
                                      _events = await Counter().getCountersForCalendar(_calendarController.visibleDays.first, _calendarController.visibleDays.last);
                                      _onDaySelected(_selectedCounterList[index].dateTime, null);
                                      setState(() {});
                                    },
                                  );
                                },
                              )
                            : Container(
                                margin: EdgeInsets.only(top: 20.0),
                                child: Text(S.of(context).no_event, style: TextStyle(fontSize: 18.0)),
                              )
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        color: _calendarController.isSelected(date) ? Colors.black : _calendarController.isToday(date) ? Colors.brown[300] : Theme.of(context).primaryColor,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}
