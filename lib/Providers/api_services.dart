import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ApiService {
  final client = http.Client();
  // Fetch token from API
  Future<String?> fetchToken(String address, String password) async {
    final response = await http.post(
      Uri.parse('$address/api/session'),
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:127.0) Gecko/20100101 Firefox/127.0',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'password': password}),
    );

    log(response.headers.toString());

    return response.headers['set-cookie']; // Get cookie
  }

  // Perform action using token
  Future<String> performAction(
      String address, String password, String method, String? endpoint,
      {Map<String, dynamic>? params}) async {
    String? token = await fetchToken(address, password);

    if (token == null) return '';

    final response = http.Request(
        method, Uri.parse('$address/api/wireguard/client$endpoint'))
      ..headers.addAll({
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:127.0) Gecko/20100101 Firefox/127.0',
        'Content-Type': 'application/json',
        'Cookie': token,
      });

    if (params != null) {
      response.body = jsonEncode(params);
    }

    final streamedResponse = await response.send();
    return await http.Response.fromStream(streamedResponse)
        .then((res) => res.body);
  }

  // Extract values from configuration
  String? extractValue(String pattern, String text) {
    RegExp regex = RegExp(pattern);
    var match = regex.firstMatch(text);
    return match?.group(1);
  }

  // Get configuration for a user
  Future<String?> getConfig(
      String userId, String address, String password) async {
    var json = await performAction(address, password, 'GET', '');
    final list = jsonDecode(json);
    // log(list.toString());
    String? conf;

    bool isUser = false;

    for (var row in list) {
      if (row['name'] == userId) {
        log('User found');
        conf = await performAction(
            address, password, 'GET', '/${row['id']}/configuration');
        isUser = true;
        break;
      }
    }
    if (isUser == false) {
      var res = await performAction(address, password, 'POST', '', params: {
        'name': userId,
      });
      var json2 = await performAction(address, password, 'GET', '');
      final list2 = jsonDecode(json2);
      for (var row in list2) {
        if (row['name'] == userId) {
          conf = await performAction(
              address, password, 'GET', '/${row['id']}/configuration');
          isUser = true;
          break;
        }
      }
    }

    if (conf != null) {
      return conf;
    }
    getConfig(userId, address, password);
    return 'error';
  }
}
