import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
// import 'package:homesphere/api/PropertyOwnerApi.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/models/User.dart';
import 'package:homesphere/services/api/PropertyOwnerAPI.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('PropertyOwnerApi Tests', () {
    late Property testProperty;

    setUp(() {
      final testUser = User(
        id: 1,
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        contact_No: "1234567890",
        role: 'user',
      );

      testProperty = Property(
        id: 1,
        user: testUser,
        title: 'Test Property',
        description: 'A beautiful house',
        price: 250000,
        location: 'City Center',
        type: 'buy',
        status: 'available',
        emiAvailable: true,
        images: [],
      );
    });

    test('getAllProperties should return list of properties', () async {
      // Arrange
      PropertyOwnerApi.baseUrl;
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode([
              {
                'id': 1,
                'user': {
                  'id': 1,
                  'name': 'Test User',
                  'email': 'test@example.com',
                  'password': 'password123',
                  'contact_No': "1234567890",
                  'role': 'user',
                },
                'title': 'Test Property',
                'description': 'A beautiful house',
                'price': 250000,
                'location': 'City Center',
                'type': 'buy',
                'status': 'available',
                'emiAvailable': true,
                'images': [],
              }
            ]),
            200);
      });

      // Inject the mock client using a patch or wrapper if needed
      final properties = await PropertyOwnerApi.getAllProperties();

      // Assert
      expect(properties, isA<List<Property>>());
      expect(properties.first.title, equals('Test Property'));
    });

    test('getPropertyById should return a property', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              'id': 1,
              'user': {
                'id': 1,
                'name': 'Test User',
                'email': 'test@example.com',
                'password': 'password123',
                'contact_No': "1234567890",
                'role': 'user',
              },
              'title': 'Test Property',
              'description': 'A beautiful house',
              'price': 250000,
              'location': 'City Center',
              'type': 'buy',
              'status': 'available',
              'emiAvailable': true,
              'images': [],
            }),
            200);
      });

      // Mock directly if you adapt PropertyOwnerApi to accept a http.Client parameter
      final property = await PropertyOwnerApi.getPropertyById(1);
      expect(property, isNotNull);
      expect(property!.title, equals('Test Property'));
    });

    // More tests can include:
    // - createProperty (requires multipart testing)
    // - updateProperty
    // - deleteProperty
    // - getPropertiesByUserId
    // - getPropertiesByType/status/location
  });
}
