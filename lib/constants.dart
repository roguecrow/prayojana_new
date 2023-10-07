import 'package:flutter/foundation.dart';

class ApiConstants {
  static String baseUrl = kProfileMode
      ? 'https://prayojana-api-staging.netlify.app/.netlify/functions/'
      : 'https://prayojana.slashdr.com/.netlify/functions/'; // Change this to your debug URL

  static String fcmUrl = 'https://prayojana.slashdr.com/.netlify/functions/message';

  static String sampleUrl = 'https://jsonplaceholder.typicode.com/users';

  static String taskUrl = kProfileMode
      ? 'https://prayojana-api-staging.netlify.app/.netlify/functions//cbtask-view'
      : 'https://prayojana.slashdr.com/.netlify/functions//cbtask-view';

  static String interactionUrl =  kProfileMode
      ? 'https://prayojana-api-staging.netlify.app/.netlify/functions/interaction-view'
      : 'https://prayojana.slashdr.com/.netlify/functions/interaction-view';

  static String memberListUrl = kProfileMode
      ? 'https://prayojana-api-staging.netlify.app/.netlify/functions/mem-list'
      : 'https://prayojana.slashdr.com/.netlify/functions/mem-list';

  static const String checkPhone = 'check-num';
  static const String checkUser = 'check-user';

  static const String graphqlUrl = kProfileMode
      ? 'https://prayojana-api-staging.slashdr.com/v1/graphql'
      : 'https://prayojana-api-v1.slashdr.com/v1/graphql';

  static const String memberUrl = kProfileMode
      ? 'https://prayojana-api-staging.netlify.app/.netlify/functions/cbmem-details'
      : 'https://prayojana.slashdr.com/.netlify/functions/cbmem-details';

  static const String contentType = 'application/json';
  static const String hasuraConsoleClientName = 'hasura-console';
  static const String adminSecret = 'myadminsecret';
}



