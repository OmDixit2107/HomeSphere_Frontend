import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthFunctions {
  static const String baseUrl = 'http://192.168.1.5:8080/api';

  // Login Function
  static Future<String> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      final jsessionId = response.headers['set-cookie']?.split(';').first;

      if (jsessionId != null) {
        await prefs.setString('JSESSIONID', jsessionId);
        print('Login successful. JSESSIONID stored: $jsessionId');
        print('Response body: ${response.body}');  // Debugging line
        // Parse the role from the response body
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String role = responseBody['role'];  // Extract role

        // Optionally, save the role in SharedPreferences to use later
        // await prefs.setString('userRole', role);

        return role;  // Return the role for further handling (admin or propertyowner)
      }
    }
    print('Login failed: ${response.statusCode} - ${response.body}');
    return "invalid";  // If login fails, return "invalid"
  }


  // Signup Function
  static Future<bool> signupUser(String name, String email, String password, String phone, String role) async {
    final url = Uri.parse('$baseUrl/signup');
    print(url);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        "role": role,
        'contact_No': phone,
      }),
    );
    print(response);
    if (response.statusCode == 201) {
      print('Signup successful: ${response.body}');
      final prefs = await SharedPreferences.getInstance();
      final jsessionId = response.headers['set-cookie']?.split(';').first;

      if (jsessionId != null) {
        await prefs.setString('JSESSIONID', jsessionId);
        print('Login successful. JSESSIONID stored: $jsessionId');
        return true;
      }
      return true;
    }

    print('Signup failed: ${response.body}');
    return false;
  }


  // Logout Function
  static Future<bool> logoutUser() async {
    final url = Uri.parse('$baseUrl/logout');
    final prefs = await SharedPreferences.getInstance();
    final jsessionId = prefs.getString('JSESSIONID');

    if (jsessionId == null) {
      print('No session found to log out');
      return false;
    }

    final response = await http.post(
      url,
      headers: {
        'Cookie': jsessionId,
      },
    );

    if (response.statusCode == 200) {
      await prefs.remove('JSESSIONID');
      print('Logout successful');
      return true;
    }
    print('Logout failed: ${response.body}');
    return false;
  }

  static Future<bool> fetchProtectedData() async {
    final url = Uri.parse('$baseUrl/protected-endpoint');
    final prefs = await SharedPreferences.getInstance();
    final jsessionId = prefs.getString('JSESSIONID');

    if (jsessionId == null) {
      print('No session found, user not logged in');
      return false;
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Cookie': jsessionId,
        },
      ).timeout(Duration(seconds: 10)); // Timeout after 10 seconds

      if (response.statusCode == 200) {
        print('Protected data: ${response.body}');
        return true;
      } else {
        print('Request failed: ${response.statusCode} - ${response.body}');
        return false;
      }
    } on TimeoutException {
      print("Request timed out!");
      return false;
    } catch (e) {
      print("An error occurred: $e");
      return false;
    }
  }

  static Future<bool> loadhomescreen() async{
    bool x = await AuthFunctions.fetchProtectedData();
    return x;
  }

}
