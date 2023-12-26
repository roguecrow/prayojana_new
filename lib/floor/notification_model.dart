import 'package:floor/floor.dart';

@Entity(tableName: 'notifications')
class AppNotification {
  @primaryKey
  final int? id; // Making it nullable

  final String notification;
  final bool isViewed;
  final String title;
  final String data;
  final String sentTime;

  AppNotification({this.id, required this.title, required this.data,required this.sentTime, required this.notification, required this.isViewed});
}
