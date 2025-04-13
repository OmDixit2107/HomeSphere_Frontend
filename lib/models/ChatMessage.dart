import 'package:homesphere/models/User.dart';

enum MessageType { CHAT, JOIN, LEAVE }

class ChatMessage {
  final int? id;
  final String? content;
  final User sender;
  final User recipient;
  final MessageType type;
  final DateTime timestamp;
  final bool isRead;

  ChatMessage({
    this.id,
    this.content,
    required this.sender,
    required this.recipient,
    required this.type,
    required this.timestamp,
    this.isRead = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      content: json['content'] as String?,
      sender: json['sender'] is Map
          ? User.fromJson(json['sender'])
          : User(
              id: int.tryParse(json['sender']?.toString() ?? '0') ?? 0,
              email: '',
              name: '',
              password: '',
              contact_No: null,
              role: '',
            ),
      recipient: json['recipient'] is Map
          ? User.fromJson(json['recipient'])
          : User(
              id: int.tryParse(json['recipient']?.toString() ?? '0') ?? 0,
              email: '',
              name: '',
              password: '',
              contact_No: null,
              role: '',
            ),
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MessageType.CHAT,
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
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
      'isRead': isRead,
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
