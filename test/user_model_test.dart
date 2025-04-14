import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesphere/models/User.dart';

void main() {
  group('User Model Tests', () {
    test('User fromJson creates user correctly', () {
      // Test data
      final Map<String, dynamic> userData = {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'password': 'hashed_password',
        'contact_No': '1234567890',
        'role': 'User',
      };

      // Create user from JSON
      final User user = User.fromJson(userData);

      // Verify all properties
      expect(user.id, equals(1));
      expect(user.name, equals('Test User'));
      expect(user.email, equals('test@example.com'));
      expect(user.password, equals('hashed_password'));
      expect(user.contact_No, equals('1234567890'));
      expect(user.role, equals('User'));
    });

    test('User toJson converts user to JSON correctly', () {
      // Create a user
      final User user = User(
        id: 2,
        name: 'Jane Doe',
        email: 'jane@example.com',
        password: 'password123',
        contact_No: '0987654321',
        role: 'Property Owner',
      );

      // Convert to JSON
      final Map<String, dynamic> json = user.toJson();

      // Verify all keys and values
      expect(json['id'], equals(2));
      expect(json['name'], equals('Jane Doe'));
      expect(json['email'], equals('jane@example.com'));
      expect(json['password'], equals('password123'));
      expect(json['contact_No'], equals('0987654321'));
      expect(json['role'], equals('Property Owner'));
    });

    test('User serialization and deserialization maintains data integrity', () {
      // Create a user
      final User originalUser = User(
        id: 3,
        name: 'John Smith',
        email: 'john@example.com',
        password: 'secure_password',
        contact_No: '5551234567',
        role: 'User',
      );

      // Serialize to JSON
      final Map<String, dynamic> json = originalUser.toJson();

      // Deserialize back to User
      final User deserializedUser = User.fromJson(json);

      // Verify data integrity
      expect(deserializedUser.id, equals(originalUser.id));
      expect(deserializedUser.name, equals(originalUser.name));
      expect(deserializedUser.email, equals(originalUser.email));
      expect(deserializedUser.password, equals(originalUser.password));
      expect(deserializedUser.contact_No, equals(originalUser.contact_No));
      expect(deserializedUser.role, equals(originalUser.role));
    });

    test('User from JSON with null or missing fields', () {
      // Test data with missing fields
      final Map<String, dynamic> incompleteData = {
        'id': 4,
        'name': 'Incomplete User',
        'email': 'incomplete@example.com',
        // Missing password, contactNo and role
      };

      // Create user from incomplete JSON - will fail if the model doesn't handle missing fields
      expect(() => User.fromJson(incompleteData), throwsA(anything));
      
      // In a more robust implementation, the model might handle missing fields with defaults
      // In that case, the test would be different
    });
  });
} 