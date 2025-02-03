import 'package:homesphere/models/User.dart';

class Property {
  final int? id;
  final User user;
  final String title;
  final String description;
  final double price;
  final String location;
  final String type;
  final String status;
  final bool emiAvailable;
  final List<String> images; // List to store image URLs

  Property({
    this.id,
    required this.user,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.type,
    required this.status,
    required this.emiAvailable,
    required this.images, // Add images here
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      user: User.fromJson(json['user']),
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      location: json['location'],
      type: json['type'],
      status: json['status'],
      emiAvailable: json['emiAvailable'],
      images: List<String>.from(json['images'] ?? []), // Parse images from JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'type': type,
      'status': status,
      'emiAvailable': emiAvailable,
    };
  }
}
