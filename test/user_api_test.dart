import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
// import 'package:homesphere/api/UserApi.dart';
import 'package:homesphere/models/User.dart';
import 'package:homesphere/services/api/UserAPI.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('UserApi Tests', () {
    test('Create user returns User object', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              'id': 1,
              'name': 'Test User',
              'email': 'test@example.com',
              'password': 'secret'
            }),
            200);
      });

      UserApi.client = mockClient; // Add a static client in UserApi for testing
      final user = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        password: 'secret',
        contact_No: '1234567890',
        role: 'user',
      );
      final createdUser = await UserApi.createUser(user);

      expect(createdUser, isNotNull);
      expect(createdUser!.email, equals('test@example.com'));
    });

    test('Get all users returns list of User', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode([
              {
                'id': 1,
                'name': 'User1',
                'email': 'u1@example.com',
                'password': '1234'
              }
            ]),
            200);
      });

      UserApi.client = mockClient;
      final users = await UserApi.getAllUsers();

      expect(users.length, greaterThan(0));
      expect(users.first.name, equals('User1'));
    });

    test('Login user returns valid User', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              'id': 10,
              'name': 'Alice',
              'email': 'alice@example.com',
              'password': 'pass'
            }),
            200);
      });

      UserApi.client = mockClient;
      final user = await UserApi.loginUser('alice@example.com', 'pass');

      expect(user, isNotNull);
      expect(user!.name, equals('Alice'));
    });

    // Add more: getUserById, updateUser, deleteUser, doesUserExist, etc.
  });
}
