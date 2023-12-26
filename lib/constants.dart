import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flavor_settings.dart';


class ApiConstants {
  static late String baseUrl;

  static Future<void> initializeBaseUrl() async {
    baseUrl = FlavorSettings().apiBaseUrl;
    print('API URL $baseUrl');
  }



  static String fcmUrl = 'https://prayojana.slashdr.com/.netlify/functions/message';

  static String sampleUrl = 'https://jsonplaceholder.typicode.com/users';

  static String taskUrl = '$baseUrl/rest/tasks_list';

  static String interactionUrl =  '$baseUrl/rest/interactions';

  // static String memberListUrl = kProfileMode
  //     ? 'https://prayojana-api-staging.netlify.app/.netlify/functions/mem-list'
  //     : 'https://prayojana.slashdr.com/.netlify/functions/mem-list';

  static String memberNameUrl = '$baseUrl/rest/filter/member';

  static const String checkPhone = '/rest/validation/check_number';
  static const String checkUser = '/rest/validation/checkuser';

  static  String graphqlUrl = '$baseUrl/v1/graphql';

  static  String calendarUrl = '$baseUrl/rest/calender_list';

  static  String memberUrl = '$baseUrl/rest/members_list';

  static  String dashboardMetricsUrl = '$baseUrl/rest/dashboard_metrics';

  static  String localityUrl = '$baseUrl/rest/filter/city';

  static String awsUrl(memberId) {
    return '$baseUrl/rest/files/upload/member/$memberId?image';
  }

  static const String contentType = 'application/json';
  static const String hasuraConsoleClientName = 'hasura-console';
  static const String adminSecret = 'myadminsecret';
}



