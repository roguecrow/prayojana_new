// dao/notification_model_dao.dart

import 'package:floor/floor.dart';

import '../notification_model.dart';

@dao
abstract class NotificationDao {
  @Query('SELECT * FROM notifications ORDER BY id DESC')
  Future<List<AppNotification>> findAllNotification();


  @Query('SELECT * FROM notifications WHERE id = :id')
  Stream<AppNotification?> findNotificationById(int id); // Changed the return type

  @insert
  Future<void> insertNotification(AppNotification notification);

  @Query('DELETE FROM notifications WHERE id = :id')
  Future<void> delete(int id);

  @Query('DELETE FROM notifications')
  Future<void> deleteAllNotifications();

  @Query('SELECT * FROM notifications WHERE isViewed = 0')
  Future<List<AppNotification>> findUnviewedNotifications();

  @Query('UPDATE notifications SET isViewed = 1')
  Future<void> markAllNotificationsAsViewed();


}
