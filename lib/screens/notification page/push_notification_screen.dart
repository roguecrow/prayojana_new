import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../floor/database.dart';
import '../../models/member_drawer.dart';
import '../interactions page/update_interaction_details_new.dart';
import '../member page/member details/member profile/member_profile.dart';
import '../tasks page/update_task_details_new.dart';

class PushNotificationScreen extends StatefulWidget {
  const PushNotificationScreen({super.key});

  @override
  State<PushNotificationScreen> createState() => _PushNotificationScreenState();
}

class _PushNotificationScreenState extends State<PushNotificationScreen> {
  List<dynamic> notifications = [];


  String formatSentTime(String sentTime) {
    DateTime dateTime = DateTime.parse(sentTime);
    String formattedDate = DateFormat('dd MMM yy').format(dateTime);
    String formattedTime = DateFormat('hh:mm a').format(dateTime);
    return '$formattedDate $formattedTime';
  }

  @override
  void initState() {
    super.initState();
    loadNotifications();
  }

  @override
  void dispose() {
    updateIsViewed(); // Call the function when the screen is being disposed
    super.dispose();
  }



  Future<void> updateIsViewed() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    await database.notificationDao.markAllNotificationsAsViewed();
    print('is viewed cleared');
  }

  Future<void> loadNotifications() async {
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
    notifications = await database.notificationDao.findAllNotification();
    print(notifications);
  }


  void handleNotificationTap(notification) {
    print('Notification Data: ${notification.data}');
    if (notification.data != null) {

      Map<String,dynamic> result = {};
      List<String> str = notification.data.toString().replaceAll("{","").replaceAll("}","").split(",");
      for(int i=0; i<str.length; i++){
        List<String> s = str[i].split(":");
        result.putIfAbsent(s[0].trim(), () => s[1].trim());
      }
      print(result);
      String refId = result['ref_id'];
      String eventType = result['type'];
      print(refId);
      print(eventType);

      if (eventType == 'created_task'|| eventType == "updated_task" && refId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewTaskDetailsScreen(taskId: int.parse(refId)),
          ),
        );
      }
      if (eventType == 'created_interaction'|| eventType == "updated_interaction" && refId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InteractionDetailsScreenNew(interactionId: int.parse(refId)),
          ),
        );
      }
      if (eventType == 'assign_member'|| eventType == "update_member_details" && refId != null) {
        final Map<String, dynamic> member = {};
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemberProfile(member: member,memberId: int.parse(refId)),
          ),
        );
      }
      // Add more conditions for other event types if needed
    }
  }


  // void handleNotificationTap(notification) {
  //   print('Notification Data: ${notification.data}');
  //
  //   Map<String,dynamic> result = {};
  //   List<String> str = notification.data.toString().replaceAll("{","").replaceAll("}","").split(",");
  //   for(int i=0; i<str.length; i++){
  //     List<String> s = str[i].split(":");
  //     result.putIfAbsent(s[0].trim(), () => s[1].trim());
  //   }
  //   print(result);
  //   print(result['ref_id']);
  //   print(result['type']);
  // }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: const Color(0xff006bbf),
        title: const Text('Notifications'),
      ),
        body: FutureBuilder<void>(
          future: loadNotifications(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading notifications'));
            } else {
              return notifications.isEmpty ?
              const Center(child: Text('No notifications available')) :
                ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(8.0.h),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  String title = notification.title;
                  String firstLetter = title.isNotEmpty ? title[0] : '';
                  return Card(
                    color: notification.isViewed ? Colors.grey.shade200 : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(firstLetter),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification.title.length > 15
                                ? '${notification.title.substring(0, 15)}...'
                                : notification.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            formatSentTime(notification.sentTime),
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10), // Add some space between title and subtitle
                          Text(
                            notification.notification,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        handleNotificationTap(notification);
                      },
                    ),
                  );
                },
              );
            }
          },
        ),
    );
  }

}
