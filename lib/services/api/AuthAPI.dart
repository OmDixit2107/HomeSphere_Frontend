import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  static const String baseUrl = 'http://192.168.1.5:8090/api';

  // Login API Call
  static Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
  }

  // Signup API Call
  static Future<http.Response> signup(String name, String email,
      String password, String phone, String role) async {
    final url = Uri.parse('$baseUrl/signup');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'contact_No': phone,
      }),
    );
  }
}
