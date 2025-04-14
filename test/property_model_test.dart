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
  group('Property Model Tests', () {
    late User testUser;

    setUp(() {
      // Initialize test user
      testUser = User(
        id: 1,
        name: 'Test Owner',
        email: 'owner@example.com',
        password: 'password123',
        contact_No: '1234567890',
        role: 'Property Owner',
      );
    });

    test('Property fromJson creates property correctly', () {
      // Test data
      final Map<String, dynamic> propertyData = {
        'id': 1,
        'user': testUser.toJson(),
        'title': 'Luxury Apartment',
        'description': 'A beautiful apartment with great views',
        'price': 250000.0,
        'location': 'Downtown',
        'type': 'buy',
        'status': 'available',
        'emiAvailable': true,
        'images': ['image1.jpg', 'image2.jpg'],
      };

      // Create property from JSON
      final Property property = Property.fromJson(propertyData);

      // Verify all properties
      expect(property.id, equals(1));
      expect(property.user.id, equals(testUser.id));
      expect(property.user.name, equals(testUser.name));
      expect(property.title, equals('Luxury Apartment'));
      expect(property.description, equals('A beautiful apartment with great views'));
      expect(property.price, equals(250000.0));
      expect(property.location, equals('Downtown'));
      expect(property.type, equals('buy'));
      expect(property.status, equals('available'));
      expect(property.emiAvailable, isTrue);
      expect(property.images, hasLength(2));
      expect(property.images, contains('image1.jpg'));
    });

    test('Property fromJson handles integer price', () {
      // Test data with integer price
      final Map<String, dynamic> propertyData = {
        'id': 2,
        'user': testUser.toJson(),
        'title': 'Studio Apartment',
        'description': 'Cozy studio for rent',
        'price': 1500, // Integer price
        'location': 'Uptown',
        'type': 'rent',
        'status': 'available',
        'emiAvailable': false,
        'images': ['image3.jpg'],
      };

      // Create property from JSON
      final Property property = Property.fromJson(propertyData);

      // Verify price is converted to double
      expect(property.price, equals(1500.0));
      expect(property.price, isA<double>());
    });

    test('Property toJson converts property to JSON correctly', () {
      // Create a property
      final Property property = Property(
        id: 3,
        user: testUser,
        title: 'Beach House',
        description: 'Beautiful beach house with ocean views',
        price: 500000.0,
        location: 'Coastal Area',
        type: 'buy',
        status: 'available',
        emiAvailable: true,
        images: ['beach1.jpg', 'beach2.jpg', 'beach3.jpg'],
      );

      // Convert to JSON
      final Map<String, dynamic> json = property.toJson();

      // Verify all keys and values
      expect(json['id'], equals(3));
      expect(json['user'], isA<Map<String, dynamic>>());
      expect(json['user']['id'], equals(testUser.id));
      expect(json['title'], equals('Beach House'));
      expect(json['description'], equals('Beautiful beach house with ocean views'));
      expect(json['price'], equals(500000.0));
      expect(json['location'], equals('Coastal Area'));
      expect(json['type'], equals('buy'));
      expect(json['status'], equals('available'));
      expect(json['emiAvailable'], isTrue);
      // Note: images are not included in toJson as per the model implementation
    });

    test('Property serialization and deserialization maintains data integrity', () {
      // Create a property
      final Property originalProperty = Property(
        id: 4,
        user: testUser,
        title: 'Mountain Cabin',
        description: 'Secluded cabin in the mountains',
        price: 350000.0,
        location: 'Mountain Range',
        type: 'buy',
        status: 'available',
        emiAvailable: false,
        images: ['cabin1.jpg', 'cabin2.jpg'],
      );

      // Serialize to JSON
      final Map<String, dynamic> json = originalProperty.toJson();
      
      // Add images field since it's not included in toJson but expected in fromJson
      json['images'] = originalProperty.images;

      // Deserialize back to Property
      final Property deserializedProperty = Property.fromJson(json);

      // Verify data integrity
      expect(deserializedProperty.id, equals(originalProperty.id));
      expect(deserializedProperty.title, equals(originalProperty.title));
      expect(deserializedProperty.description, equals(originalProperty.description));
      expect(deserializedProperty.price, equals(originalProperty.price));
      expect(deserializedProperty.location, equals(originalProperty.location));
      expect(deserializedProperty.type, equals(originalProperty.type));
      expect(deserializedProperty.status, equals(originalProperty.status));
      expect(deserializedProperty.emiAvailable, equals(originalProperty.emiAvailable));
      expect(deserializedProperty.images, equals(originalProperty.images));
    });

    test('Property mainImage getter returns first image or default', () {
      // Property with images
      final Property propertyWithImages = Property(
        id: 5,
        user: testUser,
        title: 'House with Images',
        description: 'Has multiple images',
        price: 200000.0,
        location: 'Somewhere',
        type: 'buy',
        status: 'available',
        emiAvailable: true,
        images: ['first.jpg', 'second.jpg'],
      );

      // Property without images
      final Property propertyWithoutImages = Property(
        id: 6,
        user: testUser,
        title: 'House without Images',
        description: 'Has no images',
        price: 200000.0,
        location: 'Somewhere',
        type: 'buy',
        status: 'available',
        emiAvailable: true,
        images: [],
      );

      // Verify mainImage getter returns first image when available
      expect(propertyWithImages.mainImage, equals('first.jpg'));

      // Verify mainImage getter returns default when no images available
      expect(propertyWithoutImages.mainImage, equals('assets/images/default_property.png'));
    });
  });
}
