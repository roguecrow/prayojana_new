import 'dart:convert';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:prayojana_new/graphql_queries.dart';
import '../constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../firebase_access_token.dart';


Future<String> getFirebaseAccessToken() async {

  SharedPreferences prefs = await SharedPreferences.getInstance();

  DateTime expiryTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('accessTokenExpiry') ?? 0);
  if (expiryTime.isBefore(DateTime.now())) {
    // Access token is expired, refresh it
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await AccessToken().refreshAccessToken(user);
      expiryTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('accessTokenExpiry') ?? 0);
      print('new refresh token stored');
    }
  }
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
  Future<List<dynamic>?> fetchMembersData(roleId, carebuddy , pageNo, statusList, plans, locality) async {

    print('roleId - $roleId');
    print('carebuddy - $carebuddy');
    print('pageNo - $pageNo');
    print('status - $statusList');
    print('plans - $plans');
    print('locality - $locality');

    String accessToken = await getFirebaseAccessToken();
    var headers = {
      'Content-Type': ApiConstants.contentType,
      'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
      'x-hasura-admin-secret': ApiConstants.adminSecret,
      'Authorization': 'Bearer $accessToken',
    };
    var requestBody = {};

    if (carebuddy != null) {
      requestBody['carebuddy'] = carebuddy;
    }

    if (pageNo != null) {
      requestBody['page_no'] = pageNo;
    }

    if (roleId != null) {
      requestBody['role_id'] = roleId;
    }

    if (statusList != null) {
      requestBody['status'] = statusList;
    }

    if (plans != null) {
      requestBody['plan'] = plans;
    }
    if (locality != null) {
      requestBody['locality'] = locality;
    }

    var request = http.Request(
      'POST',
      Uri.parse(ApiConstants.memberUrl),
    );

    request.headers.addAll(headers);
    request.body = jsonEncode(requestBody);


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

  Future<List<dynamic>?> fetchTaskMembersData( from, to, carebuddy, pageNo, status, members, roleId) async {

    print('roleId - $roleId');
    print('from - $from');
    print('to - $to');
    print('carebuddy - $carebuddy');
    print('pageNo - $pageNo');
    print('status - $status');
    print('members - $members');

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

    var requestBody = {};

    if (from != null && to != null) {
      requestBody['from'] = from;
      requestBody['to'] = to;
    }

    if (carebuddy != null) {
      requestBody['carebuddy'] = carebuddy;
    }

    if (pageNo != null) {
      requestBody['page_no'] = pageNo;
    }

    if (roleId != null) {
      requestBody['role_id'] = roleId;
    }

    if (status != null) {
      requestBody['status'] = status;
    }

    if (members != null) {
      requestBody['members'] = members;
    }

    request.headers.addAll(headers);
    request.body = jsonEncode(requestBody);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? taskMembers = responseData['data'];
      //print('Task Members Data: $taskMembers');
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
      print('Error Fetching member document details: $error');
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

  Future<List<dynamic>?> getMemberNames() async {
    try {
      String accessToken = await getFirebaseAccessToken();
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.memberNameUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> membersNames = List<Map<String, dynamic>>.from(data['data']);
        print(membersNames);
        return membersNames;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      print('Error fetching member details: $error');
      return null;
    }
  }

  Future<int?> deleteMemberDocument(int memberId, int documentId) async {
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
        body: jsonEncode({'query': deleteMemberDocumentsMutation(memberId, documentId)}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        int? affectedRows = data['data']['delete_member_documents']['affected_rows'];
        return affectedRows;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return null;
      }
    } catch (error) {
      print('Error Deleting member document: $error');
      return null;
    }
  }

}

class TaskApi{

  Future<List<dynamic>> getTaskDetails(int taskId) async {
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
        body: jsonEncode({'query': taskDetailsQuery(taskId)}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> taskDetails = data['data']['tasks'];
        print(taskDetails);
        return taskDetails;
      } else {
        print('API Error: ${response.reasonPhrase}');
        return [];
      }
    } catch (error) {
      print('Error fetching task details: $error');
      return [];
    }
  }


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

  Future<List<dynamic>?> fetchInteractionDataTypes(from, to, carebuddy, pageNo, status, members,roleId) async {

    print('from - $from');
    print('to - $to');
    print('roleId - $roleId');
    print('carebuddy - $carebuddy');
    print('pageNo - $pageNo');
    print('status - $status');
    print('members - $members');

    String accessToken = await getFirebaseAccessToken();
    var headers = {
      'Content-Type': ApiConstants.contentType,
      'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
      'x-hasura-admin-secret': ApiConstants.adminSecret,
      'Authorization': 'Bearer $accessToken',
    };

    var request = http.Request(
      'POST',
      Uri.parse(ApiConstants.interactionUrl),
    );
    var requestBody = {};

    if (from != null && to != null) {
      requestBody['from'] = from;
      requestBody['to'] = to;
    }

    if (carebuddy != null) {
      requestBody['carebuddy'] = carebuddy;
    }

    if (pageNo != null) {
      requestBody['page_no'] = pageNo;
    }

    if (roleId != null) {
      requestBody['role_id'] = roleId;
    }

    if (status != null) {
      requestBody['status'] = status;
    }

    if (members != null) {
      requestBody['members'] = members;
    }

    request.headers.addAll(headers);
    request.body = jsonEncode(requestBody);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> responseData = json.decode(responseString);
      List<dynamic>? interactionDetails = responseData['data'];
      print('Interaction Members Data: $interactionDetails');
      return interactionDetails;
    } else {
      print('API Error: ${response.reasonPhrase}');
      return null;
    }
  }

  Future<List<dynamic>> getInteractionDetails(int interactionId) async {
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
        body: jsonEncode({'query': interactionDetailsQuery(interactionId)}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['interaction_members'] != null) {
          List<dynamic> interactionDetails = data['data']['interaction_members'];
          //print(interactionDetails);
          return interactionDetails;
        } else {
          return []; // Return an empty list if there's no valid data
        }
      }
      else {
        print('API Error: ${response.reasonPhrase}');
        return [];
      }
    } catch (error) {
      print('Error fetching task details: $error');
      return [];
    }
  }
}

