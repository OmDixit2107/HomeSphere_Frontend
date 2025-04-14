import 'package:homesphere/services/api/AuthAPI.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Authfunctions {
  // Login Function
  static Future<String> loginUser(String email, String password) async {
    final response = await AuthApi.login(email, password);
    print(response);

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      final jsessionId = response.headers['set-cookie']?.split(';').first;

      if (jsessionId != null) {
        await prefs.setString('JSESSIONID', jsessionId);
        await prefs.setString('email', email);
        print('Login successful. JSESSIONID stored: $jsessionId');
        String? x = prefs.getString('email');
        final b = await Authfunctions.getUserEmail();
        print("Printing B " + b);
        // Parse role from response body
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String role = responseBody['role'];
        print(role);
        await prefs.setString('userRole', role);
        return role;
      }
    }
    print('Login failed: ${response.statusCode} - ${response.body}');
    return "invalid";
  }

  // Signup Function
  static Future<bool> signupUser(String name, String email, String password,
      String phone, String role) async {
    final response = await AuthApi.signup(name, email, password, phone, role);

    if (response.statusCode == 201) {
      final prefs = await SharedPreferences.getInstance();
      final jsessionId = response.headers['set-cookie']?.split(';').first;

      if (jsessionId != null) {
        await prefs.setString('JSESSIONID', jsessionId);
      }
      return true;
    }
    return false;
  }

  // Logout Function
  static Future<bool> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();

    final role = prefs.getString('userRole') ?? '';
    print("Logging out user with role: $role");

    await prefs.remove('JSESSIONID');
    await prefs.remove('userRole');
    await prefs.remove('email');
    return true;
  }

  // Retrieve User Role
  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userRole') ?? "invalid";
  }

  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? "invalid";
  }

  // Check if User is Authenticated
  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('JSESSIONID') != null;
  }
  // static Future<String> getUserRole() async {
  // // Retrieve the user role from SharedPreferences (if stored) or from backend
  // final prefs = await SharedPreferences.getInstance();
  // final role = prefs.getString('userRole') ?? '';
  // print("this is while getting\n");
  // print(role); // Default to empty string if not found
  // return role;
}
