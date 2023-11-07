// database.dart

// required package imports
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:prayojana_new/floor/notification_model.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'dao/notification_model_dao.dart';

part 'database.g.dart'; // the generated code will be there

@Database(version: 1, entities: [AppNotification])
abstract class AppDatabase extends FloorDatabase {
  NotificationDao get notificationDao;
}