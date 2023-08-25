import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:prayojana_new/graphql_queries.dart';
import '../constants.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<String> getFirebaseAccessToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('firebaseAccessToken') ?? '';
}

class ApiService {
  Future<http.Response> postUserData(String phoneNumber) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.checkPhone);
      var headers = {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
      };
      var body = json.encode({
        "input": {
          "mobileNumber": phoneNumber,
        },
      });

      var response = await http.post(url, headers: headers, body: body);
      return response;
    } catch (e) {
      log(e.toString());
      rethrow; // Rethrow the error to handle it in the calling function
    }
  }
  Future<http.Response> postBearerToken() async {
    try {
      String accessToken = await getFirebaseAccessToken();
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.checkUser);
      var headers = {
        'Authorization': 'Bearer $accessToken',
      };
      var body = '''''';

      var response = await http.post(url, headers: headers, body: body);
      return response;
    } catch (e) {
      log(e.toString());
      rethrow; // Rethrow the error to handle it in the calling function
    }
  }
}


class MemberApi {
  Future<List<dynamic>?> fetchMembersData() async {
    String accessToken = await getFirebaseAccessToken();
    var headers = {
      'Content-Type': ApiConstants.contentType,
      'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
      'x-hasura-admin-secret': ApiConstants.adminSecret,
      'Authorization': 'Bearer $accessToken',
    };

    var request = http.Request(
      'POST',
      Uri.parse(ApiConstants.graphqlUrl),
    );
    request.body = graphQLQuery;
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? members = responseData['data']?['members'];
      print(responseData);
      print('Members Data: $members'); // Print the fetched members data
      return members;
    } else {
      print('API Error: ${response.reasonPhrase}');
      return null;
    }
  }

  static Future<http.Response> postRequest(String query, Map<String, dynamic> variables) async {
    String accessToken = await getFirebaseAccessToken();
    final Map<String, String> headers = {
      'Content-Type': ApiConstants.contentType,
      'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
      'x-hasura-admin-secret': ApiConstants.adminSecret,
      'Authorization': 'Bearer $accessToken',
    };

    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl),
      headers: headers,
      body: jsonEncode({
        'query': query,
        'variables': variables,
      }),
    );

    return response;
  }

  Future<List<dynamic>?> fetchTaskMembersData() async {
    String accessToken = await getFirebaseAccessToken();
    var headers = {
      'Content-Type': ApiConstants.contentType,
      'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
      'x-hasura-admin-secret': ApiConstants.adminSecret,
      'Authorization': 'Bearer $accessToken',
    };

    var request = http.Request(
      'POST',
      Uri.parse(ApiConstants.graphqlUrl),
    );

    request.body = json.encode({'query': getTaskQuery}); // Pass the GraphQL query
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? taskMembers = responseData['data']?['task_members'];
      print('Task Members Data: $taskMembers');
      return taskMembers;
    } else {
      print('API Error: ${response.reasonPhrase}');
      return null;
    }
  }
}

class Taskapi{

  static Future<http.Response> fetchServiceProviderTypes() async {

    try {
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
        },
        body: jsonEncode({
          'query': getServiceProviderTypesQuery,
        }),
      );
      return response;
    } catch (error) {
      log('Error fetching service provider types: $error');
      throw error;
    }
  }

  static Future<http.Response> performMutation(String mutation, Map<String, dynamic> variables) async {
    String accessToken = await getFirebaseAccessToken();
    final Map<String, String> headers = {
      'Content-Type': ApiConstants.contentType,
      'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
      'x-hasura-admin-secret': ApiConstants.adminSecret,
      'Authorization': 'Bearer $accessToken',
    };

    final Map<String, dynamic> requestBody = {
      'query': mutation,
      'variables': variables,
    };

    try {
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      return response;
    } catch (error) {
      throw Exception('Failed to perform mutation: $error');
    }
  }
}


