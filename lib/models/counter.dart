import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cd/models/notification.dart' as CounterNotification;
import 'package:cd/utils/database_helper.dart';

class Counter {
  int id;
  String title;
  DateTime dateTime;
  String description;
  List<String> whatItSeems;
  List<CounterNotification.Notification> notifications;
  double counterFontSize;
  double titleFontSize;
  Color fontColor;
  Color backgroundColor;

  static final String table = "counters";
  static final String _columnID = "id";
  static final String _columnTitle = "title";
  static final String _columnDateTime = "dateTime";
  static final String _columnDescription = "description";
  static final String _columnWhatItSeems = "whatItSeems";
  static final String _columnCounterFontSize = "counterFontSize";
  static final String _columnTitleFontSize = "titleFontSize";
  static final String _columnColor = "fontColor";
  static final String _backgroundColor = "backgroundColor";

  // Create table SQL query
  static final String createTable = "CREATE TABLE $table ($_columnID INTEGER PRIMARY KEY AUTOINCREMENT,"
      "$_columnDateTime INTEGER,"
      "$_columnTitle TEXT,"
      "$_columnDescription TEXT,"
      "$_columnWhatItSeems TEXT,"
      "$_columnCounterFontSize INTEGER,"
      "$_columnTitleFontSize INTEGER,"
      "$_columnColor  TEXT,"
      "$_backgroundColor TEXT)";

  Counter({this.id, this.title, this.dateTime, this.description, this.whatItSeems, this.notifications, this.counterFontSize, this.titleFontSize, this.fontColor, this.backgroundColor});

  factory Counter.fromJson(Map<String, dynamic> json) => Counter(
      id: json["id"],
      title: json["title"],
      dateTime: DateTime.fromMillisecondsSinceEpoch(json["dateTime"]),
      description: json["description"],
      whatItSeems: (jsonDecode(json["whatItSeems"]) as List).map((item) => item.toString()).toList(),
      counterFontSize: double.parse(json["counterFontSize"].toString()),
      titleFontSize: double.parse(json["titleFontSize"].toString()),
      fontColor: Color(int.parse(json["fontColor"].toString())),
      notifications: [],
      backgroundColor: Color(int.parse(json["backgroundColor"].toString())));

  Map<String, dynamic> toJson() => {
        "title": title,
        "dateTime": dateTime.millisecondsSinceEpoch,
        "description": description,
        "whatItSeems": jsonEncode(whatItSeems),
        "counterFontSize": counterFontSize,
        "titleFontSize": titleFontSize,
        "fontColor": fontColor.value,
        "backgroundColor": backgroundColor.value
      };

  Future<List<Counter>> getCounters(String type) async {
    String where;
    if (type == "past") {
      where = "WHERE $_columnDateTime < ${DateTime.now().millisecondsSinceEpoch}";
    } else if (type == "future") {
      where = "WHERE $_columnDateTime > ${DateTime.now().millisecondsSinceEpoch}";
    }

    var db = await DatabaseHelper().database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT * from $table $where ORDER BY dateTime');
    return x.isNotEmpty ? x.map((c) => Counter.fromJson(c)).toList() : [];
  }

  Future<Map<DateTime, List<Counter>>> getCountersForCalendar(DateTime firstDate, DateTime lastDate) async {
    var db = await DatabaseHelper().database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT * from $table WHERE ($_columnDateTime >= ${firstDate.millisecondsSinceEpoch} AND $_columnDateTime <= ${lastDate.millisecondsSinceEpoch}) ORDER BY $_columnDateTime');
    if (x.isNotEmpty) {
      Map<DateTime, List<Counter>> items = Map<DateTime, List<Counter>>();
      x.forEach((item) {
        Counter _counter = Counter.fromJson(item);
        items = _addItem(items, _counter);
      });

      return items;
    } else {
      return Map<DateTime, List<Counter>>();
    }
  }

  _addItem(Map<DateTime, List<Counter>> items, Counter counter) {
    var key = DateTime(counter.dateTime.year, counter.dateTime.month, counter.dateTime.day);
    if (items.keys.contains(key)) {
      items[key].add(counter);
    } else {
      items[key] = [counter];
    }

    return items;
  }

  @override
  String toString() {
    return 'Counter{id: $id, title: $title, dateTime: $dateTime, description: $description, whatItSeems: $whatItSeems, notifications: $notifications, counterFontSize: $counterFontSize, titleFontSize: $titleFontSize, fontColor: $fontColor, backgroundColor: $backgroundColor}';
  }
}
