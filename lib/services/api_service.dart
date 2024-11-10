import 'package:http/http.dart' as http;
import 'dart:convert';
import 'token_service.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.0.4:8000/api';

  static Future<http.Response> login(String username, String password) async {
    return await http.post(
      Uri.parse('$baseUrl/token/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'username': username,
        'password': password,
      }),
    );
  }

  static Future<String> getValidAccessToken() async {
    final accessToken = await TokenService.getAccessToken();
    final refreshToken = await TokenService.getRefreshToken();

    if (accessToken == null || refreshToken == null) {
      throw Exception('No tokens found');
    }

    final tokenExpiry = TokenService.getTokenExpiry(accessToken);
    if (tokenExpiry != null && DateTime.now().isBefore(tokenExpiry)) {
      return accessToken;
    } else {
      return await _refreshAccessToken(refreshToken);
    }
  }

  static Future<String> _refreshAccessToken(String refreshToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token/refresh/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'refresh': refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      await TokenService.saveTokens(responseData['access'], refreshToken);
      return responseData['access'];
    } else {
      await TokenService.clearTokens();
      throw Exception('Failed to refresh token');
    }
  }

  static Future<http.Response> fetchTests() async {
    final accessToken = await getValidAccessToken();
    return await http.get(
      Uri.parse('$baseUrl/test/fetch-all/'),
      headers: <String, String>{
        'Authorization': 'Bearer $accessToken',
      },
    );
  }

  static Future<http.Response> fetchQuestions(String subject, String topic) async {
    final accessToken = await getValidAccessToken();
    return await http.post(
      Uri.parse('$baseUrl/questions/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, String>{
        'subject': subject,
        'topic': topic,
      }),
    );
  }

  static Future<http.Response> beginTest(int userId, int testId) async {
    final accessToken = await getValidAccessToken();
    return await http.post(
      Uri.parse('$baseUrl/test/user-begin/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'test_id': testId,
      }),
    );
  }

  static Future<http.Response> endTest(int userId, int testId) async {
    final accessToken = await getValidAccessToken();
    return await http.post(
      Uri.parse('$baseUrl/test/user-end/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(<String, dynamic>{
        'user_id': userId,
        'test_id': testId,
      }),
    );
  }
}
