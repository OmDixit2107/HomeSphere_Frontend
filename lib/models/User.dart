class User {
  final int id;
  final String email;
  final String name;
  final String password; // This should be hashed in production
  final String? contact_No;
  final String role; // e.g., 'admin', 'user', etc.

  // Constructor
  User({
    required this.id,
    required this.email,
    required this.name,
    required this.password,
    required this.contact_No,
    required this.role,
  });

  // Convert User object to a Map (for JSON serialization)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'password': password, // Note: Make sure this is hashed before sending
      'contact_No': contact_No,
      'role': role,
    };
  }

  // Create User object from Map (for JSON deserialization)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      password:
          json['password'], // In production, don't store password in plain text
      contact_No: json['contact_No'],
      role: json['role'],
    );
  }
}
