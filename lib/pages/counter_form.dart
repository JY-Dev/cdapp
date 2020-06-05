import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/block_picker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cd/generated/i18n.dart';
import 'package:cd/models/counter.dart';
import 'package:cd/models/notification.dart' as CounterNotification;
import 'package:cd/utils/database_helper.dart';
import 'package:cd/utils/shared_preferences.dart';
import 'package:intl/intl.dart';

class CounterForm extends StatefulWidget {
  final Counter counter;

  const CounterForm({Key key, this.counter}) : super(key: key);

  @override
  _CounterFormState createState() => _CounterFormState(counter: this.counter);
}

class _CounterFormState extends State<CounterForm> {
  Counter counter;
  String selectedNotificationTimeKey = "event_time";

  _CounterFormState({this.counter});

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  TextEditingController _titleController = new TextEditingController();

  @override
  initState() {
    super.initState();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    _titleController.text = counter.title;

    if (counter.id != null) {
      _loadNotifications();
    } else {
      counter.notifications = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          resizeToAvoidBottomPadding: true,
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
            title: Text(S.of(context).add_new_event, style: Theme.of(context).textTheme.headline),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: FormBuilder(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: FormBuilderTextField(
                            autofocus: true,
                            controller: _titleController,
                            attribute: "title",
                            initialValue: counter.title,
                            decoration: InputDecoration(
                              labelText: S.of(context).enter_title,
                              labelStyle: TextStyle(fontSize: 22.0, color: Theme.of(context).primaryColor.withOpacity(.5)),
                              alignLabelWithHint: true,
                              hasFloatingPlaceholder: false,
                              contentPadding: EdgeInsets.only(bottom: 5.0, top: 0),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white, width: 2.0),
                              ),
                            ),
                            validators: [FormBuilderValidators.required(errorText: S.of(context).not_empty)],
                            onChanged: (val) => setState(() => counter.title = val),
                            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.title.color),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                    Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0),
                        decoration: new BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: new BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.turned_in_not),
                            SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 15.0),
                                child: FormBuilderTextField(
                                  attribute: "description",
                                  minLines: 1,
                                  initialValue: counter.description,
                                  decoration: InputDecoration(
                                    labelText: S.of(context).description,
                                    labelStyle: TextStyle(fontSize: 16.0),
                                    alignLabelWithHint: true,
                                    hasFloatingPlaceholder: false,
                                    contentPadding: EdgeInsets.only(bottom: 0.0),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) => setState(() => counter.description = val),
                                  style: TextStyle(fontSize: 16.0),
                                  textCapitalization: TextCapitalization.sentences,
                                ),
                              ),
                            )
                          ],
                        )),
                    SizedBox(
                      height: 25.0,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10.0),
                            color: Theme.of(context).cardColor,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.access_time),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  S.of(context).event_date,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            color: Theme.of(context).cardColor.withOpacity(.6),
                            padding: EdgeInsets.all(0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: FlatButton(
                                    onPressed: () async {
                                      FocusScope.of(context).requestFocus(FocusNode());
                                      var date = await showDatePicker(
                                        context: context,
                                        firstDate: DateTime.now().subtract(Duration(days: 1)),
                                        initialDate: counter.dateTime,
                                        lastDate: DateTime(2100),
                                        initialDatePickerMode: DatePickerMode.day,
                                      );

                                      if (date != null) {
                                        counter.dateTime = DateTime(date.year, date.month, date.day, counter.dateTime.hour, counter.dateTime.minute);
                                        setState(() {});
                                      }
                                    },
                                    padding: EdgeInsets.all(20.0),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            S.of(context).date,
                                            style: TextStyle(fontSize: 14.0),
                                          ),
                                          SizedBox(
                                            height: 5.0,
                                          ),
                                          Text(
                                            DateFormat("MMM dd, yyyy").format(counter.dateTime),
                                            style: TextStyle(
                                              fontSize: 16.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: FlatButton(
                                      onPressed: () async {
                                        FocusScope.of(context).requestFocus(FocusNode());

                                        final time = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.fromDateTime(counter.dateTime ?? DateTime.now()),
                                        );
                                        if (time != null) {
                                          counter.dateTime = DateTime(counter.dateTime.year, counter.dateTime.month, counter.dateTime.day, time.hour, time.minute);
                                          setState(() {});
                                        }
                                      },
                                      padding: EdgeInsets.all(20.0),
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          DateFormat("HH:mm").format(counter.dateTime),
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            fontSize: 36.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    counter.notifications.length == 0
                        ? Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(18.5),
                            decoration: new BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: new BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            child: Text(
                              S.of(context).no_notification,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          )
                        : ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: counter.notifications.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                width: double.infinity,
                                decoration: new BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: new BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    Icons.notifications_none,
                                    size: 22,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 22,
                                      color: Theme.of(context).iconTheme.color,
                                    ),
                                    onPressed: () => setState(
                                      () => counter.notifications.removeAt(index),
                                    ),
                                  ),
                                  title: DropdownButton<String>(
                                    items: [
                                      DropdownMenuItem(
                                        child: Text(S.of(context).event_time),
                                        value: "event_time",
                                      ),
                                      DropdownMenuItem(
                                        child: Text(S.of(context).five_minute),
                                        value: "5_minutes",
                                      ),
                                      DropdownMenuItem(
                                        child: Text(S.of(context).fifteen_minutes),
                                        value: "15_minutes",
                                      ),
                                      DropdownMenuItem(
                                        child: Text(S.of(context).half_an_hour),
                                        value: "30_minutes",
                                      ),
                                      DropdownMenuItem(
                                        child: Text(S.of(context).an_hour),
                                        value: "1_hour",
                                      ),
                                      DropdownMenuItem(
                                        child: Text(S.of(context).twelve_hours),
                                        value: "12_hours",
                                      ),
                                      DropdownMenuItem(
                                        child: Text(S.of(context).a_day),
                                        value: "1_day",
                                      ),
                                      DropdownMenuItem(
                                        child: Text(S.of(context).seven_days),
                                        value: "7_days",
                                      ),
                                      DropdownMenuItem(
                                        child: Text(S.of(context).fourteen_days),
                                        value: "14_days",
                                      ),
                                      DropdownMenuItem(
                                        child: Text(S.of(context).thirty_days),
                                        value: "30_days",
                                      ),
                                    ],
                                    onChanged: (String value) {
                                      FocusScope.of(context).requestFocus(FocusNode());

                                      setState(() {
                                        counter.notifications[index].notificationTimeKey = value;
                                      });
                                    },
                                    value: counter.notifications[index].notificationTimeKey,
                                    style: Theme.of(context).textTheme.title,
                                    isExpanded: true,
                                    hint: Text(S.of(context).how_long_before_the_event),
                                  ),
                                ),
                              );
                            },
                          ),
                    Container(
                      width: double.infinity,
                      child: FlatButton(
                        padding: EdgeInsets.all(15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        color: Theme.of(context).cardColor.withOpacity(.6),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.add,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              S.of(context).add_notification,
                            )
                          ],
                        ),
                        onPressed: () {
                          setState(() {
                            counter.notifications.add(CounterNotification.Notification(notificationTimeKey: "event_time"));
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10.0),
                            color: Theme.of(context).cardColor,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.history),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  S.of(context).countdown_format,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 0),
                            color: Theme.of(context).cardColor.withOpacity(.6),
                            child: FormBuilderCheckboxList(
                              attribute: "countdown_format",
                              initialValue: counter.whatItSeems,
                              decoration: InputDecoration(contentPadding: EdgeInsets.all(0)),
                              options: [
                                FormBuilderFieldOption(value: "days", child: Text(S.of(context).days)),
                                FormBuilderFieldOption(value: "hours", child: Text(S.of(context).hours)),
                                FormBuilderFieldOption(value: "minutes", child: Text(S.of(context).minutes)),
                                FormBuilderFieldOption(value: "seconds", child: Text(S.of(context).seconds)),
                              ],
                              validators: [FormBuilderValidators.minLength(1, errorText: S.of(context).error_min_length("1"))],
                              onChanged: (val) => setState(() => counter.whatItSeems = val),
                              activeColor: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Column(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.all(10.0),
                            color: Theme.of(context).cardColor,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.title),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  S.of(context).countdown_style,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 20.0),
                            color: Theme.of(context).cardColor.withOpacity(.6),
                            child: Column(
                              children: <Widget>[
                                FormBuilderDropdown(
                                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                                  attribute: "title_font_size",
                                  decoration: InputDecoration(labelText: S.of(context).title_font_size, contentPadding: EdgeInsets.all(0)),
                                  initialValue: counter.titleFontSize,
                                  validators: [FormBuilderValidators.required(errorText: S.of(context).not_empty)],
                                  items: [
                                    DropdownMenuItem(
                                      value: 12,
                                      child: Text(
                                        S.of(context).very_small,
                                        style: Theme.of(context).textTheme.body1,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 14,
                                      child: Text(
                                        S.of(context).small,
                                        style: Theme.of(context).textTheme.body1,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 18,
                                      child: Text(
                                        S.of(context).normal,
                                        style: Theme.of(context).textTheme.body1,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 24,
                                      child: Text(
                                        S.of(context).big,
                                        style: Theme.of(context).textTheme.body1,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 36,
                                      child: Text(
                                        S.of(context).very_big,
                                        style: Theme.of(context).textTheme.body1,
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => counter.titleFontSize = double.parse(val.toString())),
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                FormBuilderDropdown(
                                  style: TextStyle(fontSize: 14.0, color: Colors.black),
                                  attribute: "counter_font_size",
                                  decoration: InputDecoration(labelText: S.of(context).counter_font_size, contentPadding: EdgeInsets.all(0)),
                                  initialValue: counter.counterFontSize,
                                  validators: [FormBuilderValidators.required(errorText: S.of(context).not_empty)],
                                  items: [
                                    DropdownMenuItem(
                                      value: 12,
                                      child: Text(
                                        S.of(context).very_small,
                                        style: Theme.of(context).textTheme.body1,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 14,
                                      child: Text(
                                        S.of(context).small,
                                        style: Theme.of(context).textTheme.body1,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 18,
                                      child: Text(
                                        S.of(context).normal,
                                        style: Theme.of(context).textTheme.body1,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 24,
                                      child: Text(
                                        S.of(context).big,
                                        style: Theme.of(context).textTheme.body1,
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 36,
                                      child: Text(
                                        S.of(context).very_big,
                                        style: Theme.of(context).textTheme.body1,
                                      ),
                                    ),
                                  ],
                                  onChanged: (val) => setState(() => counter.counterFontSize = double.parse(val.toString())),
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 100.0,
                                      child: Text(S.of(context).background_color),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    SizedBox(
                                      width: 35,
                                      child: FlatButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            child: AlertDialog(
                                              title: Text(S.of(context).pick_color),
                                              content: Container(
                                                height: 130,
                                                child: BlockPicker(
                                                  availableColors: [
                                                    Color(0xFF0DCC00),
                                                    Color(0xFFCC1B00),
                                                    Color(0xFF8400CC),
                                                    Color(0xFF0036CC),
                                                    Colors.yellow,
                                                    Color(0xFFCC004A),
                                                    Colors.grey.shade100,
                                                    Colors.black,
                                                  ],
                                                  pickerColor: counter.backgroundColor,
                                                  onColorChanged: (color) => setState(() => counter.backgroundColor = color),
                                                ),
                                              ),
                                              actions: <Widget>[
                                                FlatButton(
                                                  child: Text(S.of(context).select),
                                                  onPressed: () {
                                                    setState(() => {});
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        child: SizedBox(),
                                        shape: RoundedRectangleBorder(side: BorderSide(width: 1.0, color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(50.0))),
                                        color: counter.backgroundColor,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 10.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 100.0,
                                      child: Text(S.of(context).font_color),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    SizedBox(
                                      width: 35,
                                      child: FlatButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            child: AlertDialog(
                                              title: Text(S.of(context).pick_color),
                                              content: Container(
                                                height: 130,
                                                child: BlockPicker(
                                                  availableColors: [
                                                    Color(0xFF0DCC00),
                                                    Color(0xFFCC1B00),
                                                    Color(0xFF8400CC),
                                                    Color(0xFF0036CC),
                                                    Colors.yellow,
                                                    Color(0xFFCC004A),
                                                    Colors.grey.shade100,
                                                    Colors.black,
                                                  ],
                                                  pickerColor: counter.fontColor,
                                                  onColorChanged: (color) => setState(() => counter.fontColor = color),
                                                ),
                                              ),
                                              actions: <Widget>[
                                                SizedBox(
                                                  height: 30,
                                                  child: FlatButton(
                                                    child: Text(S.of(context).select),
                                                    onPressed: () {
                                                      setState(() => {});
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                        child: SizedBox(),
                                        shape: RoundedRectangleBorder(side: BorderSide(width: 1.0, color: Colors.grey), borderRadius: BorderRadius.all(Radius.circular(50.0))),
                                        color: counter.fontColor,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
            child: SizedBox(
              width: double.infinity,
              child: RaisedButton(
                color: Theme.of(context).primaryColor,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    _formKey.currentState.save();
                    //if new, new notification and insert database
                    if (counter.id == null) {
                      counter.id = await DatabaseHelper().insert(Counter.table, counter);
                    } else {
                      //if update, update notification and database
                      await DatabaseHelper().update(Counter.table, counter);
                    }
                    await _saveNotifications();
                    if (counter.id > 0) {
                      Navigator.pushReplacementNamed(context, '/home');
                      Navigator.pop(context, true);
                    }
                  } else {
                    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(S.of(context).please_check_form_errors), backgroundColor: Colors.redAccent));
                  }
                },
                child: Text(
                  S.of(context).save,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  _loadNotifications() async {
    counter.notifications = await CounterNotification.Notification().getNotifications(counter.id);
    setState(() {});
  }

  Future<void> _saveNotifications() async {
    List<CounterNotification.Notification> oldNotifications = await CounterNotification.Notification().getNotifications(counter.id);
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    //delete old notifications
    oldNotifications.forEach((notification) async {
      await flutterLocalNotificationsPlugin.cancel(notification.id);
      await DatabaseHelper().delete(CounterNotification.Notification.table, notification.id);
    });

    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    //notification settings
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      counter.id.toString(),
      counter.title,
      counter.description,
      largeIconBitmapSource: BitmapSource.Drawable,
      vibrationPattern: vibrationPattern,
      enableLights: true,
      color: const Color.fromARGB(255, 255, 0, 0),
      ledColor: const Color.fromARGB(255, 255, 0, 0),
      ledOnMs: 1000,
      ledOffMs: 500,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);

    counter.notifications.forEach((notification) async {
      notification.counterId = counter.id;

      if (notification.notificationTimeKey == "event_time") {
        notification.dateTime = counter.dateTime;
      } else if (notification.notificationTimeKey == '5_minutes') {
        notification.dateTime = counter.dateTime.subtract(Duration(minutes: 5));
      } else if (notification.notificationTimeKey == '15_minutes') {
        notification.dateTime = counter.dateTime.subtract(Duration(minutes: 15));
      } else if (notification.notificationTimeKey == '30_minutes') {
        notification.dateTime = counter.dateTime.subtract(Duration(minutes: 30));
      } else if (notification.notificationTimeKey == '1_hours') {
        notification.dateTime = counter.dateTime.subtract(Duration(hours: 1));
      } else if (notification.notificationTimeKey == '12_hours') {
        notification.dateTime = counter.dateTime.subtract(Duration(hours: 12));
      } else if (notification.notificationTimeKey == '1_day') {
        notification.dateTime = counter.dateTime.subtract(Duration(days: 1));
      } else if (notification.notificationTimeKey == '7_days') {
        notification.dateTime = counter.dateTime.subtract(Duration(days: 7));
      } else if (notification.notificationTimeKey == '14_days') {
        notification.dateTime = counter.dateTime.subtract(Duration(days: 14));
      } else if (notification.notificationTimeKey == '30_days') {
        notification.dateTime = counter.dateTime.subtract(Duration(days: 30));
      }

      if (notification.dateTime.isAfter(DateTime.now())) {
        int notificationId = await DatabaseHelper().insert(CounterNotification.Notification.table, notification);
        await flutterLocalNotificationsPlugin.schedule(
          notificationId,
          counter.title,
          counter.description,
          notification.dateTime,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
        );
      }
    });
  }
}
