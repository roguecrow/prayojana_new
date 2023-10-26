import 'package:flutter/foundation.dart';

class ApiConstants {
  static String baseUrl = kProfileMode
      ? 'https://prayojana-api-v1.slashdr.com'
      : 'https://prayojana-api-v1.slashdr.com'; // Change this to your debug URL

  static String fcmUrl = 'https://prayojana.slashdr.com/.netlify/functions/message';

  static String sampleUrl = 'https://jsonplaceholder.typicode.com/users';

  static String taskUrl = kProfileMode
        ? 'https://prayojana-api-v1.slashdr.com/rest/tasks_list'
        : 'https://prayojana-api-v1.slashdr.com/rest/tasks_list';

  static String interactionUrl =  kProfileMode
      ? 'https://prayojana-api-v1.slashdr.com/rest/interactions'
      : 'https://prayojana-api-v1.slashdr.com/rest/interactions';

  static String memberListUrl = kProfileMode
      ? 'https://prayojana-api-staging.netlify.app/.netlify/functions/mem-list'
      : 'https://prayojana.slashdr.com/.netlify/functions/mem-list';

  static String memberNameUrl = kProfileMode
      ? 'https://prayojana-api-v1.slashdr.com/rest/filter/member'
      : 'https://prayojana-api-v1.slashdr.com/rest/filter/member';

  static const String checkPhone = '/rest/validation/check_number';
  static const String checkUser = '/rest/validation/checkuser';

  static const String graphqlUrl = kProfileMode
      ? 'https://prayojana-api-staging.slashdr.com/v1/graphql'
      : 'https://prayojana-api-v1.slashdr.com/v1/graphql';

  static const String calendarUrl = kProfileMode
      ? 'https://prayojana-api-v1.slashdr.com/rest/calender_list'
      : 'https://prayojana-api-v1.slashdr.com/rest/calender_list';

  static const String memberUrl = kProfileMode
      ? 'https://prayojana-api-v1.slashdr.com/rest/members_list'
      : 'https://prayojana-api-v1.slashdr.com/rest/members_list';

  static const String dashboardMetricsUrl = kProfileMode
      ? 'https://prayojana-api-v1.slashdr.com/rest/dashboard_metrics'
      : 'https://prayojana-api-v1.slashdr.com/rest/dashboard_metrics';

  static const String contentType = 'application/json';
  static const String hasuraConsoleClientName = 'hasura-console';
  static const String adminSecret = 'myadminsecret';
}



