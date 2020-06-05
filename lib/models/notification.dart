import 'package:cd/utils/database_helper.dart';

class Notification {
  int id;
  int counterId;
  DateTime dateTime;
  String notificationTimeKey;

  static final String table = "notifications";
  static final String _columnID = "id";
  static final String _columnDateTime = "dateTime";
  static final String _counterId = "counterId";
  static final String _columnNotificationTimeKey = "notificationTimeKey";

  // Create table SQL query
  static final String createTable = "CREATE TABLE $table ($_columnID INTEGER PRIMARY KEY AUTOINCREMENT,"
      "$_columnDateTime TEXT,"
      "$_counterId INTEGER,"
      "$_columnNotificationTimeKey TEXT)";

  Notification({
    this.id,
    this.dateTime,
    this.counterId,
    this.notificationTimeKey,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["id"],
        counterId: json["counterId"],
        dateTime: DateTime.fromMillisecondsSinceEpoch(int.parse(json["dateTime"])),
        notificationTimeKey: json["notificationTimeKey"],
      );

  Map<String, dynamic> toJson() => {
        "counterId": counterId,
        "dateTime": dateTime.millisecondsSinceEpoch,
        "notificationTimeKey": notificationTimeKey,
      };


  Future<List<Notification>> getNotifications(int counterId) async {
    var db = await DatabaseHelper().database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT * from $table WHERE $_counterId = $counterId ORDER BY $_columnDateTime DESC');
    return x.isNotEmpty ? x.map((c) {
      return  Notification.fromJson(c);
    }).toList() : [];
  }

  @override
  String toString() {
    return 'Notification{id: $id, counterId: $counterId, dateTime: $dateTime, notificationTimeKey: $notificationTimeKey}';
  }


}
