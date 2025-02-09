import 'dart:convert';
import 'package:homesphere/models/User.dart'; // Assuming you have a User model defined
import 'package:http/http.dart' as http;

class UserApi {
  static const String baseUrl = 'http://10.0.2.2:8090/api/users';

  // Create a new user
  static Future<User?> createUser(User user) async {
    final url = Uri.parse('$baseUrl/create');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Get all users
  static Future<List<User>> getAllUsers() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => User.fromJson(e)).toList();
    }
    return [];
  }

  // Get user by ID
  static Future<User?> getUserById(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Get user by email
  static Future<User?> getUserByEmail(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/by-email/${email}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      // Ensure the response is properly formatted
      if (data is Map<String, dynamic>) {
        return User.fromJson(data);
      }
    }
    print("directly returning null\n");
    return null;
  }

  // Update a user
  static Future<User?> updateUser(int id, User updatedUser) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updatedUser.toJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Delete a user
  static Future<bool> deleteUser(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url);

    return response.statusCode == 204;
  }

  // Check if user exists by email
  static Future<bool> doesUserExist(String email) async {
    final url = Uri.parse('$baseUrl/exists/$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    }
    return false;
  }

  static Future<int?> getUserIdByEmail(String email) async {
    final url = Uri.parse('$baseUrl/by-email/$email');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      // Ensure the response contains a map and has the "id" key
      if (data is Map<String, dynamic>) {
        print("inside\n");
        print(data["id"]);
        return data["id"];
      } else {
        // Handle the case where "id" is not present
        print("ID not found in response: $data");
      }
    } else {
      print("Request failed with status: ${response.statusCode}");
    }
    return null;
  }

  // Login a user (assuming authentication via email and password)
  static Future<User?> loginUser(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Logout a user
  static Future<bool> logoutUser(String email) async {
    final url = Uri.parse('$baseUrl/logout');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return response.statusCode == 200;
  }

  // Reset password for a user (send a reset link or process)
  static Future<bool> resetPassword(String email) async {
    final url = Uri.parse('$baseUrl/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return response.statusCode == 200;
  }
}
