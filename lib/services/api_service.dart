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
          "mobileNumber": phoneNumber,
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
      Uri.parse(ApiConstants.memberUrl),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? memberData = responseData['memberData'];

      print('Members Data: $memberData'); // Print the fetched members data
      return memberData;
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
      Uri.parse(ApiConstants.taskUrl),
    );

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? taskMembers = responseData['taskMembersData'];
      print('Task Members Data: $taskMembers');
      return taskMembers;
    } else {
      print('API Error: ${response.reasonPhrase}');
      return null;
    }
  }

  Future<List<dynamic>?> fetchMemberDetails(int memberId) async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getMemberQuery(memberId)}), // Use the getMemberQuery function
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> members = List<Map<String, dynamic>>.from(data['data']['members']);
        return members;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      print('Error fetching member details: $error');
      return null;
    }
  }

  Future<List<dynamic>?> fetchMemberHealthDetails(int memberId) async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getMemberHealthQuery(memberId)}), // Use the getMemberQuery function
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> membersHealth = List<Map<String, dynamic>>.from(data['data']['members']);
        return membersHealth;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      print('Error fetching member details: $error');
      return null;
    }
  }

  Future<List<dynamic>?> fetchMemberNotesDetails(int memberId) async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getMemberNotesQuery(memberId)}), // Use the getMemberQuery function
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> membersNotes = List<Map<String, dynamic>>.from(data['data']['members']);
        return membersNotes;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      print('Error fetching member details: $error');
      return null;
    }
  }

  Future<List<dynamic>?> fetchMemberAssistanceDetails(int memberId) async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getMemberAssistanceQuery(memberId)}), // Use the getMemberQuery function
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> membersAssistance = List<Map<String, dynamic>>.from(data['data']['members']);
        return membersAssistance;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      print('Error fetching member details: $error');
      return null;
    }
  }

  Future<List<dynamic>?> fetchMemberDocumentsDetails(int memberId) async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getMemberDocumentsQuery(memberId)}), // Use the getMemberQuery function
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> membersDocuments = List<Map<String, dynamic>>.from(data['data']['member_documents']);
        return membersDocuments;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      print('Error fetching member details: $error');
      return null;
    }
  }

  Future<List<dynamic>?> fetchMemberPrayojanaProfileDetails(int memberId) async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getPrayojanaProfileQuery(memberId)}), // Use the getMemberQuery function
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> membersPrayojanaProfile = List<Map<String, dynamic>>.from(data['data']['members']);
        return membersPrayojanaProfile;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      print('Error fetching member details: $error');
      return null;
    }
  }

  Future<List<dynamic>?> fetchMemberInterestDetails(int memberId) async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getMemberInterestQuery(memberId)}), // Use the getMemberQuery function
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> membersInterest = List<Map<String, dynamic>>.from(data['data']['members']);
        return membersInterest;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      print('Error fetching member details: $error');
      return null;
    }
  }

  Future<List<dynamic>> fetchInterestDetails() async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getInterestTypes}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> interest = data['data']['interest_types'];
        return interest;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return [];
      }
    } catch (error) {
      print('Error fetching member details: $error');
      return [];
    }
  }



  Future<List<dynamic>?> fetchPlans() async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'query': getPlans}), // Use the getPlans query
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> plans = data['data']['plans'];
        return plans;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      print('Error fetching plans: $error');
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

class InteractionApi {

  Future<List<dynamic>> fetchDataTypes() async {
    String accessToken = await getFirebaseAccessToken();
    final Map<String, String> headers = {
      'Hasura-Client-Name': 'hasura-console',
      'x-hasura-admin-secret': 'myadminsecret',
      'content-type': 'application/json',
      'Authorization': 'Bearer $accessToken',
    };
    String url = ApiConstants.interactionUrl;

    final http.Response response = await http.post(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> fetchedInteractionMembers = responseData['interactionMembersData'];

      print('fetchedInteractionMembers: $fetchedInteractionMembers'); // Add this line

      return fetchedInteractionMembers;
    } else {
      print('Error fetching data: ${response.reasonPhrase}');
      return []; // Return an empty list in case of an error
    }
  }
}

class FCMMessaging {

  static Future<http.Response> postFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedFCMToken = prefs.getString('FCMToken');

    try {
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.fcmUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
        },
        body: jsonEncode({
          'registrationToken': storedFCMToken,
        }),
      );

      if (response.statusCode == 200) {
        print('FCM Token sent: $storedFCMToken');
        print(response.body);
      } else {
        print('Failed to send FCM Token. Status code: ${response.statusCode}');
      }

      return response;
    } catch (error) {
      print('Error fetching service provider types: $error');
      throw error;
    }
  }
}


