import 'package:homesphere/models/User.dart';
import 'package:homesphere/models/Property.dart';

class Payment {
  final int? id;
  final double amount;
  final DateTime paymentDate;
  final User user;
  final Property property;

  Payment({
    this.id,
    required this.amount,
    required this.paymentDate,
    required this.user,
    required this.property,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
      user: User.fromJson(json['user']),
      property: Property.fromJson(json['property']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'paymentDate': paymentDate.toIso8601String(),
      'userId': user.id,
      'propertyId': property.id,
    };
  }
}
