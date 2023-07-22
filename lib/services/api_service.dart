import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import '../constants.dart';

class ApiService {
  Future<http.Response> postUserData(String phoneNumber) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.check_numEndpoint);
      var headers = {
        'hasura_secret_key': 'myadminsecret',
        'Hasura-Client-Name': 'hasura-console',
        'Content-Type': 'application/json',
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
  Future<http.Response> postBearerToken(String bearerToken) async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.check_userEndpoint);
      var headers = {
        'Authorization': 'Bearer $bearerToken',
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
