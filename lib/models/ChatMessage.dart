import 'package:homesphere/models/User.dart';

enum MessageType { CHAT, JOIN, LEAVE }

class ChatMessage {
  final int? id;
  final String? content;
  final User sender;
  final User recipient;
  final MessageType type;
  final DateTime timestamp;

  ChatMessage({
    this.id,
    this.content,
    required this.sender,
    required this.recipient,
    required this.type,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Handle both direct IDs and nested objects
    int senderId = json['senderId'] ?? json['sender']?['id'];
    int recipientId = json['recipientId'] ?? json['recipient']?['id'];

    final sender = User(
      id: senderId,
      name: json['sender']?['name'] ?? '',
      email: json['sender']?['email'] ?? '',
      password: json['sender']?['password'] ?? '',
      contact_No: json['sender']?['contact_No'] ?? '',
      role: json['sender']?['role'] ?? '',
    );

    final recipient = User(
      id: recipientId,
      name: json['recipient']?['name'] ?? '',
      email: json['recipient']?['email'] ?? '',
      password: json['recipient']?['password'] ?? '',
      contact_No: json['recipient']?['contact_No'] ?? '',
      role: json['recipient']?['role'] ?? '',
    );

    return ChatMessage(
      id: json['id'],
      content: json['content'],
      sender: sender,
      recipient: recipient,
      type: MessageType.values.firstWhere(
        (e) => e.toString() == 'MessageType.${json['type']}',
        orElse: () => MessageType.CHAT,
      ),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'content': content,
      'sender': sender.toJson(),
      'recipient': recipient.toJson(),
      'type': type.toString().split('.').last,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Simplified version for sending messages
  Map<String, dynamic> toSendJson() {
    return {
      'content': content,
      'senderId': sender.id ?? 0,
      'recipientId': recipient.id ?? 0,
      'type': type.toString().split('.').last,
    };
  }
}
