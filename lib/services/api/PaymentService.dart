import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:homesphere/models/Payment.dart';
// import 'package:homesphere/config/ApiConfig.dart';

class PaymentService {
  static const String baseUrl =
      'http://10.0.2.2:8090'; // Update with your backend URL

  static Future<Payment> createPayment(Payment payment) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': payment.amount,
          'paymentDate': payment.paymentDate.toIso8601String(),
          'user': payment.user,
          'property': payment.property,
        }),
      );

      print('Payment API Response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Create a new payment object using the response data but keeping our original user and property
        final responseJson = jsonDecode(response.body);
        return Payment(
            id: responseJson['id'],
            amount: responseJson['amount'].toDouble(),
            paymentDate: DateTime.parse(responseJson['paymentDate']),
            user: payment.user, // Use the original user
            property: payment.property // Use the original property
            );
      } else {
        throw Exception('Payment failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Payment service error: $e');
      throw Exception('Payment processing failed. Please try again.');
    }
  }

  static Future<List<Payment>> getPaymentsByUser(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/payments/user/$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }

  static Future<List<Payment>> getPaymentsByProperty(int propertyId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/payments/property/$propertyId'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Payment.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load payments');
    }
  }
}
