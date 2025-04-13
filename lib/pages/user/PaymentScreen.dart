import 'package:flutter/material.dart';
import 'package:homesphere/models/Payment.dart';
import 'package:homesphere/models/Property.dart';
import 'package:homesphere/models/User.dart';
import 'package:homesphere/services/api/PaymentService.dart';

class PaymentScreen extends StatefulWidget {
  final Property property;
  final User currentUser;

  const PaymentScreen({
    Key? key,
    required this.property,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;

  Future<void> _processPayment() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Create payment object with proper type casting
      final payment = Payment(
        amount: widget.property.price.toDouble(),
        paymentDate: DateTime.now(),
        user: widget.currentUser,
        property: widget.property,
      );

      // Add debug print to check payment object
      print('Sending payment: ${payment.toJson()}');

      // Make the API call
      final response = await PaymentService.createPayment(payment);

      if (!mounted) return;

      // Show success message and return to previous screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment processed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Add small delay before popping
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      // Improved error handling with stack trace
      print('Payment error: $e');
      print('Stack trace: $stackTrace');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Payment failed: ${e.toString().replaceAll('Exception:', '')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _processPayment,
            textColor: Colors.white,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Property Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.property.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.property.location,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Payment Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Amount:'),
                        Text(
                          '₹${widget.property.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Payment Button
            ElevatedButton(
              onPressed: _isLoading ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Confirm Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
