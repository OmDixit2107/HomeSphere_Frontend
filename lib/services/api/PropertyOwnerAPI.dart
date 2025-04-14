import 'dart:convert';
import 'dart:io';
import 'package:homesphere/models/Property.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class PropertyOwnerApi {
  static const String baseUrl = 'http://10.0.2.2:8090/api/properties';

  static Future<Property?> createProperty(
      Property property, List<File> images) async {
    try {
      print('📤 Creating property with title: ${property.title}');
      print('📸 Number of images to upload: ${images.length}');

      final url = Uri.parse('$baseUrl/create');
      print('🌐 Making request to: $url');

      // Create a multipart request
      var request = http.MultipartRequest('POST', url);

      // Add the property object to the form data
      final propertyJson = property.toJson();
      print('📦 Property JSON: $propertyJson');
      request.fields['property'] = jsonEncode(propertyJson);

      // Add images to the form data
      for (var image in images) {
        try {
          var mimeType = lookupMimeType(image.path);
          print('🖼️ Processing image: ${image.path} (type: $mimeType)');

          var imageFile = await http.MultipartFile.fromPath(
            'images', // Changed from 'imageFile' to match server expectation
            image.path,
            contentType: MediaType.parse(mimeType ?? 'image/jpeg'),
          );
          request.files.add(imageFile);
        } catch (e) {
          print('❌ Error processing image ${image.path}: $e');
        }
      }

      // Add headers if needed
      request.headers['Content-Type'] = 'multipart/form-data';

      // Send the request
      print('📤 Sending request...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Property created successfully');
        return Property.fromJson(jsonDecode(response.body));
      } else {
        print('❌ Failed to create property');
        print('Status Code: ${response.statusCode}');
        print('Error Response: ${response.body}');
        throw Exception('Failed to create property: ${response.body}');
      }
    } catch (e, stackTrace) {
      print('❌ Exception while creating property: $e');
      print('📚 Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<Property?> updateProperty(
      int id, Property updatedProperty, List<File> images) async {
    final url = Uri.parse('$baseUrl/$id');

    // Create a multipart request for update
    var request = http.MultipartRequest('PUT', url);

    // Add updated property data as fields
    request.fields['title'] = updatedProperty.title;
    request.fields['description'] = updatedProperty.description;
    request.fields['price'] = updatedProperty.price.toString();
    request.fields['location'] = updatedProperty.location;
    request.fields['type'] = updatedProperty.type;
    request.fields['status'] = updatedProperty.status;
    request.fields['emiAvailable'] = updatedProperty.emiAvailable.toString();

    // Add images as multipart files
    for (int i = 0; i < images.length; i++) {
      var imageFile = await http.MultipartFile.fromPath(
        'images',
        images[i].path,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(imageFile);
    }

    // Send the request
    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // Convert response to a property object and return
        var responseData = await response.stream.bytesToString();
        return Property.fromJson(jsonDecode(responseData));
      } else {
        print('Failed to update property. Status Code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error updating property: $e');
      return null;
    }
  }

  // Get all properties
  static Future<List<Property>> getAllProperties() async {
    final url = Uri.parse(baseUrl);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Property.fromJson(e)).toList();
    }
    return [];
  }

  // // Get all properties by type
  // static Future<List<Property>> getAllPropertiesbyType() async {
  //   final url = Uri.parse(baseUrl);
  //   final response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     List<dynamic> data = jsonDecode(response.body);
  //     return data.map((e) => Property.fromJson(e)).toList();
  //   }
  //   return [];
  // }

  // Get all properties by user id
  static Future<List<Property>> getPropertiesByUserId(int userId) async {
    final url = Uri.parse('$baseUrl/user/$userId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Property.fromJson(e)).toList();
    }
    return [];
  }

  // Get property by ID
  static Future<Property?> getPropertyById(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Property.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  // Get properties by type (e.g., "buy" or "rent")
  static Future<List<Property>> getPropertiesByType(String type) async {
    final url = Uri.parse('$baseUrl/type/$type');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Property.fromJson(e)).toList();
    }
    return [];
  }

  // Get properties by status (e.g., "available", "sold", "rented")
  static Future<List<Property>> getPropertiesByStatus(String status) async {
    final url = Uri.parse('$baseUrl/status/$status');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Property.fromJson(e)).toList();
    }
    return [];
  }

  // Get properties by location
  static Future<List<Property>> getPropertiesByLocation(String location) async {
    final url = Uri.parse('$baseUrl/location/$location');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Property.fromJson(e)).toList();
    }
    return [];
  }

  // Delete a property
  static Future<bool> deleteProperty(int id) async {
    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(url);

    return response.statusCode == 204;
  }

  // Check if EMI is available for a property
  static Future<bool> isEmiAvailable(int id) async {
    final url = Uri.parse('$baseUrl/$id/emi');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    }
    return false;
  }

  static Future<http.Response> getImageByPropertyId(int id) async {
    final url = Uri.parse('$baseUrl/user/image/$id');
    final response = await http.get(url);
    return response;
  }
}