class FCMMessaging {

  static Future<http.Response> postFCMToken(device, isNotExpired, regId, userId) async {
    String accessToken = await getFirebaseAccessToken();
    try {
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'query': insertNotificationDevices,
          'variables': {
            'device': device,  // Add your device value here
            'isNotExpired': isNotExpired,  // Add your isExpired value here// Add your isActive value here
            'regId': regId,  // Add your regId value here
            'userId': userId,  // Add your userId value here
          },
        }),
      );

      if (response.statusCode == 200) {
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

  static Future<http.Response> logoutFunction(regId, userId, isNotExpired) async {
    String accessToken = await getFirebaseAccessToken();
    try {
      final http.Response response = await http.post(
        Uri.parse(ApiConstants.graphqlUrl),
        headers: {
          'Content-Type': ApiConstants.contentType,
          'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
          'x-hasura-admin-secret': ApiConstants.adminSecret,
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'query': updateNotificationDevices,
          'variables': {
            'isNotExpired': isNotExpired,  // Add your isExpired value here
            'regId': regId,  // Add your regId value here
            'userId': userId,  // Add your userId value here
          },
        }),
      );

      if (response.statusCode == 200) {
        print(response.body);
      } else {
        print('Failed to update IS expired: ${response.statusCode}');
      }

      return response;
    } catch (error) {
      print('Error updating: $error');
      throw error;
    }
  }

 Future<List> fetchFcmToken() async {
    String accessToken = await getFirebaseAccessToken();
    final http.Response response = await http.post(
      Uri.parse(ApiConstants.graphqlUrl), // Replace with your API endpoint
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'query': notificationTokenIds,

      }),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> notificationToken = responseData['data']['notification_devices'];
      //print('notification Token data  -  $notificationToken');
      return notificationToken;

    } else {
      throw Exception('Failed to load Notification Token');
    }
  }
}

class CalenderApi {

  Future<Map<String, dynamic>?> fetchCalendarDetails(from , to ) async {
    String accessToken = await getFirebaseAccessToken();
    try{
      var headers = {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      };

      var requestBody = {
        'from': from, // Assuming 'from' is a DateTime object
        'to': to,     // Assuming 'to' is a DateTime object
      };

      var request = http.Request(
        'POST',
        Uri.parse(ApiConstants.calendarUrl),
      );

      request.headers.addAll(headers);
      request.body = jsonEncode(requestBody);


      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        Map<String, dynamic> responseData = json.decode(responseString);
        Map<String, dynamic> calenderDetail = responseData;
        //print('Calendar data: $calenderDetail');
        return calenderDetail;
      }

      else {
        print('API Error: ${response.reasonPhrase} -  StatusCode : ${response.statusCode}');
        var statusCode = response.statusCode;
        print('tokenRefresher called');
        await AccessTokenReFetcher().tokenReFetcher(fetchCalendarDetails(from , to ),statusCode);
      }
    }
    catch (error) {
      print('Error: $error');
    }
    return null;
  }
}


class DashBoardApi {
  Future<Map<String, dynamic>?> fetchDashBoardDetails() async {
    String accessToken = await getFirebaseAccessToken();
    try{
      var headers = {
        'Content-Type': ApiConstants.contentType,
        'Hasura-Client-Name': ApiConstants.hasuraConsoleClientName,
        'x-hasura-admin-secret': ApiConstants.adminSecret,
        'Authorization': 'Bearer $accessToken',
      };
      var request = http.Request(
        'POST',
        Uri.parse(ApiConstants.dashboardMetricsUrl),
      );

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseString = await response.stream.bytesToString();
        Map<String, dynamic> responseData = json.decode(responseString);
        Map<String, dynamic> dashBoardDetail = responseData;
        return dashBoardDetail;
      }

      else {
        print('API Error: ${response.reasonPhrase} -  StatusCode : ${response.statusCode}');
        var statusCode = response.statusCode;
        print('tokenrefresher called');
        await AccessTokenReFetcher().tokenReFetcher(fetchDashBoardDetails(),statusCode);
      }
    }
    catch (error) {
      print('Error: $error');
    }
    return null;
  }

}

class AccessTokenReFetcher {

  Future<void> tokenReFetcher(function , statusCode) async {
    if(statusCode == 401)
      {
        try {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          String? uid = prefs.getString('uid');
          String? accessToken = prefs.getString('firebaseAccessToken');

          if (uid != null && accessToken != null) {
            // UID and access token found in local storage
            DateTime expiryTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('accessTokenExpiry') ?? 0);

            if (expiryTime.isBefore(DateTime.now())) {
              // Access token is expired, refresh it
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                await AccessToken().refreshAccessToken(user);
                accessToken = prefs.getString('firebaseAccessToken');
                expiryTime = DateTime.fromMillisecondsSinceEpoch(prefs.getInt('accessTokenExpiry') ?? 0);
                print('new refresh token storeed');
              }
            }
            if (expiryTime.isAfter(DateTime.now())) {
              print('again the $function called');
              // return await function;
            }
            else {
              print('token expired');
            }
            print(accessToken);
          }
        } catch (e) {
          print('Error refreshing access token: $e');
        }
      }
    else if (statusCode == 404) {
      return null;

    }
    else if (statusCode == 500) {
      return null;
    }
  }
}


